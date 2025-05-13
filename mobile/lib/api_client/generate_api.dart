import 'dart:io';
import 'package:http/http.dart' as http;

/// 生成API客户端
///
/// 运行此脚本以从Swagger文档生成API客户端代码
Future<void> main() async {
  // 确保后端服务器正在运行
  print('正在生成API客户端...');
  print('请确保后端服务器正在运行，并且Swagger文档可访问。');

  try {
    // 下载Swagger JSON文件
    print('正在下载Swagger文档...');
    final response = await http.get(
      Uri.parse('http://localhost:8081/swagger/doc.json'),
    );

    if (response.statusCode == 200) {
      // 保存Swagger JSON文件
      final swaggerJson = response.body;
      final swaggerFile = File('swagger.json');
      await swaggerFile.writeAsString(swaggerJson);

      print('Swagger文档下载成功！');

      // 运行OpenAPI生成器
      print('正在运行OpenAPI生成器...');

      // 使用命令行运行OpenAPI生成器
      final result = await Process.run('flutter', [
        'pub',
        'run',
        'build_runner',
        'build',
        '--delete-conflicting-outputs',
      ]);

      print(result.stdout);

      if (result.exitCode != 0) {
        print('错误: ${result.stderr}');
        return;
      }

      print('API客户端生成成功！');
      print('生成的代码位于: lib/api_client/generated/');
    } else {
      print('下载Swagger文档失败: ${response.statusCode}');
      print('请确保后端服务器正在运行，并且Swagger文档可访问。');
    }
  } catch (e) {
    print('API客户端生成失败: $e');
  }
}
