import 'package:flutter/material.dart';

/// 中国传统图案绘制器
class ChinesePatternPainter extends CustomPainter {
  final Color color;

  ChinesePatternPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = color.withAlpha((color.a * 0.7).round())
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.0;

    final path = Path();

    // 绘制中国传统云纹
    final centerX = size.width / 2;
    final centerY = size.height / 2;
    final radius = size.width / 3;

    // 第一个云纹
    path.moveTo(centerX - radius, centerY);
    path.cubicTo(
      centerX - radius,
      centerY - radius / 2,
      centerX - radius / 2,
      centerY - radius / 2,
      centerX,
      centerY,
    );

    // 第二个云纹
    path.cubicTo(
      centerX + radius / 2,
      centerY + radius / 2,
      centerX + radius,
      centerY + radius / 2,
      centerX + radius,
      centerY,
    );

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
