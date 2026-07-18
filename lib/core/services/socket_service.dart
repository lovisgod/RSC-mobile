import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:socket_io_client/socket_io_client.dart' as sio;

import '../constants/api_constants.dart';

/// Thin wrapper around a single socket.io connection to the realtime
/// namespace. Registered as a SINGLETON — the whole app shares one socket.
///
/// Auth is via the HttpOnly session cookie already attached by DioClient's
/// cookie jar (`withCredentials: true`), so no token handling here.
class SocketService {
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
  /// dropped.
  final Map<String, Function(dynamic)> _listeners = {};

  bool get isConnected => _isConnected;

  /// Notifies listeners (e.g. the track screen's live/reconnecting badge)
  /// whenever the connection state flips.
  final ValueNotifier<bool> isConnectedNotifier = ValueNotifier(false);

  void connect() {
    _shouldReconnect = true;
    if (_isConnected) return;

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

    _socket = sio.io('${ApiConstants.baseUrl}/realtime', options);

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
      if (_shouldReconnect) _scheduleReconnect();
    });

    _socket!.onReconnect((_) {
      _isConnected = true;
      isConnectedNotifier.value = true;
      debugPrint('[RSC Socket] Reconnected ✅');
      _resubscribeActiveRooms();
    });

    _listeners.forEach((event, handler) => _socket!.on(event, handler));

    _socket!.connect();
    _startConnectivityListener();
  }

  /// Linear backoff (5s, 10s, 15s… up to 10 attempts). Counter resets on a
  /// successful connect or on network restore.
  void _scheduleReconnect() {
    if (_reconnectAttempts >= _maxReconnectAttempts) {
      debugPrint('[RSC Socket] Max reconnect attempts reached. Stopping.');
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
    for (final room in _activeRooms) {
      _socket?.emit('room:subscribe', {'room': room});
    }
  }

  void on(String event, Function(dynamic) handler) {
    _listeners[event] = handler;
    _socket?.on(event, handler);
  }

  void off(String event) {
    _listeners.remove(event);
    _socket?.off(event);
  }
}
