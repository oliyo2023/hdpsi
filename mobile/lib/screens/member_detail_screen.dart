import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/member.dart';
import '../controllers/member_controller.dart';
import '../utils/app_theme.dart';
import '../utils/formatters.dart';
import '../widgets/loading_indicator.dart';
import '../widgets/error_display.dart';

class MemberDetailScreen extends StatefulWidget {
  final int memberId;

  const MemberDetailScreen({super.key, required this.memberId});

  @override
  State<MemberDetailScreen> createState() => _MemberDetailScreenState();
}

class _MemberDetailScreenState extends State<MemberDetailScreen> {
  // 使用GetX获取控制器
  final MemberController _memberController = Get.find<MemberController>();

  @override
  void initState() {
    super.initState();
    // 加载会员详情
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _memberController.getMember(widget.memberId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('会员详情'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              // 导航到编辑页面
              Navigator.of(
                context,
              ).pushNamed('/members/edit', arguments: widget.memberId);
            },
          ),
        ],
      ),
      body: Obx(() {
        if (_memberController.isLoading) {
          return const LoadingIndicator(message: '加载会员信息...');
        }

        if (_memberController.error != null) {
          return ErrorDisplay(
            error: _memberController.error!,
            onRetry: () => _memberController.getMember(widget.memberId),
          );
        }

        final member = _memberController.selectedMember;
        if (member == null) {
          return const Center(child: Text('未找到会员信息'));
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildMemberHeader(member),
              const SizedBox(height: 24.0),
              _buildInfoSection('基本信息', _buildBasicInfo(member)),
              const SizedBox(height: 16.0),
              _buildInfoSection('体型数据', _buildBodyInfo(member)),
              const SizedBox(height: 16.0),
              _buildInfoSection('偏好信息', _buildPreferenceInfo(member)),
              const SizedBox(height: 16.0),
              _buildInfoSection('备注', _buildNoteInfo(member)),
              const SizedBox(height: 24.0),
              _buildActionButtons(context, member),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildMemberHeader(Member member) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTheme.borderRadius),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            CircleAvatar(
              radius: 40,
              backgroundColor: _getLevelColor(member.level).withAlpha(51),
              child: Text(
                member.name.isNotEmpty ? member.name[0] : '?',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: _getLevelColor(member.level),
                ),
              ),
            ),
            const SizedBox(width: 16.0),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    member.name,
                    style: const TextStyle(
                      fontSize: 24.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8.0),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8.0,
                          vertical: 2.0,
                        ),
                        decoration: BoxDecoration(
                          color: _getLevelColor(member.level).withAlpha(51),
                          borderRadius: BorderRadius.circular(4.0),
                        ),
                        child: Text(
                          Formatters.formatMemberLevel(member.level),
                          style: TextStyle(
                            fontSize: 14.0,
                            fontWeight: FontWeight.bold,
                            color: _getLevelColor(member.level),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8.0),
                      Text(
                        '积分: ${member.points}',
                        style: const TextStyle(
                          fontSize: 14.0,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8.0),
                  Text(
                    '累计消费: ¥${member.totalSpent.toStringAsFixed(2)}',
                    style: const TextStyle(fontSize: 14.0),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoSection(String title, Widget content) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTheme.borderRadius),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 18.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Divider(),
            const SizedBox(height: 8.0),
            content,
          ],
        ),
      ),
    );
  }

  Widget _buildBasicInfo(Member member) {
    return Column(
      children: [
        _buildInfoRow('手机号码', member.phone),
        _buildInfoRow('性别', _formatGender(member.gender)),
        _buildInfoRow('生日', member.birthday ?? '未设置'),
        _buildInfoRow('邮箱', member.email.isNotEmpty ? member.email : '未设置'),
        _buildInfoRow('地址', member.address.isNotEmpty ? member.address : '未设置'),
        _buildInfoRow('最近购买', member.lastPurchaseDate ?? '无购买记录'),
        _buildInfoRow('创建时间', Formatters.formatDateTime(member.createdAt)),
      ],
    );
  }

  Widget _buildBodyInfo(Member member) {
    bool hasBodyData =
        member.bodyHeight != null ||
        member.bodyWeight != null ||
        member.shoulderWidth != null ||
        member.bustSize != null ||
        member.waistSize != null ||
        member.hipSize != null ||
        member.inseam != null;

    if (!hasBodyData) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 16.0),
          child: Text('暂无体型数据'),
        ),
      );
    }

    return Column(
      children: [
        _buildInfoRow(
          '身高',
          member.bodyHeight != null ? '${member.bodyHeight} cm' : '未设置',
        ),
        _buildInfoRow(
          '体重',
          member.bodyWeight != null ? '${member.bodyWeight} kg' : '未设置',
        ),
        _buildInfoRow(
          '肩宽',
          member.shoulderWidth != null ? '${member.shoulderWidth} cm' : '未设置',
        ),
        _buildInfoRow(
          '胸围',
          member.bustSize != null ? '${member.bustSize} cm' : '未设置',
        ),
        _buildInfoRow(
          '腰围',
          member.waistSize != null ? '${member.waistSize} cm' : '未设置',
        ),
        _buildInfoRow(
          '臀围',
          member.hipSize != null ? '${member.hipSize} cm' : '未设置',
        ),
        _buildInfoRow(
          '内侧缝',
          member.inseam != null ? '${member.inseam} cm' : '未设置',
        ),
      ],
    );
  }

  Widget _buildPreferenceInfo(Member member) {
    bool hasPreferenceData =
        member.stylePreference != null ||
        member.favoriteColors != null ||
        member.favoriteCategories != null ||
        member.consumptionLevel != null;

    if (!hasPreferenceData) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 16.0),
          child: Text('暂无偏好数据'),
        ),
      );
    }

    return Column(
      children: [
        _buildInfoRow('风格偏好', member.stylePreference ?? '未设置'),
        _buildInfoRow('喜爱颜色', member.favoriteColors ?? '未设置'),
        _buildInfoRow('喜爱类别', member.favoriteCategories ?? '未设置'),
        _buildInfoRow('消费水平', member.consumptionLevel ?? '未设置'),
      ],
    );
  }

  Widget _buildNoteInfo(Member member) {
    if (member.note.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 16.0),
          child: Text('暂无备注'),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Text(member.note),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: TextStyle(fontSize: 14.0, color: Colors.grey[600]),
            ),
          ),
          Expanded(child: Text(value, style: const TextStyle(fontSize: 14.0))),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context, Member member) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        ElevatedButton.icon(
          icon: const Icon(Icons.add_shopping_cart),
          label: const Text('添加消费'),
          onPressed: () => _showAddConsumptionDialog(context, member),
        ),
        ElevatedButton.icon(
          icon: const Icon(Icons.history),
          label: const Text('消费记录'),
          onPressed: () {
            Navigator.of(
              context,
            ).pushNamed('/members/transactions', arguments: member.id);
          },
        ),
      ],
    );
  }

  String _formatGender(String gender) {
    switch (gender.toLowerCase()) {
      case 'male':
        return '男';
      case 'female':
        return '女';
      default:
        return gender.isEmpty ? '未设置' : gender;
    }
  }

  Color _getLevelColor(String level) {
    switch (level) {
      case 'regular':
        return Colors.blue;
      case 'silver':
        return Colors.blueGrey;
      case 'gold':
        return Colors.amber;
      case 'platinum':
        return Colors.teal;
      case 'diamond':
        return Colors.purple;
      default:
        return Colors.blue;
    }
  }

  // 显示添加消费记录对话框
  void _showAddConsumptionDialog(BuildContext context, Member member) {
    final TextEditingController amountController = TextEditingController();
    final TextEditingController noteController = TextEditingController();
    String selectedType = 'purchase'; // 默认为购买类型

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('添加消费记录'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // 消费金额
                    TextField(
                      controller: amountController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: '消费金额',
                        prefixText: '¥',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // 消费类型
                    DropdownButtonFormField<String>(
                      value: selectedType,
                      decoration: const InputDecoration(
                        labelText: '消费类型',
                        border: OutlineInputBorder(),
                      ),
                      items: const [
                        DropdownMenuItem(
                          value: 'purchase',
                          child: Text('购买商品'),
                        ),
                        DropdownMenuItem(value: 'service', child: Text('服务消费')),
                        DropdownMenuItem(value: 'other', child: Text('其他消费')),
                      ],
                      onChanged: (value) {
                        setState(() {
                          selectedType = value!;
                        });
                      },
                    ),
                    const SizedBox(height: 16),

                    // 备注
                    TextField(
                      controller: noteController,
                      maxLines: 3,
                      decoration: const InputDecoration(
                        labelText: '备注',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('取消'),
                ),
                ElevatedButton(
                  onPressed:
                      () => _addConsumptionRecord(
                        context,
                        member,
                        amountController.text,
                        selectedType,
                        noteController.text,
                      ),
                  child: const Text('确认'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // 添加消费记录
  void _addConsumptionRecord(
    BuildContext context,
    Member member,
    String amount,
    String type,
    String note,
  ) async {
    if (amount.isEmpty) {
      Get.snackbar('错误', '请输入消费金额');
      return;
    }

    try {
      final double consumptionAmount = double.parse(amount);
      if (consumptionAmount <= 0) {
        Get.snackbar('错误', '消费金额必须大于0');
        return;
      }

      // 计算积分（假设每消费1元获得1积分）
      final int earnedPoints = consumptionAmount.round();

      // 调用正确的积分添加API - 使用 /api/members/{id}/points/add 路由
      final success = await _memberController.addMemberPoints(
        member.id,
        earnedPoints,
        type,
        note.isEmpty ? '消费获得积分' : note,
      );

      Get.back(); // 关闭对话框

      if (success) {
        Get.snackbar('成功', '消费记录添加成功，获得 $earnedPoints 积分');
      } else {
        Get.snackbar('失败', '添加消费记录失败: ${_memberController.error}');
      }
    } catch (e) {
      Get.back(); // 关闭对话框
      Get.snackbar('错误', '添加消费记录失败: $e');
    }
  }
}
