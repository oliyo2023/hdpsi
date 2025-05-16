import 'dart:convert';
import 'package:hd_psi_mobile/utils/logger.dart';

/// JSON适配器
///
/// 用于处理后端API返回的JSON字段名称与生成的模型中的字段名称不匹配的问题
class JsonAdapter {
  /// 转换JSON字段名称
  ///
  /// 将后端API返回的大写开头字段名称转换为生成的模型中的小写开头字段名称
  static Map<String, dynamic> convertJsonKeys(Map<String, dynamic> json) {
    final result = <String, dynamic>{};

    json.forEach((key, value) {
      // 将大写开头的字段名称转换为小写开头
      final newKey = _convertKey(key);

      // 如果值是Map，递归转换
      if (value is Map<String, dynamic>) {
        result[newKey] = convertJsonKeys(value);
      }
      // 如果值是List，递归转换List中的每个Map
      else if (value is List) {
        result[newKey] = _convertList(value);
      }
      // 否则直接使用原始值
      else {
        result[newKey] = value;
      }
    });

    return result;
  }

  /// 转换List中的每个Map
  static List _convertList(List list) {
    return list.map((item) {
      if (item is Map<String, dynamic>) {
        return convertJsonKeys(item);
      } else if (item is List) {
        return _convertList(item);
      } else {
        return item;
      }
    }).toList();
  }

  /// 转换单个字段名称
  static String _convertKey(String key) {
    // 如果字段名称为空，直接返回
    if (key.isEmpty) return key;

    // 特殊处理ID字段
    if (key == 'ID') return 'id';

    // 将第一个字符转换为小写
    return key[0].toLowerCase() + key.substring(1);
  }

  /// 解析JSON字符串
  ///
  /// 解析JSON字符串并转换字段名称
  static Map<String, dynamic> parseJson(String jsonString) {
    try {
      final json = jsonDecode(jsonString) as Map<String, dynamic>;
      return convertJsonKeys(json);
    } catch (e) {
      Logger.e('JsonAdapter', '解析JSON失败: $e');
      rethrow;
    }
  }
}
