import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// 隐私政策页面
/// 展示应用的隐私政策和数据使用说明
class PrivacyPolicyPage extends StatelessWidget {
  const PrivacyPolicyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('隐私政策'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSection(
              title: '宏店隐私政策',
              content: '''
感谢您使用宏店应用！本隐私政策说明了我们如何收集、使用、存储和保护您的个人信息。

生效日期：2025年5月25日
最后更新：2025年5月25日

宏达服装有限公司（以下简称"我们"）非常重视您的隐私保护。请仔细阅读本隐私政策，了解我们如何处理您的个人信息。
''',
            ),
            _buildSection(
              title: '1. 信息收集',
              content: '''
我们可能收集以下类型的信息：

1.1 账户信息
• 用户名、密码
• 联系方式（电话、邮箱）
• 员工工号、角色权限

1.2 业务数据
• 商品信息（名称、价格、库存等）
• 销售记录和订单信息
• 供应商和客户信息
• 库存变动记录

1.3 设备信息
• 设备型号、操作系统版本
• 应用版本信息
• 网络连接状态

1.4 使用数据
• 应用使用统计
• 功能使用频率
• 错误日志和崩溃报告
''',
            ),
            _buildSection(
              title: '2. 信息使用',
              content: '''
我们使用收集的信息用于：

2.1 核心功能
• 提供进销存管理服务
• 处理商品和订单信息
• 生成业务报表和统计

2.2 服务改进
• 优化应用性能
• 修复软件错误
• 开发新功能

2.3 安全保障
• 验证用户身份
• 防止欺诈行为
• 保护数据安全

2.4 客户支持
• 响应用户咨询
• 提供技术支持
• 处理投诉建议
''',
            ),
            _buildSection(
              title: '3. 权限说明',
              content: '''
宏店需要以下权限来提供完整的服务：

3.1 相机权限
• 用途：扫描商品条码、拍摄商品图片
• 说明：仅在您主动使用扫码或拍照功能时访问
• 数据处理：图片仅用于商品管理，不会上传到第三方

3.2 存储权限
• 用途：保存应用数据、缓存图片、导出报表
• 说明：确保应用正常运行和数据持久化
• 数据处理：仅访问应用相关文件夹

3.3 网络权限
• 用途：数据同步、在线更新、云端备份
• 说明：连接公司服务器进行数据交换
• 数据处理：使用加密传输保护数据安全

3.4 相册权限
• 用途：选择商品图片、上传产品照片
• 说明：仅在您选择图片时访问
• 数据处理：选中的图片仅用于商品信息完善
''',
            ),
            _buildSection(
              title: '4. 数据存储与安全',
              content: '''
4.1 数据存储
• 本地数据：存储在设备安全存储区域
• 云端数据：存储在公司自有服务器
• 备份数据：定期备份确保数据安全

4.2 安全措施
• 数据加密：传输和存储均采用加密技术
• 访问控制：严格的用户权限管理
• 安全审计：定期进行安全检查和更新

4.3 数据保留
• 业务数据：根据法律要求和业务需要保留
• 日志数据：保留30天用于问题排查
• 账户数据：账户注销后30天内删除
''',
            ),
            _buildSection(
              title: '5. 信息共享',
              content: '''
我们不会向第三方出售、交易或转让您的个人信息，除非：

5.1 获得您的明确同意
5.2 法律法规要求
5.3 保护我们的合法权益
5.4 紧急情况下保护用户安全

与第三方服务提供商的合作仅限于：
• 云存储服务（数据备份）
• 技术支持服务（问题排查）
• 安全服务（防护攻击）

所有合作均签署严格的保密协议。
''',
            ),
            _buildSection(
              title: '6. 您的权利',
              content: '''
您对个人信息享有以下权利：

6.1 访问权
• 查看我们收集的您的个人信息
• 了解信息的使用目的和方式

6.2 更正权
• 更新或修正不准确的个人信息
• 完善不完整的信息

6.3 删除权
• 要求删除不必要的个人信息
• 注销账户时删除相关数据

6.4 限制处理权
• 限制某些信息的处理方式
• 暂停某些功能的数据收集

如需行使上述权利，请联系我们的客服团队。
''',
            ),
            _buildSection(
              title: '7. 未成年人保护',
              content: '''
宏店主要面向企业用户，不专门收集未成年人信息。

如果我们发现在未获得父母同意的情况下收集了未成年人的个人信息，我们将尽快删除相关信息。

如果您是未成年人的父母或监护人，发现您的孩子向我们提供了个人信息，请及时联系我们。
''',
            ),
            _buildSection(
              title: '8. 政策更新',
              content: '''
我们可能会不时更新本隐私政策。更新时，我们会：

• 在应用内发布更新通知
• 通过邮件或短信通知重要变更
• 在公司网站发布最新版本

重大变更会提前30天通知，并征求您的同意。

继续使用我们的服务即表示您接受更新后的隐私政策。
''',
            ),
            _buildSection(
              title: '9. 联系我们',
              content: '''
如果您对本隐私政策有任何疑问、意见或建议，请通过以下方式联系我们：

公司名称：宏达服装有限公司
联系邮箱：privacy@hongda.com
客服电话：400-123-4567
公司地址：广东省广州市天河区XXX路XXX号

我们将在收到您的反馈后15个工作日内回复。

感谢您对宏店的信任和支持！
''',
            ),
            const SizedBox(height: 32),
            Center(
              child: ElevatedButton(
                onPressed: () => Get.back(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                ),
                child: const Text('我已阅读并理解'),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildSection({required String title, required String content}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.blue,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          content,
          style: const TextStyle(
            fontSize: 14,
            height: 1.5,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }
}
