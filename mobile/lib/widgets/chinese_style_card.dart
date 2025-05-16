import 'package:flutter/material.dart';
import '../utils/app_theme.dart';
import 'dart:math' as math;

/// 中国风格卡片组件
class ChineseStyleCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final double elevation;
  final BorderRadius? borderRadius;
  final Color? backgroundColor;
  final Color? borderColor;
  final bool showPattern;
  final PatternType patternType;
  final VoidCallback? onTap;

  const ChineseStyleCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16.0),
    this.elevation = 2.0,
    this.borderRadius,
    this.backgroundColor,
    this.borderColor,
    this.showPattern = true,
    this.patternType = PatternType.cloud,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveBorderRadius =
        borderRadius ?? BorderRadius.circular(AppTheme.borderRadius);
    final effectiveBackgroundColor = backgroundColor ?? AppTheme.cardColor;
    final effectiveBorderColor = borderColor ?? AppTheme.borderColor;

    return Material(
      color: Colors.transparent,
      elevation: elevation,
      borderRadius: effectiveBorderRadius,
      child: InkWell(
        onTap: onTap,
        borderRadius: effectiveBorderRadius,
        child: Container(
          decoration: BoxDecoration(
            color: effectiveBackgroundColor,
            borderRadius: effectiveBorderRadius,
            border: Border.all(color: effectiveBorderColor, width: 1.0),
          ),
          child: Stack(
            children: [
              // 中国传统图案
              if (showPattern)
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: ClipRRect(
                    borderRadius: BorderRadius.only(
                      bottomRight: effectiveBorderRadius.bottomRight,
                    ),
                    child: Opacity(
                      opacity: 0.05,
                      child: CustomPaint(
                        size: const Size(80, 80),
                        painter: _getPatternPainter(patternType),
                      ),
                    ),
                  ),
                ),

              // 卡片内容
              Padding(padding: padding, child: child),
            ],
          ),
        ),
      ),
    );
  }

  CustomPainter _getPatternPainter(PatternType type) {
    switch (type) {
      case PatternType.cloud:
        return ChineseCloudPatternPainter();
      case PatternType.flower:
        return ChineseFlowerPatternPainter();
      case PatternType.wave:
        return ChineseWavePatternPainter();
      case PatternType.lattice:
        return ChineseLatticePatternPainter();
    }
  }
}

/// 中国传统图案类型
enum PatternType {
  cloud, // 云纹
  flower, // 花纹
  wave, // 水纹
  lattice, // 格纹
}

/// 中国云纹图案绘制器
class ChineseCloudPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = Colors.black
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5;

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

    // 第三个云纹
    path.cubicTo(
      centerX + radius,
      centerY - radius / 2,
      centerX + radius / 2,
      centerY - radius,
      centerX,
      centerY - radius,
    );

    // 第四个云纹
    path.cubicTo(
      centerX - radius / 2,
      centerY - radius,
      centerX - radius,
      centerY - radius / 2,
      centerX - radius,
      centerY,
    );

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// 中国花纹图案绘制器
class ChineseFlowerPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = Colors.black
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5;

    final centerX = size.width / 2;
    final centerY = size.height / 2;
    final radius = size.width / 4;

    // 绘制花朵中心
    canvas.drawCircle(Offset(centerX, centerY), radius / 4, paint);

    // 绘制花瓣
    for (int i = 0; i < 8; i++) {
      final angle = i * math.pi / 4;
      final x1 = centerX + radius * math.cos(angle);
      final y1 = centerY + radius * math.sin(angle);

      final path = Path();
      path.moveTo(centerX, centerY);
      path.quadraticBezierTo(
        centerX + radius * 0.8 * math.cos(angle + math.pi / 8),
        centerY + radius * 0.8 * math.sin(angle + math.pi / 8),
        x1,
        y1,
      );
      path.quadraticBezierTo(
        centerX + radius * 0.8 * math.cos(angle - math.pi / 8),
        centerY + radius * 0.8 * math.sin(angle - math.pi / 8),
        centerX,
        centerY,
      );

      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// 中国水纹图案绘制器
class ChineseWavePatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = Colors.black
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5;

    final waveHeight = size.height / 6;
    final waveWidth = size.width / 3;

    for (int i = 0; i < 3; i++) {
      final y = size.height * 0.2 + i * waveHeight * 2;

      final path = Path();
      path.moveTo(0, y);

      for (int j = 0; j < 6; j++) {
        final x1 = j * waveWidth / 2;
        final x2 = (j + 1) * waveWidth / 2;

        if (j % 2 == 0) {
          path.quadraticBezierTo((x1 + x2) / 2, y - waveHeight, x2, y);
        } else {
          path.quadraticBezierTo((x1 + x2) / 2, y + waveHeight, x2, y);
        }
      }

      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// 中国格纹图案绘制器
class ChineseLatticePatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = Colors.black
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.0;

    final cellSize = size.width / 4;

    // 绘制横线
    for (int i = 0; i <= 4; i++) {
      canvas.drawLine(
        Offset(0, i * cellSize),
        Offset(size.width, i * cellSize),
        paint,
      );
    }

    // 绘制竖线
    for (int i = 0; i <= 4; i++) {
      canvas.drawLine(
        Offset(i * cellSize, 0),
        Offset(i * cellSize, size.height),
        paint,
      );
    }

    // 绘制对角线
    for (int i = 0; i < 4; i++) {
      for (int j = 0; j < 4; j++) {
        canvas.drawLine(
          Offset(i * cellSize, j * cellSize),
          Offset((i + 1) * cellSize, (j + 1) * cellSize),
          paint,
        );

        canvas.drawLine(
          Offset((i + 1) * cellSize, j * cellSize),
          Offset(i * cellSize, (j + 1) * cellSize),
          paint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
