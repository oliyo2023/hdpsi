import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:intl/intl.dart';
import '../providers/member_provider.dart';
import '../utils/validators.dart';

class MemberAddScreen extends StatefulWidget {
  const MemberAddScreen({super.key});

  @override
  State<MemberAddScreen> createState() => _MemberAddScreenState();
}

class _MemberAddScreenState extends State<MemberAddScreen> {
  final _formKey = GlobalKey<FormBuilderState>();
  bool _isBasicInfoExpanded = true;
  bool _isBodyInfoExpanded = false;
  bool _isPreferenceExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('添加会员')),
      body: Consumer<MemberProvider>(
        builder: (context, memberProvider, child) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: FormBuilder(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // 基本信息
                  _buildExpandableSection(
                    title: '基本信息',
                    isExpanded: _isBasicInfoExpanded,
                    onExpansionChanged: (value) {
                      setState(() {
                        _isBasicInfoExpanded = value;
                      });
                    },
                    children: [
                      // 姓名
                      FormBuilderTextField(
                        name: 'name',
                        decoration: const InputDecoration(
                          labelText: '姓名',
                          border: OutlineInputBorder(),
                        ),
                        validator: FormBuilderValidators.compose([
                          FormBuilderValidators.required(errorText: '请输入姓名'),
                        ]),
                      ),
                      const SizedBox(height: 16.0),

                      // 手机号
                      FormBuilderTextField(
                        name: 'phone',
                        decoration: const InputDecoration(
                          labelText: '手机号',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.phone,
                        validator: (value) => Validators.validatePhone(value),
                      ),
                      const SizedBox(height: 16.0),

                      // 性别
                      FormBuilderDropdown<String>(
                        name: 'gender',
                        decoration: const InputDecoration(
                          labelText: '性别',
                          border: OutlineInputBorder(),
                        ),
                        items: const [
                          DropdownMenuItem(value: '男', child: Text('男')),
                          DropdownMenuItem(value: '女', child: Text('女')),
                        ],
                      ),
                      const SizedBox(height: 16.0),

                      // 生日
                      FormBuilderDateTimePicker(
                        name: 'birthday',
                        inputType: InputType.date,
                        decoration: const InputDecoration(
                          labelText: '生日',
                          border: OutlineInputBorder(),
                          suffixIcon: Icon(Icons.calendar_today),
                        ),
                        format: DateFormat('yyyy-MM-dd'),
                      ),
                      const SizedBox(height: 16.0),

                      // 邮箱
                      FormBuilderTextField(
                        name: 'email',
                        decoration: const InputDecoration(
                          labelText: '邮箱',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.emailAddress,
                        validator: (value) => Validators.validateEmail(value),
                      ),
                      const SizedBox(height: 16.0),

                      // 地址
                      FormBuilderTextField(
                        name: 'address',
                        decoration: const InputDecoration(
                          labelText: '地址',
                          border: OutlineInputBorder(),
                        ),
                        maxLines: 2,
                      ),
                      const SizedBox(height: 16.0),

                      // 会员等级
                      FormBuilderDropdown<String>(
                        name: 'level',
                        decoration: const InputDecoration(
                          labelText: '会员等级',
                          border: OutlineInputBorder(),
                        ),
                        initialValue: 'regular',
                        items: const [
                          DropdownMenuItem(
                            value: 'regular',
                            child: Text('普通会员'),
                          ),
                          DropdownMenuItem(
                            value: 'silver',
                            child: Text('白银会员'),
                          ),
                          DropdownMenuItem(value: 'gold', child: Text('黄金会员')),
                          DropdownMenuItem(
                            value: 'platinum',
                            child: Text('铂金会员'),
                          ),
                          DropdownMenuItem(
                            value: 'diamond',
                            child: Text('钻石会员'),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 16.0),

                  // 体型信息
                  _buildExpandableSection(
                    title: '体型信息',
                    isExpanded: _isBodyInfoExpanded,
                    onExpansionChanged: (value) {
                      setState(() {
                        _isBodyInfoExpanded = value;
                      });
                    },
                    children: [
                      // 身高
                      FormBuilderTextField(
                        name: 'bodyHeight',
                        decoration: const InputDecoration(
                          labelText: '身高 (cm)',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                        validator:
                            (value) => Validators.validateNumber(value, '身高'),
                      ),
                      const SizedBox(height: 16.0),

                      // 体重
                      FormBuilderTextField(
                        name: 'bodyWeight',
                        decoration: const InputDecoration(
                          labelText: '体重 (kg)',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                        validator:
                            (value) => Validators.validateNumber(value, '体重'),
                      ),
                      const SizedBox(height: 16.0),

                      // 肩宽
                      FormBuilderTextField(
                        name: 'shoulderWidth',
                        decoration: const InputDecoration(
                          labelText: '肩宽 (cm)',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                        validator:
                            (value) => Validators.validateNumber(value, '肩宽'),
                      ),
                      const SizedBox(height: 16.0),

                      // 胸围
                      FormBuilderTextField(
                        name: 'bustSize',
                        decoration: const InputDecoration(
                          labelText: '胸围 (cm)',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                        validator:
                            (value) => Validators.validateNumber(value, '胸围'),
                      ),
                      const SizedBox(height: 16.0),

                      // 腰围
                      FormBuilderTextField(
                        name: 'waistSize',
                        decoration: const InputDecoration(
                          labelText: '腰围 (cm)',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                        validator:
                            (value) => Validators.validateNumber(value, '腰围'),
                      ),
                      const SizedBox(height: 16.0),

                      // 臀围
                      FormBuilderTextField(
                        name: 'hipSize',
                        decoration: const InputDecoration(
                          labelText: '臀围 (cm)',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                        validator:
                            (value) => Validators.validateNumber(value, '臀围'),
                      ),
                      const SizedBox(height: 16.0),

                      // 内缝长度
                      FormBuilderTextField(
                        name: 'inseam',
                        decoration: const InputDecoration(
                          labelText: '内缝长度 (cm)',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                        validator:
                            (value) => Validators.validateNumber(value, '内缝长度'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16.0),

                  // 偏好信息
                  _buildExpandableSection(
                    title: '偏好信息',
                    isExpanded: _isPreferenceExpanded,
                    onExpansionChanged: (value) {
                      setState(() {
                        _isPreferenceExpanded = value;
                      });
                    },
                    children: [
                      // 风格偏好
                      FormBuilderDropdown<String>(
                        name: 'stylePreference',
                        decoration: const InputDecoration(
                          labelText: '风格偏好',
                          border: OutlineInputBorder(),
                        ),
                        items: const [
                          DropdownMenuItem(value: 'casual', child: Text('休闲')),
                          DropdownMenuItem(value: 'formal', child: Text('正式')),
                          DropdownMenuItem(
                            value: 'sportswear',
                            child: Text('运动'),
                          ),
                          DropdownMenuItem(value: 'vintage', child: Text('复古')),
                          DropdownMenuItem(
                            value: 'minimalist',
                            child: Text('极简'),
                          ),
                          DropdownMenuItem(
                            value: 'romantic',
                            child: Text('浪漫'),
                          ),
                          DropdownMenuItem(
                            value: 'bohemian',
                            child: Text('波西米亚'),
                          ),
                          DropdownMenuItem(value: 'street', child: Text('街头')),
                        ],
                      ),
                      const SizedBox(height: 16.0),

                      // 喜欢的颜色
                      FormBuilderTextField(
                        name: 'favoriteColors',
                        decoration: const InputDecoration(
                          labelText: '喜欢的颜色（用逗号分隔）',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 16.0),

                      // 喜欢的品类
                      FormBuilderTextField(
                        name: 'favoriteCategories',
                        decoration: const InputDecoration(
                          labelText: '喜欢的品类（用逗号分隔）',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 16.0),

                      // 消费能力
                      FormBuilderDropdown<String>(
                        name: 'consumptionLevel',
                        decoration: const InputDecoration(
                          labelText: '消费能力',
                          border: OutlineInputBorder(),
                        ),
                        items: const [
                          DropdownMenuItem(value: 'low', child: Text('低')),
                          DropdownMenuItem(value: 'medium', child: Text('中')),
                          DropdownMenuItem(value: 'high', child: Text('高')),
                          DropdownMenuItem(value: 'luxury', child: Text('奢侈')),
                        ],
                      ),
                      const SizedBox(height: 16.0),

                      // 备注
                      FormBuilderTextField(
                        name: 'note',
                        decoration: const InputDecoration(
                          labelText: '备注',
                          border: OutlineInputBorder(),
                        ),
                        maxLines: 3,
                      ),
                    ],
                  ),
                  const SizedBox(height: 24.0),

                  // 错误信息
                  if (memberProvider.error != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16.0),
                      child: Text(
                        memberProvider.error!,
                        style: const TextStyle(color: Colors.red, fontSize: 14),
                        textAlign: TextAlign.center,
                      ),
                    ),

                  // 提交按钮
                  SizedBox(
                    height: 50,
                    child: ElevatedButton(
                      onPressed: memberProvider.isLoading ? null : _submitForm,
                      child:
                          memberProvider.isLoading
                              ? const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                              : const Text(
                                '保存会员信息',
                                style: TextStyle(fontSize: 16),
                              ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildExpandableSection({
    required String title,
    required bool isExpanded,
    required ValueChanged<bool> onExpansionChanged,
    required List<Widget> children,
  }) {
    return Card(
      child: ExpansionTile(
        title: Text(
          title,
          style: const TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
        ),
        initiallyExpanded: isExpanded,
        onExpansionChanged: onExpansionChanged,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: children,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.saveAndValidate()) {
      final formData = _formKey.currentState!.value;

      // 处理日期格式
      if (formData['birthday'] != null && formData['birthday'] is DateTime) {
        formData['birthday'] =
            (formData['birthday'] as DateTime).toIso8601String();
      }

      // 转换数字字段
      final numericFields = [
        'bodyHeight',
        'bodyWeight',
        'shoulderWidth',
        'bustSize',
        'waistSize',
        'hipSize',
        'inseam',
      ];

      for (final field in numericFields) {
        if (formData[field] != null && formData[field].toString().isNotEmpty) {
          formData[field] = int.parse(formData[field].toString());
        } else {
          formData[field] = null;
        }
      }

      final success = await Provider.of<MemberProvider>(
        context,
        listen: false,
      ).createMember(formData);

      if (success && mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('会员创建成功')));
        Navigator.of(context).pop();
      }
    }
  }
}
