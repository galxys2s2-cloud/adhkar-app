import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

class ArabesqueBackground extends StatelessWidget {
  final Widget child;

  const ArabesqueBackground({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [
                  AppColors.darkBg,
                  AppColors.darkSurface,
                  AppColors.navyDeep,
                  AppColors.darkBg,
                ]
              : [
                  AppColors.lightBg,
                  AppColors.lightSurface,
                  const Color(0xFFF8F4EA),
                  AppColors.lightBg,
                ],
        ),
      ),
      child: Stack(
        children: [
          // Decorative corner patterns
          Positioned(
            top: -40,
            right: -40,
            child: _buildCornerPattern(isDark),
          ),
          Positioned(
            bottom: -40,
            left: -40,
            child: Transform.rotate(
              angle: 3.14159, // 180 degrees
              child: _buildCornerPattern(isDark),
            ),
          ),
          child,
        ],
      ),
    );
  }

  Widget _buildCornerPattern(bool isDark) {
    return Opacity(
      opacity: 0.08,
      child: CustomPaint(
        size: const Size(180, 180),
        painter: _ArabesquePainter(
          color: isDark ? AppColors.gold : AppColors.navyDeep,
        ),
      ),
    );
  }
}

class _ArabesquePainter extends CustomPainter {
  final Color color;

  _ArabesquePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2.5;

    // Outer circle
    canvas.drawCircle(center, radius, paint);

    // Inner circle
    canvas.drawCircle(center, radius * 0.7, paint);

    // Star/petal pattern
    for (int i = 0; i < 8; i++) {
      final angle = (i * 3.14159 * 2) / 8;
      final x1 = center.dx + radius * 0.3 * angle.cos();
      final y1 = center.dy + radius * 0.3 * angle.sin();
      final x2 = center.dx + radius * angle.cos();
      final y2 = center.dy + radius * angle.sin();

      canvas.drawLine(Offset(x1, y1), Offset(x2, y2), paint);
    }

    // Diamond pattern
    final diamondPaint = Paint()
      ..color = color.withValues(alpha: 0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    final path = Path()
      ..moveTo(center.dx, center.dy - radius * 0.5)
      ..lineTo(center.dx + radius * 0.5, center.dy)
      ..lineTo(center.dx, center.dy + radius * 0.5)
      ..lineTo(center.dx - radius * 0.5, center.dy)
      ..close();
    canvas.drawPath(path, diamondPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
