import 'package:flutter/services.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';

class ScannerUtil {
  // 扫描条形码或二维码
  static Future<String?> scanBarcode() async {
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
}
