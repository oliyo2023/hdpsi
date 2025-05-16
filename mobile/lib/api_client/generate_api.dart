import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:hd_psi_mobile/utils/logger.dart';

/// 生成API客户端
///
/// 运行此脚本以从Swagger文档生成API客户端代码
Future<void> main() async {
  // 确保后端服务器正在运行
  Logger.i('API生成', '正在生成API客户端...');
  Logger.i('API生成', '请确保后端服务器正在运行，并且Swagger文档可访问。');

  try {
    // 下载Swagger JSON文件
    Logger.i('API生成', '正在下载Swagger文档...');
    final response = await http.get(
      Uri.parse('http://localhost:8081/swagger/doc.json'),
    );

    if (response.statusCode == 200) {
      // 保存Swagger JSON文件
      final swaggerJson = response.body;
      final swaggerFile = File('swagger.json');
      await swaggerFile.writeAsString(swaggerJson);

      Logger.i('API生成', 'Swagger文档下载成功！');

      // 运行OpenAPI生成器
      Logger.i('API生成', '正在运行OpenAPI生成器...');

      // 使用命令行运行OpenAPI生成器
      final result = await Process.run('flutter', [
        'pub',
        'run',
        'build_runner',
        'build',
        '--delete-conflicting-outputs',
      ]);

      Logger.i('API生成', result.stdout);

      if (result.exitCode != 0) {
        Logger.e('API生成', '错误: ${result.stderr}');
        return;
      }

      Logger.i('API生成', 'API客户端生成成功！');
      Logger.i('API生成', '生成的代码位于: lib/api_client/generated/');
    } else {
      Logger.e('API生成', '下载Swagger文档失败: ${response.statusCode}');
      Logger.e('API生成', '请确保后端服务器正在运行，并且Swagger文档可访问。');
    }
  } catch (e) {
    Logger.e('API生成', 'API客户端生成失败: $e');
  }
}
