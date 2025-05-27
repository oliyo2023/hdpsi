import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../services/permission_service.dart';
import '../services/app_initialization_service.dart';
import '../utils/permission_helper.dart';
import '../widgets/scan_button_widget.dart';

/// 权限测试页面
/// 用于开发和测试权限功能
class PermissionTestPage extends StatefulWidget {
  const PermissionTestPage({super.key});

  @override
  State<PermissionTestPage> createState() => _PermissionTestPageState();
}

class _PermissionTestPageState extends State<PermissionTestPage> {
  final AppInitializationService _appService = AppInitializationService.to;
  final PermissionService _permissionService = PermissionService.to;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('权限测试'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: _showPermissionStatus,
            icon: const Icon(Icons.info_outline),
            tooltip: '权限状态',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSection(
              title: '应用状态',
              children: [
                Obx(() => _buildStatusCard(
                  title: '首次启动',
                  value: _appService.isFirstLaunch.value ? '是' : '否',
                  color: _appService.isFirstLaunch.value ? Colors.orange : Colors.green,
                )),
                Obx(() => _buildStatusCard(
                  title: '权限引导完成',
                  value: _appService.isPermissionGuideCompleted.value ? '是' : '否',
                  color: _appService.isPermissionGuideCompleted.value ? Colors.green : Colors.orange,
                )),
                Obx(() => _buildStatusCard(
                  title: '应用初始化',
                  value: _appService.isInitialized.value ? '完成' : '进行中',
                  color: _appService.isInitialized.value ? Colors.green : Colors.blue,
                )),
              ],
            ),
            
            const SizedBox(height: 24),
            
            _buildSection(
              title: '权限测试',
              children: [
                _buildPermissionTestCard(
                  title: '相机权限（扫码）',
                  description: '测试扫码功能的相机权限',
                  onTest: () async {
                    final granted = await PermissionHelper.checkCameraForScanning();
                    _showResult('相机权限（扫码）', granted);
                  },
                ),
                _buildPermissionTestCard(
                  title: '相机权限（拍照）',
                  description: '测试拍照功能的相机权限',
                  onTest: () async {
                    final granted = await PermissionHelper.checkCameraForPhoto();
                    _showResult('相机权限（拍照）', granted);
                  },
                ),
                _buildPermissionTestCard(
                  title: '相册权限',
                  description: '测试图片选择功能的相册权限',
                  onTest: () async {
                    final granted = await PermissionHelper.checkPhotosPermission();
                    _showResult('相册权限', granted);
                  },
                ),
                _buildPermissionTestCard(
                  title: '存储权限',
                  description: '测试文件保存功能的存储权限',
                  onTest: () async {
                    final granted = await PermissionHelper.checkStoragePermission();
                    _showResult('存储权限', granted);
                  },
                ),
              ],
            ),
            
            const SizedBox(height: 24),
            
            _buildSection(
              title: '功能组件测试',
              children: [
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          '扫码按钮',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        const Text('测试集成权限检查的扫码按钮组件'),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            ScanButtonWidget(
                              onScanSuccess: () {
                                Get.snackbar('测试', '扫码功能测试成功');
                              },
                            ),
                            const SizedBox(width: 12),
                            ScanButtonWidget(
                              onScanSuccess: () {
                                Get.snackbar('测试', '浮动按钮测试成功');
                              },
                              isFloatingActionButton: true,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          '图片选择按钮',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        const Text('测试集成权限检查的图片选择组件'),
                        const SizedBox(height: 12),
                        ImagePickerButtonWidget(
                          onImageSelected: (imagePath) {
                            Get.snackbar('测试', '图片选择测试成功: $imagePath');
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          '文件保存按钮',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        const Text('测试集成权限检查的文件保存组件'),
                        const SizedBox(height: 12),
                        SaveFileButtonWidget(
                          onSaveSuccess: () {
                            Get.snackbar('测试', '文件保存测试成功');
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 24),
            
            _buildSection(
              title: '开发工具',
              children: [
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          '重置应用状态',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        const Text('重置首次启动和权限引导状态，用于测试'),
                        const SizedBox(height: 12),
                        ElevatedButton(
                          onPressed: _resetAppStatus,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            foregroundColor: Colors.white,
                          ),
                          child: const Text('重置状态'),
                        ),
                      ],
                    ),
                  ),
                ),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          '显示权限引导',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        const Text('手动显示权限引导页面'),
                        const SizedBox(height: 12),
                        ElevatedButton(
                          onPressed: () {
                            Get.toNamed('/permission-guide');
                          },
                          child: const Text('显示引导'),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection({required String title, required List<Widget> children}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.blue,
          ),
        ),
        const SizedBox(height: 12),
        ...children,
      ],
    );
  }

  Widget _buildStatusCard({
    required String title,
    required String value,
    required Color color,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
            const Spacer(),
            Text(
              value,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPermissionTestCard({
    required String title,
    required String description,
    required VoidCallback onTest,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              description,
              style: const TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: onTest,
              child: const Text('测试权限'),
            ),
          ],
        ),
      ),
    );
  }

  void _showResult(String permission, bool granted) {
    Get.snackbar(
      permission,
      granted ? '权限已授权' : '权限被拒绝',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: granted ? Colors.green.shade100 : Colors.red.shade100,
      colorText: granted ? Colors.green.shade800 : Colors.red.shade800,
      icon: Icon(
        granted ? Icons.check_circle : Icons.cancel,
        color: granted ? Colors.green : Colors.red,
      ),
    );
  }

  void _showPermissionStatus() {
    _appService.showPermissionStatus();
  }

  void _resetAppStatus() async {
    await _appService.resetFirstLaunchStatus();
    Get.snackbar(
      '重置完成',
      '应用状态已重置，重启应用后生效',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.blue.shade100,
      colorText: Colors.blue.shade800,
      icon: const Icon(Icons.refresh, color: Colors.blue),
    );
  }
}
