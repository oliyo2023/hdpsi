import 'package:flutter/material.dart';
import '../utils/app_theme.dart';

/// 友好的错误显示组件
/// 
/// 显示用户友好的错误消息，并提供重试选项
class FriendlyErrorDisplay extends StatelessWidget {
  /// 错误消息
  final String message;
  
  /// 重试回调
  final VoidCallback? onRetry;
  
  /// 图标
  final IconData icon;
  
  /// 图标颜色
  final Color iconColor;
  
  /// 是否显示重试按钮
  final bool showRetryButton;

  const FriendlyErrorDisplay({
    super.key,
    required this.message,
    this.onRetry,
    this.icon = Icons.error_outline,
    this.iconColor = Colors.red,
    this.showRetryButton = true,
  });

  /// 网络错误构造函数
  factory FriendlyErrorDisplay.network({
    required String message,
    VoidCallback? onRetry,
  }) {
    return FriendlyErrorDisplay(
      message: message,
      onRetry: onRetry,
      icon: Icons.wifi_off,
      iconColor: Colors.orange,
    );
  }

  /// 服务器错误构造函数
  factory FriendlyErrorDisplay.server({
    required String message,
    VoidCallback? onRetry,
  }) {
    return FriendlyErrorDisplay(
      message: message,
      onRetry: onRetry,
      icon: Icons.cloud_off,
      iconColor: Colors.red,
    );
  }

  /// 认证错误构造函数
  factory FriendlyErrorDisplay.auth({
    required String message,
    VoidCallback? onRetry,
  }) {
    return FriendlyErrorDisplay(
      message: message,
      onRetry: onRetry,
      icon: Icons.lock,
      iconColor: Colors.red,
      showRetryButton: false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 错误图标
            Icon(
              icon,
              color: iconColor,
              size: 64,
            ),
            const SizedBox(height: 24),
            
            // 错误消息
            Text(
              message,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            
            // 重试按钮
            if (showRetryButton && onRetry != null)
              ElevatedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: const Text('重试'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
