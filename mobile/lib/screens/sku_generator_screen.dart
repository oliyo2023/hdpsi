import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../utils/sku_generator.dart';
import '../utils/app_theme.dart';

class SkuGeneratorScreen extends StatefulWidget {
  const SkuGeneratorScreen({super.key});

  @override
  State<SkuGeneratorScreen> createState() => _SkuGeneratorScreenState();
}

class _SkuGeneratorScreenState extends State<SkuGeneratorScreen> {
  final _formKey = GlobalKey<FormState>();

  // 表单数据
  String _categoryCode = '';
  int _year = DateTime.now().year;
  String _season = 'all';
  String _colorCode = '';
  String _sizeCode = '';

  // 生成的SKU
  String? _generatedSku;

  // 季节选项
  final List<Map<String, String>> _seasonOptions = [
    {'value': 'spring', 'label': '春季 (S)'},
    {'value': 'summer', 'label': '夏季 (X)'},
    {'value': 'autumn', 'label': '秋季 (Q)'},
    {'value': 'winter', 'label': '冬季 (D)'},
    {'value': 'all', 'label': '四季 (A)'},
  ];

  // 生成SKU
  void _generateSku() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      try {
        final sku = SkuGenerator.generateSku(
          categoryCode: _categoryCode,
          year: _year,
          season: _season,
          colorCode: _colorCode,
          sizeCode: _sizeCode,
        );

        setState(() {
          _generatedSku = sku;
        });
      } catch (e) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('生成SKU失败: ${e.toString()}')));
      }
    }
  }

  // 复制SKU到剪贴板
  void _copySku() {
    if (_generatedSku != null) {
      Clipboard.setData(ClipboardData(text: _generatedSku!));
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('SKU已复制到剪贴板')));
    }
  }

  // 重置表单
  void _resetForm() {
    _formKey.currentState?.reset();
    setState(() {
      _categoryCode = '';
      _year = DateTime.now().year;
      _season = 'all';
      _colorCode = '';
      _sizeCode = '';
      _generatedSku = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('SKU生成器')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppTheme.spacingMedium),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 说明卡片
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
                      Row(
                        children: [
                          Icon(
                            Icons.info_outline,
                            color: AppTheme.primaryColor,
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            'SKU编码规则',
                            style: TextStyle(
                              fontSize: AppTheme.fontSizeMedium,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        '品类(2位) + 年份(2位) + 季节(1位) + 颜色(3位) + 尺码(2位)',
                        style: TextStyle(fontSize: AppTheme.fontSizeNormal),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        '例如: FD23SRED01 表示 女装(FD)2023年春季(S)红色(RED)01号尺码',
                        style: TextStyle(
                          fontSize: AppTheme.fontSizeSmall,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // 表单卡片
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppTheme.borderRadius),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(AppTheme.spacingMedium),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 品类代码
                      TextFormField(
                        decoration: const InputDecoration(
                          labelText: '品类代码 (2位)',
                          hintText: '例如: FD (女装)',
                          helperText: '男装: MD, 女装: FD, 童装: CD, 内衣: UW',
                        ),
                        maxLength: 2,
                        textCapitalization: TextCapitalization.characters,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return '请输入品类代码';
                          }
                          if (value.length != 2) {
                            return '品类代码必须为2位字符';
                          }
                          return null;
                        },
                        onSaved: (value) {
                          _categoryCode = value ?? '';
                        },
                      ),
                      const SizedBox(height: AppTheme.spacing),

                      // 年份
                      DropdownButtonFormField<int>(
                        decoration: const InputDecoration(
                          labelText: '年份',
                          hintText: '选择年份',
                        ),
                        value: _year,
                        items: List.generate(5, (index) {
                          final year = DateTime.now().year - 2 + index;
                          return DropdownMenuItem(
                            value: year,
                            child: Text(year.toString()),
                          );
                        }),
                        onChanged: (value) {
                          setState(() {
                            _year = value ?? DateTime.now().year;
                          });
                        },
                        validator: (value) {
                          if (value == null) {
                            return '请选择年份';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: AppTheme.spacingMedium),

                      // 季节
                      DropdownButtonFormField<String>(
                        decoration: const InputDecoration(
                          labelText: '季节',
                          hintText: '选择季节',
                        ),
                        value: _season,
                        items:
                            _seasonOptions.map((option) {
                              return DropdownMenuItem(
                                value: option['value'],
                                child: Text(option['label']!),
                              );
                            }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _season = value ?? 'all';
                          });
                        },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return '请选择季节';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: AppTheme.spacingMedium),

                      // 颜色代码
                      TextFormField(
                        decoration: const InputDecoration(
                          labelText: '颜色代码 (3位)',
                          hintText: '例如: RED, BLK, WHT',
                          helperText: 'RED: 红色, BLK: 黑色, WHT: 白色, BLU: 蓝色',
                        ),
                        maxLength: 3,
                        textCapitalization: TextCapitalization.characters,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return '请输入颜色代码';
                          }
                          if (value.length != 3) {
                            return '颜色代码必须为3位字符';
                          }
                          return null;
                        },
                        onSaved: (value) {
                          _colorCode = value ?? '';
                        },
                      ),
                      const SizedBox(height: AppTheme.spacing),

                      // 尺码代码
                      TextFormField(
                        decoration: const InputDecoration(
                          labelText: '尺码代码 (2位)',
                          hintText: '例如: 01, 02, XL, 2X',
                          helperText: '01: S, 02: M, 03: L, 04: XL, 05: XXL',
                        ),
                        maxLength: 2,
                        textCapitalization: TextCapitalization.characters,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return '请输入尺码代码';
                          }
                          if (value.length != 2) {
                            return '尺码代码必须为2位字符';
                          }
                          return null;
                        },
                        onSaved: (value) {
                          _sizeCode = value ?? '';
                        },
                      ),

                      const SizedBox(height: AppTheme.spacingMedium),

                      // 按钮行
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              onPressed: _generateSku,
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                ),
                              ),
                              child: const Text('生成SKU'),
                            ),
                          ),
                          const SizedBox(width: AppTheme.spacing),
                          OutlinedButton(
                            onPressed: _resetForm,
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                            child: const Text('重置'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              // 生成的SKU结果
              if (_generatedSku != null) ...[
                const SizedBox(height: AppTheme.spacingMedium),
                Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppTheme.borderRadius),
                  ),
                  color: AppTheme.primaryColor.withAlpha(30),
                  child: Padding(
                    padding: const EdgeInsets.all(AppTheme.spacingMedium),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          '生成的SKU编码',
                          style: TextStyle(
                            fontSize: AppTheme.fontSizeMedium,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: AppTheme.spacing),
                        Row(
                          children: [
                            Expanded(
                              child: Container(
                                padding: const EdgeInsets.all(AppTheme.spacing),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(
                                    AppTheme.borderRadius / 2,
                                  ),
                                  border: Border.all(
                                    color: AppTheme.primaryColor.withAlpha(100),
                                  ),
                                ),
                                child: Text(
                                  _generatedSku!,
                                  style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: AppTheme.primaryColor,
                                    letterSpacing: 1.5,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                            const SizedBox(width: AppTheme.spacing),
                            IconButton(
                              onPressed: _copySku,
                              icon: const Icon(Icons.copy),
                              tooltip: '复制到剪贴板',
                              color: AppTheme.primaryColor,
                            ),
                          ],
                        ),
                        const SizedBox(height: AppTheme.spacing),
                        // SKU解析
                        ..._buildSkuAnalysis(_generatedSku!),
                      ],
                    ),
                  ),
                ),
              ],

              // 底部空白
              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
    );
  }

  // 构建SKU解析结果
  List<Widget> _buildSkuAnalysis(String sku) {
    try {
      final parts = SkuGenerator.parseSku(sku);

      return [
        const Text(
          'SKU解析:',
          style: TextStyle(
            fontSize: AppTheme.fontSizeNormal,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        _buildAnalysisItem('品类', parts['categoryCode']!),
        _buildAnalysisItem('年份', parts['year']!),
        _buildAnalysisItem('季节', parts['season']!),
        _buildAnalysisItem('颜色', parts['colorCode']!),
        _buildAnalysisItem('尺码', parts['sizeCode']!),
      ];
    } catch (e) {
      return [
        Text(
          '解析失败: ${e.toString()}',
          style: const TextStyle(color: Colors.red),
        ),
      ];
    }
  }

  // 构建解析项
  Widget _buildAnalysisItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 2),
      child: Row(
        children: [
          SizedBox(
            width: 60,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: AppTheme.fontSizeSmall,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: AppTheme.fontSizeNormal),
            ),
          ),
        ],
      ),
    );
  }
}
