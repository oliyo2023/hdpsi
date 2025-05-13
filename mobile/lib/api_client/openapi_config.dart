import 'package:openapi_generator_annotations/openapi_generator_annotations.dart';

@Openapi(
  additionalProperties: AdditionalProperties(
    pubName: 'hd_psi_api',
    pubDescription: '宏达服装进销存系统API客户端',
    pubAuthor: 'HD-PSI Team',
    pubAuthorEmail: 'support@example.com',
    pubHomepage: 'https://github.com/example/hd_psi',
    pubVersion: '1.0.0',
  ),
  inputSpecFile: 'swagger.json', // 本地Swagger JSON文件
  generatorName: Generator.dart,
  outputDirectory: 'lib/api_client/generated',
  skipSpecValidation: true,
  alwaysRun: true,
  // 配置生成器选项
  typeMappings: {'integer': 'int', 'number': 'double', 'boolean': 'bool'},
  // 导入映射
  importMappings: {'DateTime': 'dart:core'},
)
class OpenApiConfig {}
