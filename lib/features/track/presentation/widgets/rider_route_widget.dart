import 'package:flutter/material.dart';

class RiderRouteWidget extends StatelessWidget {
  const RiderRouteWidget({super.key, required this.progress});

  final double progress;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 140,
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      decoration: BoxDecoration(
        color: const Color(0xFFEEF2FF),
        borderRadius: BorderRadius.circular(16),
      ),
      clipBehavior: Clip.hardEdge,
      child: LayoutBuilder(
        builder: (context, constraints) {
          const startX = 36.0;
          const startY = 98.0;
          const endY = 26.0;
          final endX = constraints.maxWidth - 28.0;

          final motoX = startX + (endX - startX) * progress;
          final motoY = startY + (endY - startY) * progress;

          return Stack(
            children: [
              Positioned.fill(
                child: CustomPaint(
                  painter: _RoutePainter(endX: endX),
                ),
              ),

              // Kitchens dot + label
              Positioned(
                left: 20,
                bottom: 10,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 14,
                      height: 14,
                      decoration: const BoxDecoration(
                        color: Color(0xFF141F3D),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Kitchens',
                      style: TextStyle(
                        fontSize: 11,
                        color: Color(0xFF6B7280),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),

              // Your Home label + dot
              Positioned(
                right: 10,
                top: 12,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Your Home',
                      style: TextStyle(
                        fontSize: 11,
                        color: Color(0xFFD4832A),
                        fontWeight: FontWeight.w600,
                      ),
                      overflow: TextOverflow.clip,
                    ),
                    const SizedBox(width: 4),
                    Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: const Color(0xFFD4832A),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                    ),
                  ],
                ),
              ),

              // Motorcycle emoji
              Positioned(
                left: motoX - 12,
                top: motoY - 12,
                child: const Text('🏍️', style: TextStyle(fontSize: 20)),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _RoutePainter extends CustomPainter {
  const _RoutePainter({required this.endX});

  final double endX;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..strokeWidth = 5
      ..strokeCap = StrokeCap.round;

    canvas.drawLine(
      const Offset(36, 98),
      Offset(endX, 26),
      paint,
    );
  }

  @override
  bool shouldRepaint(_RoutePainter old) => old.endX != endX;
}
