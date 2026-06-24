import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

enum AppSnackbarType { info, success, error, loading }

/// Top-anchored custom snackbar with slide-in/out animation.
///
/// Usage:
///   AppSnackbar.show(context, message: 'Done!', type: AppSnackbarType.success);
///   AppSnackbar.show(context, message: 'Logging in...', emoji: '🔑',
///       type: AppSnackbarType.loading, persistent: true);
///   AppSnackbar.dismiss(); // call when loading is done
class AppSnackbar {
  AppSnackbar._();

  static _SnackController? _active;

  static void show(
    BuildContext context, {
    required String message,
    String? emoji,
    AppSnackbarType type = AppSnackbarType.info,
    Duration duration = const Duration(seconds: 3),
    bool persistent = false,
  }) {
    _active?.dismiss();

    final ctrl = _SnackController();
    _active = ctrl;

    late OverlayEntry entry;
    entry = OverlayEntry(
      builder: (_) => _SnackToast(
        message: message,
        emoji: emoji ?? _defaultEmoji(type),
        backgroundColor: _backgroundColor(type),
        controller: ctrl,
        onRemove: () {
          try {
            entry.remove();
          } catch (_) {}
          if (identical(_active, ctrl)) _active = null;
        },
      ),
    );

    Overlay.of(context).insert(entry);

    if (!persistent) {
      Future.delayed(duration, ctrl.dismiss);
    }
  }

  static void dismiss() => _active?.dismiss();

  static String _defaultEmoji(AppSnackbarType type) => switch (type) {
        AppSnackbarType.success => '✅',
        AppSnackbarType.error => '⚠️',
        AppSnackbarType.loading => '⏳',
        AppSnackbarType.info => 'ℹ️',
      };

  static Color _backgroundColor(AppSnackbarType type) => switch (type) {
        AppSnackbarType.success =>  AppColors.surfaceDark,
        AppSnackbarType.error => AppColors.error,
        AppSnackbarType.loading || AppSnackbarType.info => AppColors.surfaceDark,
      };
}

// ── Internal controller ─────────────────────────────────────────────────────

class _SnackController {
  VoidCallback? _dismissFn;
  bool _earlyDismiss = false;

  void _bind(VoidCallback fn) {
    _dismissFn = fn;
    if (_earlyDismiss) fn();
  }

  void dismiss() {
    if (_dismissFn != null) {
      _dismissFn!();
    } else {
      _earlyDismiss = true;
    }
  }
}

// ── Toast widget ────────────────────────────────────────────────────────────

class _SnackToast extends StatefulWidget {
  const _SnackToast({
    required this.message,
    required this.emoji,
    required this.backgroundColor,
    required this.controller,
    required this.onRemove,
  });

  final String message;
  final String emoji;
  final Color backgroundColor;
  final _SnackController controller;
  final VoidCallback onRemove;

  @override
  State<_SnackToast> createState() => _SnackToastState();
}

class _SnackToastState extends State<_SnackToast>
    with SingleTickerProviderStateMixin {
  late final AnimationController _anim;
  late final Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _anim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
      reverseDuration: const Duration(milliseconds: 220),
    );
    _slide = Tween<Offset>(
      begin: const Offset(0, -1.4),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _anim, curve: Curves.easeOutCubic));

    widget.controller._bind(_dismiss);
    _anim.forward();
  }

  @override
  void dispose() {
    _anim.dispose();
    super.dispose();
  }

  Future<void> _dismiss() async {
    if (!mounted) {
      widget.onRemove();
      return;
    }
    await _anim.reverse();
    widget.onRemove();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: MediaQuery.of(context).padding.top + 12,
      left: 16,
      right: 16,
      child: SlideTransition(
        position: _slide,
        child: Material(
          color: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: widget.backgroundColor,
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.20),
                  blurRadius: 20,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Row(
              children: [
                Text(widget.emoji, style: const TextStyle(fontSize: 18)),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    widget.message,
                    style: AppTextStyles.body.copyWith(
                      color: AppColors.textOnDark,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
