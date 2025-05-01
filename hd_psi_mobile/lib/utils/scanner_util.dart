import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';

class ScannerUtil {
  // 扫描条形码或二维码
  static Future<String?> scanBarcode() async {
    // 在Web平台上使用模拟输入
    if (kIsWeb) {
      return _showBarcodeInputDialog();
    }

    String barcodeScanRes;

    try {
      barcodeScanRes = await FlutterBarcodeScanner.scanBarcode(
        '#ff6666',
        '取消',
        true,
        ScanMode.BARCODE,
      );

      // 用户取消扫描
      if (barcodeScanRes == '-1') {
        return null;
      }

      return barcodeScanRes;
    } on PlatformException {
      return null;
    }
  }

  // 扫描二维码
  static Future<String?> scanQRCode() async {
    // 在Web平台上使用模拟输入
    if (kIsWeb) {
      return _showBarcodeInputDialog();
    }

    String barcodeScanRes;

    try {
      barcodeScanRes = await FlutterBarcodeScanner.scanBarcode(
        '#ff6666',
        '取消',
        true,
        ScanMode.QR,
      );

      // 用户取消扫描
      if (barcodeScanRes == '-1') {
        return null;
      }

      return barcodeScanRes;
    } on PlatformException {
      return null;
    }
  }

  // Web平台上显示输入对话框
  static Future<String?> _showBarcodeInputDialog() async {
    final TextEditingController controller = TextEditingController();
    String? result;

    // 获取全局上下文
    final context = navigatorKey.currentContext;
    if (context == null) return null;

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('输入条码'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('由于Web平台限制，请手动输入条码'),
              const SizedBox(height: 16),
              TextField(
                controller: controller,
                decoration: const InputDecoration(
                  labelText: '条码',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.text,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('取消'),
            ),
            ElevatedButton(
              onPressed: () {
                result = controller.text;
                Navigator.of(context).pop();
              },
              child: const Text('确定'),
            ),
          ],
        );
      },
    );

    return result;
  }
}

// 全局导航键，用于获取上下文
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
