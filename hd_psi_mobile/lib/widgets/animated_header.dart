import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../utils/app_theme.dart';

class AnimatedHeader extends StatefulWidget {
  final String title;
  final double height;
  final bool showBackButton;

  const AnimatedHeader({
    super.key,
    required this.title,
    this.height = 150.0,
    this.showBackButton = false,
  });

  @override
  State<AnimatedHeader> createState() => _AnimatedHeaderState();
}

class _AnimatedHeaderState extends State<AnimatedHeader>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _bubbleAnimation1;
  late Animation<double> _bubbleAnimation2;
  late Animation<double> _bubbleAnimation3;
  late Animation<double> _titleOpacityAnimation;
  late Animation<double> _titleSlideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );

    _bubbleAnimation1 = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.7, curve: Curves.easeOut),
      ),
    );

    _bubbleAnimation2 = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.2, 0.9, curve: Curves.easeOut),
      ),
    );

    _bubbleAnimation3 = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.4, 1.0, curve: Curves.easeOut),
      ),
    );

    _titleOpacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.5, 1.0, curve: Curves.easeOut),
      ),
    );

    _titleSlideAnimation = Tween<double>(begin: 50.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.5, 1.0, curve: Curves.easeOut),
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
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppTheme.primaryColor, AppTheme.primaryDarkColor],
        ),
        borderRadius: const BorderRadius.vertical(
          bottom: Radius.circular(AppTheme.borderRadius * 2),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(51),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Stack(
        children: [
          // 装饰性气泡1
          AnimatedBuilder(
            animation: _bubbleAnimation1,
            builder: (context, child) {
              return Positioned(
                right: -50 + (20 * _bubbleAnimation1.value),
                top: -50 + (10 * math.sin(_controller.value * math.pi)),
                child: Opacity(
                  opacity: _bubbleAnimation1.value,
                  child: Container(
                    width: 200,
                    height: 200,
                    decoration: BoxDecoration(
                      color: Colors.white.withAlpha(25),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              );
            },
          ),
          // 装饰性气泡2
          AnimatedBuilder(
            animation: _bubbleAnimation2,
            builder: (context, child) {
              return Positioned(
                left: -30 + (15 * _bubbleAnimation2.value),
                bottom: -30 + (15 * math.sin(_controller.value * math.pi * 2)),
                child: Opacity(
                  opacity: _bubbleAnimation2.value,
                  child: Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      color: Colors.white.withAlpha(25),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              );
            },
          ),
          // 装饰性气泡3
          AnimatedBuilder(
            animation: _bubbleAnimation3,
            builder: (context, child) {
              return Positioned(
                left: 100 + (10 * math.sin(_controller.value * math.pi)),
                top: 20 + (10 * math.cos(_controller.value * math.pi * 2)),
                child: Opacity(
                  opacity: _bubbleAnimation3.value,
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: Colors.white.withAlpha(25),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              );
            },
          ),
          // 标题
          Positioned(
            bottom: 20,
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
                      child: Text(
                        widget.title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: AppTheme.fontSizeExtraLarge,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2,
                          shadows: [
                            Shadow(
                              color: Colors.black26,
                              blurRadius: 5,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
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
