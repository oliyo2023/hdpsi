import 'package:flutter/foundation.dart';

/// 简单的日志工具类
class Logger {
  // 日志级别 - 使用lowerCamelCase命名风格
  static const int verbose = 0;
  static const int debug = 1;
  static const int info = 2;
  static const int warn = 3;
  static const int error = 4;
  static const int nothing = 5;

  // 当前日志级别，可以根据环境设置
  static int _level = kDebugMode ? verbose : info;

  // 设置日志级别
  static void setLevel(int level) {
    _level = level;
  }

  // 详细日志
  static void v(String tag, String message) {
    if (_level <= verbose) {
      _log('VERBOSE', tag, message);
    }
  }

  // 调试日志
  static void d(String tag, String message) {
    if (_level <= debug) {
      _log('DEBUG', tag, message);
    }
  }

  // 信息日志
  static void i(String tag, String message) {
    if (_level <= info) {
      _log('INFO', tag, message);
    }
  }

  // 警告日志
  static void w(String tag, String message) {
    if (_level <= warn) {
      _log('WARN', tag, message);
    }
  }

  // 错误日志
  static void e(String tag, String message) {
    if (_level <= error) {
      _log('ERROR', tag, message);
    }
  }

  // 打印日志的内部方法
  static void _log(String level, String tag, String message) {
    if (kDebugMode) {
      debugPrint('[$level] $tag: $message');
    }
  }
}
