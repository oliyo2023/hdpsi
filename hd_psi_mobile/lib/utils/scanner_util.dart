import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class ScannerUtil {
  // 扫描条形码或二维码
  static Future<String?> scanBarcode() async {
    // 在Web平台上使用模拟输入
    if (kIsWeb) {
      return _showBarcodeInputDialog();
    }

    final context = navigatorKey.currentContext;
    if (context == null) return null;

    String? barcodeScanRes;

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          insetPadding: const EdgeInsets.all(10),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: SizedBox(
              height: MediaQuery.of(context).size.height * 0.8,
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          '扫描条码',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: MobileScanner(
                      controller: MobileScannerController(),
                      onDetect: (capture) {
                        final List<Barcode> barcodes = capture.barcodes;
                        if (barcodes.isNotEmpty) {
                          final String code = barcodes.first.rawValue ?? '';
                          if (code.isNotEmpty) {
                            barcodeScanRes = code;
                            Navigator.of(context).pop();
                          }
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );

    return barcodeScanRes;
  }

  // 扫描二维码
  static Future<String?> scanQRCode() async {
    // 在Web平台上使用模拟输入
    if (kIsWeb) {
      return _showBarcodeInputDialog();
    }

    final context = navigatorKey.currentContext;
    if (context == null) return null;

    String? barcodeScanRes;

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          insetPadding: const EdgeInsets.all(10),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: SizedBox(
              height: MediaQuery.of(context).size.height * 0.8,
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          '扫描二维码',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: MobileScanner(
                      controller: MobileScannerController(
                        formats: const [BarcodeFormat.qrCode],
                      ),
                      onDetect: (capture) {
                        final List<Barcode> barcodes = capture.barcodes;
                        if (barcodes.isNotEmpty) {
                          final String code = barcodes.first.rawValue ?? '';
                          if (code.isNotEmpty) {
                            barcodeScanRes = code;
                            Navigator.of(context).pop();
                          }
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );

    return barcodeScanRes;
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
