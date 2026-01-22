import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:intl/intl.dart';
import '../models/member.dart';
import '../controllers/member_controller.dart';
import '../utils/validators.dart';
import '../widgets/loading_indicator.dart';
import '../widgets/error_display.dart';

class MemberEditScreen extends StatefulWidget {
  final int memberId;

  const MemberEditScreen({super.key, required this.memberId});

  @override
  State<MemberEditScreen> createState() => _MemberEditScreenState();
}

class _MemberEditScreenState extends State<MemberEditScreen> {
  final _formKey = GlobalKey<FormBuilderState>();
  bool _isBasicInfoExpanded = true;
  bool _isBodyInfoExpanded = false;
  bool _isPreferenceExpanded = false;
  bool _isLoading = true;
  String? _error;

  late final MemberController _memberController;

  @override
  void initState() {
    super.initState();
    // 获取MemberController实例
    _memberController = Get.find<MemberController>();
    // 加载会员详情
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadMemberData();
    });
  }

  Future<void> _loadMemberData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      await _memberController.getMember(widget.memberId);
    } catch (e) {
      setState(() {
        _error = '加载会员信息失败: ${e.toString()}';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('编辑会员')),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    // 处理本地加载状态
    if (_isLoading) {
      return const LoadingIndicator(message: '加载会员信息...');
    }

    // 处理本地错误状态
    if (_error != null) {
      return ErrorDisplay(error: _error!, onRetry: _loadMemberData);
    }

    // 使用 Obx 只观察 GetX 的可观察变量
    return Obx(() {
      if (_memberController.isLoading) {
        return const LoadingIndicator(message: '处理中...');
      }

      if (_memberController.error != null) {
        return ErrorDisplay(
          error: _memberController.error!,
          onRetry: _loadMemberData,
        );
      }

      final member = _memberController.selectedMember;
      if (member == null) {
        return const Center(child: Text('未找到会员信息'));
      }

      return SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: FormBuilder(
          key: _formKey,
          initialValue: _getInitialValues(member),
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
                    items: const [
                      DropdownMenuItem(value: 'regular', child: Text('普通会员')),
                      DropdownMenuItem(value: 'silver', child: Text('白银会员')),
                      DropdownMenuItem(value: 'gold', child: Text('黄金会员')),
                      DropdownMenuItem(value: 'platinum', child: Text('铂金会员')),
                      DropdownMenuItem(value: 'diamond', child: Text('钻石会员')),
                    ],
                  ),
                  const SizedBox(height: 16.0),

                  // 积分
                  FormBuilderTextField(
                    name: 'points',
                    decoration: const InputDecoration(
                      labelText: '积分',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    validator:
                        (value) => Validators.validateNumber(value, '积分'),
                    enabled: false, // 积分不允许直接编辑
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
                      DropdownMenuItem(value: 'sportswear', child: Text('运动')),
                      DropdownMenuItem(value: 'vintage', child: Text('复古')),
                      DropdownMenuItem(value: 'minimalist', child: Text('极简')),
                      DropdownMenuItem(value: 'romantic', child: Text('浪漫')),
                      DropdownMenuItem(value: 'bohemian', child: Text('波西米亚')),
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
              if (_memberController.error != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: Text(
                    _memberController.error!,
                    style: const TextStyle(color: Colors.red, fontSize: 14),
                    textAlign: TextAlign.center,
                  ),
                ),

              // 提交按钮
              SizedBox(
                height: 50,
                child: ElevatedButton(
                  onPressed: _memberController.isLoading ? null : _submitForm,
                  child:
                      _memberController.isLoading
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
    });
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

  Map<String, dynamic> _getInitialValues(Member member) {
    // 将会员数据转换为表单初始值
    final initialValues = <String, dynamic>{
      'name': member.name,
      'phone': member.phone,
      'gender': _formatGender(member.gender),
      'email': member.email,
      'address': member.address,
      'level': member.level,
      'points': member.points.toString(),
      'note': member.note,
    };

    // 处理生日
    if (member.birthday != null && member.birthday!.isNotEmpty) {
      try {
        initialValues['birthday'] = DateTime.parse(member.birthday!);
      } catch (e) {
        // 如果日期解析失败，不设置初始值
      }
    }

    // 处理体型数据
    if (member.bodyHeight != null) {
      initialValues['bodyHeight'] = member.bodyHeight.toString();
    }
    if (member.bodyWeight != null) {
      initialValues['bodyWeight'] = member.bodyWeight.toString();
    }
    if (member.shoulderWidth != null) {
      initialValues['shoulderWidth'] = member.shoulderWidth.toString();
    }
    if (member.bustSize != null) {
      initialValues['bustSize'] = member.bustSize.toString();
    }
    if (member.waistSize != null) {
      initialValues['waistSize'] = member.waistSize.toString();
    }
    if (member.hipSize != null) {
      initialValues['hipSize'] = member.hipSize.toString();
    }
    if (member.inseam != null) {
      initialValues['inseam'] = member.inseam.toString();
    }

    // 处理偏好数据
    if (member.stylePreference != null) {
      initialValues['stylePreference'] = member.stylePreference;
    }
    if (member.favoriteColors != null) {
      initialValues['favoriteColors'] = member.favoriteColors;
    }
    if (member.favoriteCategories != null) {
      initialValues['favoriteCategories'] = member.favoriteCategories;
    }
    if (member.consumptionLevel != null) {
      initialValues['consumptionLevel'] = member.consumptionLevel;
    }

    return initialValues;
  }

  String _formatGender(String gender) {
    // 将后端的性别格式转换为前端显示格式
    switch (gender.toLowerCase()) {
      case 'male':
        return '男';
      case 'female':
        return '女';
      default:
        return gender;
    }
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.saveAndValidate()) {
      // 创建可修改的表单数据副本
      final formData = Map<String, dynamic>.from(_formKey.currentState!.value);

      // 处理日期格式 - 转换为 YYYY-MM-DD 格式以适配 Golang 后端
      if (formData['birthday'] != null && formData['birthday'] is DateTime) {
        final birthday = formData['birthday'] as DateTime;
        formData['birthday'] = DateFormat('yyyy-MM-dd').format(birthday);
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

      // 移除积分字段，因为积分不允许直接编辑
      formData.remove('points');

      final success = await _memberController.updateMember(
        widget.memberId,
        formData,
      );

      if (success && mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('会员信息更新成功')));
        Navigator.of(context).pop();
      }
    }
  }
}
