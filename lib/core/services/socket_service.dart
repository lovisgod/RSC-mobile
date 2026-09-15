import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:socket_io_client/socket_io_client.dart' as sio;

import '../config/app_config.dart';

/// Thin wrapper around a single socket.io connection to the realtime
/// namespace. Registered as a SINGLETON — the whole app shares one socket.
///
/// Auth is via the HttpOnly session cookie already attached by DioClient's
/// cookie jar (`withCredentials: true`), so no token handling here.
class SocketService {
  SocketService(AppConfig appConfig) : _baseUrl = appConfig.baseUrl;

  final String _baseUrl;
  sio.Socket? _socket;
  bool _isConnected = false;
  final Set<String> _activeRooms = {};

  /// Network-aware reconnection layer on top of socket.io's built-in retry:
  /// socket.io gives up after its own attempt budget, so this timer keeps
  /// trying with linear backoff, and a connectivity listener reconnects
  /// immediately when the network comes back.
  Timer? _reconnectTimer;
  int _reconnectAttempts = 0;
  static const int _maxReconnectAttempts = 10;
  static const Duration _reconnectDelay = Duration(seconds: 5);

  /// True between [connect] (login) and [disconnect] (logout) — an
  /// intentional disconnect must never trigger auto-reconnect.
  bool _shouldReconnect = false;
  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;

  /// Listeners registered via [on] are kept here and reapplied whenever the
  /// socket is (re)created, so a caller that registers before [connect] has
  /// ever run (e.g. a singleton bloc built before login) isn't silently
  /// dropped. Multiple handlers per event are supported — the socket-level
  /// listener is bound ONCE per event and fans out to every handler.
  final Map<String, List<Function(dynamic)>> _listeners = {};

  /// Events that already have a fan-out listener bound to the current socket
  /// instance — guards against double-binding (which would double-deliver).
  final Set<String> _boundEvents = {};

  bool get isConnected => _isConnected;

  /// Notifies listeners (e.g. the track screen's live/reconnecting badge)
  /// whenever the connection state flips.
  final ValueNotifier<bool> isConnectedNotifier = ValueNotifier(false);

  void connect() {
    _shouldReconnect = true;
    if (_isConnected) return;

    // A socket already exists (e.g. retrying on app resume after the backoff
    // gave up) — reuse it instead of leaking it under a force-new replacement.
    if (_socket != null) {
      _reconnectAttempts = 0;
      _reconnectTimer?.cancel();
      _socket!.connect();
      return;
    }

    final options = sio.OptionBuilder()
        .setTransports(['websocket'])
        .setExtraHeaders({})
        .enableReconnection()
        .setReconnectionAttempts(5)
        .setReconnectionDelay(2000)
        .enableForceNew()
        .build();
    // HttpOnly cookie auth — no token needed in headers.
    options['withCredentials'] = true;

    _socket = sio.io('$_baseUrl/realtime', options);

    _socket!.onConnect((_) {
      _isConnected = true;
      isConnectedNotifier.value = true;
      _reconnectAttempts = 0;
      _reconnectTimer?.cancel();
      debugPrint('[RSC Socket] Connected ✅');
      _resubscribeActiveRooms();
    });

    _socket!.onDisconnect((_) {
      _isConnected = false;
      isConnectedNotifier.value = false;
      debugPrint('[RSC Socket] Disconnected');
      if (_shouldReconnect) _scheduleReconnect();
    });

    _socket!.onConnectError((err) {
      debugPrint('[RSC Socket] Connect error: $err');

      if (_isAuthError(err)) {
        // The session cookie is dead — retrying can never succeed. Stop here
        // and let SessionInterceptor drive the actual logout when the next
        // REST call returns 401; the socket never logs out directly.
        debugPrint(
          '[RSC Socket] Auth error detected — stopping reconnect attempts',
        );
        _shouldReconnect = false;
        _reconnectAttempts = 0;
        _reconnectTimer?.cancel();
        return;
      }

      if (_shouldReconnect) _scheduleReconnect();
    });

    _socket!.onReconnect((_) {
      _isConnected = true;
      isConnectedNotifier.value = true;
      debugPrint('[RSC Socket] Reconnected ✅');
      _resubscribeActiveRooms();
    });

    _boundEvents.clear();
    for (final event in _listeners.keys) {
      _bindSocketListener(event);
    }

    _socket!.connect();
    _startConnectivityListener();
  }

  bool _isAuthError(dynamic err) {
    final message = err.toString().toLowerCase();
    return message.contains('401') ||
        message.contains('403') ||
        message.contains('unauthorized') ||
        message.contains('authentication') ||
        message.contains('forbidden');
  }

