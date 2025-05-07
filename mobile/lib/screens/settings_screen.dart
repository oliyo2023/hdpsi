import 'package:flutter/material.dart';
import '../utils/config.dart';
import '../utils/app_theme.dart';
import '../widgets/animated_header.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _apiUrlController = TextEditingController();
  String _selectedEnvironment = 'dev'; // 默认选择开发环境
  bool _isCustomUrl = false;

  @override
  void initState() {
    super.initState();
    _apiUrlController.text = AppConfig.apiBaseUrl;
    
    // 检查当前URL是否是预定义环境中的一个
    for (var entry in AppConfig.environments.entries) {
      if (entry.value == AppConfig.apiBaseUrl) {
        _selectedEnvironment = entry.key;
        _isCustomUrl = false;
        break;
      }
    }
    
    // 如果不是预定义环境，则是自定义URL
    if (AppConfig.apiBaseUrl != AppConfig.environments[_selectedEnvironment]) {
      _isCustomUrl = true;
    }
  }

  @override
  void dispose() {
    _apiUrlController.dispose();
    super.dispose();
  }

  void _saveSettings() {
    if (_isCustomUrl) {
      // 保存自定义URL
      AppConfig.setApiBaseUrl(_apiUrlController.text);
    } else {
      // 保存预定义环境
      AppConfig.setEnvironment(_selectedEnvironment);
      // 更新文本框显示
      _apiUrlController.text = AppConfig.apiBaseUrl;
    }
    
    // 显示保存成功提示
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('设置已保存')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // 动画顶部
          const AnimatedHeader(title: '设置', height: 120.0),
          
          // 设置内容
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppTheme.spacingMedium),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // API服务器设置卡片
                  Card(
                    margin: const EdgeInsets.only(bottom: AppTheme.spacingMedium),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppTheme.borderRadius),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(AppTheme.spacingMedium),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'API服务器设置',
                            style: TextStyle(
                              fontSize: AppTheme.fontSizeLarge,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: AppTheme.spacing),
                          const Text(
                            '选择预定义环境或输入自定义API服务器地址',
                            style: TextStyle(
                              fontSize: AppTheme.fontSizeNormal,
                              color: Colors.grey,
                            ),
                          ),
                          const SizedBox(height: AppTheme.spacingMedium),
                          
                          // 环境选择
                          const Text(
                            '环境',
                            style: TextStyle(
                              fontSize: AppTheme.fontSizeNormal,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: AppTheme.spacing),
                          
                          // 环境选择单选按钮组
                          Wrap(
                            spacing: AppTheme.spacing,
                            children: [
                              _buildEnvironmentChip('本地', 'local'),
                              _buildEnvironmentChip('开发', 'dev'),
                              _buildEnvironmentChip('测试', 'test'),
                              _buildEnvironmentChip('生产', 'prod'),
                              _buildEnvironmentChip('自定义', 'custom'),
                            ],
                          ),
                          
                          const SizedBox(height: AppTheme.spacingMedium),
                          
                          // 自定义URL输入框
                          TextField(
                            controller: _apiUrlController,
                            decoration: InputDecoration(
                              labelText: 'API服务器地址',
                              hintText: 'http://example.com',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(AppTheme.borderRadius),
                              ),
                              enabled: _isCustomUrl,
                            ),
                          ),
                          
                          const SizedBox(height: AppTheme.spacingMedium),
                          
                          // 保存按钮
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: _saveSettings,
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(AppTheme.borderRadius),
                                ),
                              ),
                              child: const Text('保存设置'),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                  // 当前配置信息卡片
                  Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppTheme.borderRadius),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(AppTheme.spacingMedium),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            '当前配置',
                            style: TextStyle(
                              fontSize: AppTheme.fontSizeLarge,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: AppTheme.spacingMedium),
                          
                          // 当前API地址
                          _buildInfoRow('API服务器地址', AppConfig.apiBaseUrl),
                          
                          // 应用版本
                          _buildInfoRow('应用版本', AppConfig.appVersion),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 构建环境选择芯片
  Widget _buildEnvironmentChip(String label, String value) {
    final isSelected = _isCustomUrl ? value == 'custom' : _selectedEnvironment == value;
    
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          if (value == 'custom') {
            _isCustomUrl = true;
          } else {
            _selectedEnvironment = value;
            _isCustomUrl = false;
            // 更新文本框显示预定义环境的URL
            _apiUrlController.text = AppConfig.environments[value] ?? '';
          }
        });
      },
    );
  }

  // 构建信息行
  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppTheme.spacing),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: AppTheme.fontSizeNormal,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: AppTheme.fontSizeNormal,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
