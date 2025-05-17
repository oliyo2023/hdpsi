import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:hd_psi_mobile/utils/app_theme.dart';

/// 中国风格的动画头部组件
class ChineseStyleHeader extends StatefulWidget {
  final String title;
  final double height;
  final bool showBackButton;

  const ChineseStyleHeader({
    super.key,
    required this.title,
    this.height = 180.0,
    this.showBackButton = false,
  });

  @override
  State<ChineseStyleHeader> createState() => _ChineseStyleHeaderState();
}

class _ChineseStyleHeaderState extends State<ChineseStyleHeader>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _cloudAnimation1;
  late Animation<double> _cloudAnimation2;
  late Animation<double> _mountainAnimation;
  late Animation<double> _titleOpacityAnimation;
  late Animation<double> _titleSlideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    );

    _cloudAnimation1 = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.7, curve: Curves.easeOut),
      ),
    );

    _cloudAnimation2 = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.2, 0.9, curve: Curves.easeOut),
      ),
    );

    _mountainAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.1, 0.8, curve: Curves.easeOut),
      ),
    );

    _titleOpacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.6, 1.0, curve: Curves.easeOut),
      ),
    );

    _titleSlideAnimation = Tween<double>(begin: 30.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.6, 1.0, curve: Curves.easeOut),
      ),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: widget.height,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppTheme.primaryColor.withAlpha(
              (AppTheme.primaryColor.a * 0.9).round(),
            ),
            AppTheme.primaryDarkColor,
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(40),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        children: [
          // 山水画背景
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: AnimatedBuilder(
              animation: _mountainAnimation,
              builder: (context, child) {
                return Opacity(
                  opacity: _mountainAnimation.value,
                  child: CustomPaint(
                    size: Size(MediaQuery.of(context).size.width, 80),
                    painter: MountainPainter(),
                  ),
                );
              },
            ),
          ),

          // 云纹1
          AnimatedBuilder(
            animation: _cloudAnimation1,
            builder: (context, child) {
              return Positioned(
                right: -40 + (60 * _cloudAnimation1.value),
                top: 20 + (5 * math.sin(_controller.value * math.pi)),
                child: Opacity(
                  opacity: _cloudAnimation1.value * 0.7,
                  child: CustomPaint(
                    size: const Size(100, 40),
                    painter: CloudPainter(
                      color: Colors.white.withAlpha(
                        (Colors.white.a * 0.3).round(),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),

          // 云纹2
          AnimatedBuilder(
            animation: _cloudAnimation2,
            builder: (context, child) {
              return Positioned(
                left: -20 + (40 * _cloudAnimation2.value),
                top: 50 + (8 * math.sin(_controller.value * math.pi * 0.7)),
                child: Opacity(
                  opacity: _cloudAnimation2.value * 0.5,
                  child: CustomPaint(
                    size: const Size(80, 30),
                    painter: CloudPainter(
                      color: Colors.white.withAlpha(
                        (Colors.white.a * 0.2).round(),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),

          // 标题
          Positioned(
            bottom: 30,
            left: 0,
            right: 0,
            child: AnimatedBuilder(
              animation: _titleOpacityAnimation,
              builder: (context, child) {
                return Opacity(
                  opacity: _titleOpacityAnimation.value,
                  child: Transform.translate(
                    offset: Offset(0, _titleSlideAnimation.value),
                    child: Center(
                      child: Column(
                        children: [
                          // 印章效果
                          Container(
                            padding: const EdgeInsets.all(2),
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: Colors.white.withAlpha(
                                  (Colors.white.a * 0.6).round(),
                                ),
                                width: 1,
                              ),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              widget.title,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: AppTheme.fontSizeExtraLarge,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 4,
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            height: 2,
                            width: 100,
                            decoration: BoxDecoration(
                              color: AppTheme.accentColor,
                              borderRadius: BorderRadius.circular(1),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          // 返回按钮
          if (widget.showBackButton)
            Positioned(
              top: MediaQuery.of(context).padding.top + 10,
              left: 10,
              child: AnimatedBuilder(
                animation: _titleOpacityAnimation,
                builder: (context, child) {
                  return Opacity(
                    opacity: _titleOpacityAnimation.value,
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () => Navigator.of(context).pop(),
                        borderRadius: BorderRadius.circular(
                          AppTheme.borderRadius,
                        ),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white.withAlpha(51),
                            borderRadius: BorderRadius.circular(
                              AppTheme.borderRadius,
                            ),
                          ),
                          child: const Icon(
                            Icons.arrow_back,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}

/// 云纹绘制器
class CloudPainter extends CustomPainter {
  final Color color;

  CloudPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = color
          ..style = PaintingStyle.fill;

    final path = Path();

    // 绘制中国传统云纹
    path.moveTo(0, size.height * 0.5);

    // 第一个云纹
    path.quadraticBezierTo(
      size.width * 0.2,
      0,
      size.width * 0.4,
      size.height * 0.4,
    );

    // 第二个云纹
    path.quadraticBezierTo(
      size.width * 0.6,
      size.height * 0.8,
      size.width * 0.8,
      size.height * 0.3,
    );

    // 第三个云纹
    path.quadraticBezierTo(size.width * 0.9, 0, size.width, size.height * 0.5);

    // 闭合路径
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// 山水画绘制器
class MountainPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = Colors.black.withAlpha((Colors.black.a * 0.1).round())
          ..style = PaintingStyle.fill;

    final path = Path();

    // 远山
    path.moveTo(0, size.height * 0.7);
    path.quadraticBezierTo(
      size.width * 0.2,
      size.height * 0.5,
      size.width * 0.4,
      size.height * 0.6,
    );
    path.quadraticBezierTo(
      size.width * 0.6,
      size.height * 0.7,
      size.width * 0.8,
      size.height * 0.5,
    );
    path.quadraticBezierTo(
      size.width * 0.9,
      size.height * 0.4,
      size.width,
      size.height * 0.6,
    );

    // 闭合路径
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();

    canvas.drawPath(path, paint);

    // 近山
    final nearPath = Path();
    nearPath.moveTo(0, size.height * 0.8);
    nearPath.quadraticBezierTo(
      size.width * 0.3,
      size.height * 0.7,
      size.width * 0.5,
      size.height * 0.8,
    );
    nearPath.quadraticBezierTo(
      size.width * 0.7,
      size.height * 0.9,
      size.width,
      size.height * 0.75,
    );

    // 闭合路径
    nearPath.lineTo(size.width, size.height);
    nearPath.lineTo(0, size.height);
    nearPath.close();

    final nearPaint =
        Paint()
          ..color = Colors.black.withAlpha((Colors.black.a * 0.15).round())
          ..style = PaintingStyle.fill;

    canvas.drawPath(nearPath, nearPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
