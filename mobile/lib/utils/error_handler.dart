import 'package:dio/dio.dart';
import 'logger.dart';

/// 错误处理工具类
/// 提供友好的错误消息，同时将详细错误记录到日志
class ErrorHandler {
  /// 获取用户友好的错误消息
  /// 
  /// [error] 原始错误对象
  /// 返回用户友好的错误消息
  static String getFriendlyMessage(dynamic error) {
    // 记录详细错误到日志
    _logDetailedError(error);
    
    // 返回用户友好的错误消息
    return _getFriendlyErrorMessage(error);
  }
  
  /// 记录详细错误信息到日志
  static void _logDetailedError(dynamic error) {
    if (error is DioException) {
      // 记录DIO错误的详细信息
      Logger.e('ErrorHandler', '网络请求错误: ${error.type}');
      Logger.e('ErrorHandler', '请求URL: ${error.requestOptions.uri}');
      Logger.e('ErrorHandler', '请求方法: ${error.requestOptions.method}');
      
      if (error.response != null) {
        Logger.e('ErrorHandler', '状态码: ${error.response!.statusCode}');
        Logger.e('ErrorHandler', '响应数据: ${error.response!.data}');
      }
      
      if (error.error != null) {
        Logger.e('ErrorHandler', '错误详情: ${error.error}');
      }
      
      Logger.e('ErrorHandler', '堆栈跟踪: ${error.stackTrace}');
    } else {
      // 记录其他类型错误
      Logger.e('ErrorHandler', '发生错误: ${error.toString()}');
      if (error is Error) {
        Logger.e('ErrorHandler', '堆栈跟踪: ${error.stackTrace}');
      }
    }
  }
  
  /// 获取用户友好的错误消息
  static String _getFriendlyErrorMessage(dynamic error) {
    if (error is DioException) {
      return _getDioFriendlyMessage(error);
    } else {
      return '操作失败，请稍后重试';
    }
  }
  
  /// 获取DIO错误的友好消息
  static String _getDioFriendlyMessage(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
        return '连接超时，请检查网络后重试';
        
      case DioExceptionType.sendTimeout:
        return '发送请求超时，请稍后重试';
        
      case DioExceptionType.receiveTimeout:
        return '接收数据超时，请稍后重试';
        
      case DioExceptionType.badResponse:
        return _getHttpStatusFriendlyMessage(error.response?.statusCode);
        
      case DioExceptionType.cancel:
        return '请求已取消';
        
      case DioExceptionType.connectionError:
        return '网络连接错误，请检查网络设置';
        
      case DioExceptionType.unknown:
      default:
        if (error.error != null && error.error.toString().contains('SocketException')) {
          return '无法连接到服务器，请检查网络连接';
        }
        return '网络请求失败，请稍后重试';
    }
  }
  
  /// 根据HTTP状态码获取友好消息
  static String _getHttpStatusFriendlyMessage(int? statusCode) {
    switch (statusCode) {
      case 400:
        return '请求参数有误，请检查输入';
        
      case 401:
        return '登录已过期，请重新登录';
        
      case 403:
        return '没有权限执行此操作';
        
      case 404:
        return '请求的资源不存在';
        
      case 408:
        return '请求超时，请稍后重试';
        
      case 409:
        return '操作冲突，请刷新后重试';
        
      case 429:
        return '请求过于频繁，请稍后再试';
        
      case 500:
        return '服务器内部错误，请稍后重试';
        
      case 502:
        return '服务暂时不可用，请稍后重试';
        
      case 503:
        return '服务器正在维护，请稍后重试';
        
      case 504:
        return '服务器响应超时，请稍后重试';
        
      default:
        return '服务器响应异常，请稍后重试';
    }
  }
}
