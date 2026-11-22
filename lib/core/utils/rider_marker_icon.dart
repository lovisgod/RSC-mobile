import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

// Draws a directional rider marker (colored disc + heading arrow, pointing
// north/up) once and caches the PNG bytes. Marker.rotation then turns the
// whole icon to face the rider's actual bearing — a plain default pin can't
// convey direction of travel the way this can.
abstract final class RiderMarkerIcon {
  static BitmapDescriptor? _cached;

  static Future<BitmapDescriptor> get() async => _cached ??= await _build();

  static Future<BitmapDescriptor> _build() async {
    const double size = 96;
    const center = Offset(size / 2, size / 2);

    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder, const Rect.fromLTWH(0, 0, size, size));

    canvas.drawCircle(
      center,
      size / 2 - 4,
      Paint()..color = Colors.white.withValues(alpha: 0.95),
    );
    canvas.drawCircle(
      center,
      size / 2 - 10,
      Paint()..color = const Color(0xFF2F80ED),
    );

    final arrow = Path()
      ..moveTo(center.dx, center.dy - size / 2 + 22)
      ..lineTo(center.dx - 13, center.dy + 8)
      ..lineTo(center.dx, center.dy - 4)
      ..lineTo(center.dx + 13, center.dy + 8)
      ..close();
    canvas.drawPath(arrow, Paint()..color = Colors.white);

    final picture = recorder.endRecording();
    final image = await picture.toImage(size.toInt(), size.toInt());
    final bytes = await image.toByteData(format: ui.ImageByteFormat.png);

    return BitmapDescriptor.bytes(
      bytes!.buffer.asUint8List(),
      width: 40,
      height: 40,
    );
  }
}
