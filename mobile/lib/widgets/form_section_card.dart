import 'package:flutter/material.dart';

/// 表单分组卡片组件
/// 用于将表单字段分组显示，提供更好的视觉层次结构
class FormSectionCard extends StatelessWidget {
  /// 分组标题
  final String title;

  /// 分组图标
  final IconData? icon;

  /// 子组件列表
  final List<Widget> children;

  /// 卡片内边距
  final EdgeInsetsGeometry contentPadding;

  /// 卡片外边距
  final EdgeInsetsGeometry margin;

  const FormSectionCard({
    super.key,
    required this.title,
    this.icon,
    required this.children,
    this.contentPadding = const EdgeInsets.all(16.0),
    this.margin = const EdgeInsets.only(bottom: 16.0),
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: margin,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 卡片标题
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 12.0,
            ),
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor.withAlpha(
                (Theme.of(context).primaryColor.a * 0.1).round(),
              ),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              children: [
                if (icon != null) ...[
                  Icon(icon, size: 20, color: Theme.of(context).primaryColor),
                  const SizedBox(width: 8),
                ],
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
              ],
            ),
          ),
          // 卡片内容
          Padding(
            padding: contentPadding,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children:
                  children.map((child) {
                    // 为每个子组件添加底部间距，除了最后一个
                    if (child != children.last) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16.0),
                        child: child,
                      );
                    }
                    return child;
                  }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}
