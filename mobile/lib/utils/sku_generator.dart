import 'package:flutter/material.dart';

/// 商品SKU编码生成器
class SkuGenerator {
  /// 季节枚举
  static const Map<String, String> seasons = {
    'spring': 'S', // 春季
    'summer': 'X', // 夏季
    'autumn': 'Q', // 秋季
    'winter': 'D', // 冬季
    'all': 'A',    // 四季
  };

  /// 生成SKU编码
  /// 
  /// 编码规则: 品类(2)+年份(2)+季节(1)+颜色(3)+尺码(2)
  /// 
  /// [categoryCode] 品类代码，2位字符
  /// [year] 年份，取后两位，如2023取23
  /// [season] 季节，取首字母，春S/夏X/秋Q/冬D/四季A
  /// [colorCode] 颜色代码，3位字符
  /// [sizeCode] 尺码代码，2位字符
  static String generateSku({
    required String categoryCode,
    required int year,
    required String season,
    required String colorCode,
    required String sizeCode,
  }) {
    // 验证输入
    if (categoryCode.length != 2) {
      throw ArgumentError('品类代码必须为2位字符');
    }
    
    // 处理年份，取后两位
    final yearCode = (year % 100).toString().padLeft(2, '0');
    
    // 处理季节
    final seasonCode = seasons[season.toLowerCase()] ?? 'A';
    
    // 处理颜色代码
    if (colorCode.length != 3) {
      throw ArgumentError('颜色代码必须为3位字符');
    }
    
    // 处理尺码代码
    if (sizeCode.length != 2) {
      throw ArgumentError('尺码代码必须为2位字符');
    }
    
    // 组合SKU
    return '${categoryCode.toUpperCase()}$yearCode$seasonCode${colorCode.toUpperCase()}${sizeCode.toUpperCase()}';
  }
  
  /// 解析SKU编码
  /// 
  /// 返回包含各部分信息的Map
  static Map<String, String> parseSku(String sku) {
    if (sku.length != 10) {
      throw ArgumentError('SKU编码必须为10位字符');
    }
    
    return {
      'categoryCode': sku.substring(0, 2),
      'year': '20${sku.substring(2, 4)}',
      'season': _getSeasonName(sku.substring(4, 5)),
      'colorCode': sku.substring(5, 8),
      'sizeCode': sku.substring(8, 10),
    };
  }
  
  /// 根据季节代码获取季节名称
  static String _getSeasonName(String code) {
    switch (code) {
      case 'S': return '春季';
      case 'X': return '夏季';
      case 'Q': return '秋季';
      case 'D': return '冬季';
      case 'A': return '四季';
      default: return '未知';
    }
  }
  
  /// 验证SKU编码是否有效
  static bool isValidSku(String sku) {
    if (sku.length != 10) {
      return false;
    }
    
    // 验证年份部分是否为数字
    if (!RegExp(r'^\d{2}$').hasMatch(sku.substring(2, 4))) {
      return false;
    }
    
    // 验证季节部分是否有效
    if (!seasons.values.contains(sku.substring(4, 5))) {
      return false;
    }
    
    return true;
  }
}