  /// Linear backoff (5s, 10s, 15s… up to 10 attempts). Counter resets on a
  /// successful connect or on network restore.
  void _scheduleReconnect() {
    if (_reconnectAttempts >= _maxReconnectAttempts) {
      // Not a permanent stop — the next app resume or network restore calls
      // connect() again with a fresh attempt budget.
      debugPrint(
        '[RSC Socket] ⚠️ Max reconnect attempts ($_maxReconnectAttempts) '
        'reached. Socket gave up — will retry on next app resume.',
      );
      return;
    }

    _reconnectTimer?.cancel();
    _reconnectAttempts++;

    final delay = Duration(
      seconds: _reconnectDelay.inSeconds * _reconnectAttempts,
    );
    debugPrint(
      '[RSC Socket] Reconnecting in ${delay.inSeconds}s '
      '(attempt $_reconnectAttempts)',
    );

    _reconnectTimer = Timer(delay, () {
      if (_shouldReconnect && !_isConnected) {
        debugPrint('[RSC Socket] Attempting reconnect...');
        _socket?.connect();
      }
    });
  }

  void _startConnectivityListener() {
    if (_connectivitySubscription != null) return;
    _connectivitySubscription = Connectivity().onConnectivityChanged.listen((
      results,
    ) {
      final hasConnection = results.any((r) => r != ConnectivityResult.none);
      if (hasConnection && !_isConnected && _shouldReconnect) {
        debugPrint('[RSC Socket] Network restored — reconnecting immediately');
        _reconnectAttempts = 0;
        _reconnectTimer?.cancel();
        _socket?.connect();
      }
    });
  }

  void disconnect() {
    _shouldReconnect = false;
    _reconnectTimer?.cancel();
    _reconnectTimer = null;
    _reconnectAttempts = 0;
    _connectivitySubscription?.cancel();
    _connectivitySubscription = null;
    _socket?.disconnect();
    _socket?.dispose();
    _socket = null;
    _boundEvents.clear();
    _isConnected = false;
    isConnectedNotifier.value = false;
    _activeRooms.clear();
    debugPrint('[RSC Socket] Disconnected 🔌');
  }

  void subscribeToRoom(String room) {
    _activeRooms.add(room);
    if (!_isConnected) connect();
    _socket?.emit('room:subscribe', {'room': room});
    debugPrint('[RSC Socket] Subscribed to: $room');
  }

  void unsubscribeFromRoom(String room) {
    _activeRooms.remove(room);
    _socket?.emit('room:unsubscribe', {'room': room});
    debugPrint('[RSC Socket] Unsubscribed: $room');
  }

  void _resubscribeActiveRooms() {
    // Re-ensure event listeners first so no push arriving right after the
    // room re-join is missed ([_bindSocketListener] is a no-op when already
    // bound, so this never double-delivers).
    for (final event in _listeners.keys) {
      _bindSocketListener(event);
    }
    for (final room in _activeRooms) {
      _socket?.emit('room:subscribe', {'room': room});
    }
  }

  /// Binds the single socket-level fan-out listener for [event]. Handlers are
  /// resolved from [_listeners] at dispatch time, so ones added later are
  /// picked up without rebinding.
  void _bindSocketListener(String event) {
    final socket = _socket;
    if (socket == null || _boundEvents.contains(event)) return;
    _boundEvents.add(event);
    socket.on(event, (data) {
      final handlers = List.of(_listeners[event] ?? const []);
      for (final handler in handlers) {
        handler(data);
      }
    });
  }

  void on(String event, Function(dynamic) handler) {
    final handlers = _listeners.putIfAbsent(event, () => []);
    if (!handlers.contains(handler)) handlers.add(handler);
    _bindSocketListener(event);
    debugPrint(
      '[RSC Socket] Handler added for: $event (total: ${handlers.length})',
    );
  }

  /// Removes [handler] for [event], or ALL handlers when [handler] is null.
  /// The socket-level listener is unbound once no handlers remain.
  void off(String event, [Function(dynamic)? handler]) {
    if (handler == null) {
      _listeners.remove(event);
      _socket?.off(event);
      _boundEvents.remove(event);
      debugPrint('[RSC Socket] All handlers removed for: $event');
      return;
    }

    final handlers = _listeners[event];
    handlers?.remove(handler);
    if (handlers != null && handlers.isEmpty) {
      _listeners.remove(event);
      _socket?.off(event);
      _boundEvents.remove(event);
    }
    debugPrint(
      '[RSC Socket] Handler removed for: $event '
      '(remaining: ${_listeners[event]?.length ?? 0})',
    );
  }
}
