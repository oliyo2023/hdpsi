import 'package:flutter/material.dart';
import 'package:hd_psi_mobile/utils/app_theme.dart';
import 'dart:math' as math;

/// 中国风格的快捷操作按钮
class ChineseStyleAction extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color color;
  final VoidCallback onTap;
  final bool useInkEffect;
  final double size;
  final ShapeType shapeType;

  const ChineseStyleAction({
    super.key,
    required this.icon,
    required this.title,
    required this.color,
    required this.onTap,
    this.useInkEffect = true,
    this.size = 60.0,
    this.shapeType = ShapeType.circle,
  });

  @override
  Widget build(BuildContext context) {
    final Widget iconContainer = Container(
      width: size,
      height: size,
      decoration: _getDecoration(),
      child: Icon(icon, size: size * 0.5, color: color),
    );

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // 图标部分
        useInkEffect
            ? Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: onTap,
                borderRadius: _getBorderRadius(),
                child: iconContainer,
              ),
            )
            : GestureDetector(onTap: onTap, child: iconContainer),
        const SizedBox(height: 8),
        // 标题部分
        Text(
          title,
          style: TextStyle(
            fontSize: AppTheme.fontSizeNormal,
            fontWeight: FontWeight.w500,
            color: AppTheme.textPrimaryColor,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  /// 获取装饰样式
  BoxDecoration _getDecoration() {
    switch (shapeType) {
      case ShapeType.circle:
        return BoxDecoration(
          color: color.withAlpha(20),
          shape: BoxShape.circle,
          border: Border.all(color: color.withAlpha(50), width: 1.5),
        );
      case ShapeType.square:
        return BoxDecoration(
          color: color.withAlpha(20),
          borderRadius: BorderRadius.circular(AppTheme.borderRadius),
          border: Border.all(color: color.withAlpha(50), width: 1.5),
        );
      case ShapeType.octagon:
        return BoxDecoration(
          color: color.withAlpha(20),
          borderRadius: BorderRadius.circular(AppTheme.borderRadius),
          border: Border.all(color: color.withAlpha(50), width: 1.5),
          shape: BoxShape.rectangle,
        );
      case ShapeType.seal:
        return BoxDecoration(
          color: color.withAlpha(20),
          shape: BoxShape.circle,
          border: Border.all(color: color.withAlpha(50), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: color.withAlpha(30),
              blurRadius: 5,
              spreadRadius: 1,
            ),
          ],
        );
    }
  }

  /// 获取边框圆角
  BorderRadius _getBorderRadius() {
    switch (shapeType) {
      case ShapeType.circle:
      case ShapeType.seal:
        return BorderRadius.circular(size / 2);
      case ShapeType.square:
      case ShapeType.octagon:
        return BorderRadius.circular(AppTheme.borderRadius);
    }
  }
}

/// 形状类型
enum ShapeType {
  circle, // 圆形
  square, // 方形
  octagon, // 八边形
  seal, // 印章
}

/// 中国风格的功能卡片
class ChineseStyleFeatureCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final String description;
  final VoidCallback onTap;
  final PatternType patternType;

  const ChineseStyleFeatureCard({
    super.key,
    required this.title,
    required this.icon,
    required this.color,
    required this.description,
    required this.onTap,
    this.patternType = PatternType.cloud,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTheme.borderRadius),
        side: BorderSide(color: color.withAlpha(50), width: 1),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppTheme.borderRadius),
        child: Stack(
          children: [
            // 背景图案
            Positioned(
              right: 0,
              bottom: 0,
              child: Opacity(
                opacity: 0.05,
                child: CustomPaint(
                  size: const Size(60, 60),
                  painter: _getPatternPainter(),
                ),
              ),
            ),

            // 内容
            Padding(
              padding: const EdgeInsets.all(AppTheme.spacingMedium),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 图标容器
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: color.withAlpha(25),
                      borderRadius: BorderRadius.circular(
                        AppTheme.borderRadius,
                      ),
                      border: Border.all(color: color.withAlpha(50), width: 1),
                    ),
                    child: Icon(icon, size: 28, color: color),
                  ),
                  const SizedBox(height: AppTheme.spacing),

                  // 标题
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: AppTheme.fontSizeMedium,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimaryColor,
                    ),
                  ),
                  const SizedBox(height: 4),

                  // 描述
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: AppTheme.fontSizeSmall,
                      color: AppTheme.textSecondaryColor,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  CustomPainter _getPatternPainter() {
    switch (patternType) {
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

/// 图案类型
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

/// 中国花纹图案绘制器
class ChineseFlowerPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = Colors.black
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.0;

    final centerX = size.width / 2;
    final centerY = size.height / 2;
    final radius = size.width / 4;

    // 绘制花朵中心
    canvas.drawCircle(Offset(centerX, centerY), radius / 4, paint);

    // 绘制花瓣
    for (int i = 0; i < 4; i++) {
      final angle = i * math.pi / 2;
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
          ..strokeWidth = 1.0;

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
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
