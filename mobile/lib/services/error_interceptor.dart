import 'package:dio/dio.dart';
import '../utils/error_handler.dart';
import '../utils/logger.dart';

/// DIO错误拦截器
/// 
/// 拦截所有DIO请求错误，提供友好的错误消息，并记录详细错误信息到日志
class ErrorInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    // 记录详细错误信息到日志
    _logDetailedError(err);
    
    // 创建新的错误对象，包含友好的错误消息
    final friendlyMessage = ErrorHandler.getFriendlyMessage(err);
    
    // 创建新的错误响应
    final newResponse = err.response != null
        ? Response(
            requestOptions: err.requestOptions,
            statusCode: err.response!.statusCode,
            data: {
              'error': friendlyMessage,
              'request_id': _getRequestId(err),
            },
          )
        : null;
    
    // 创建新的错误对象
    final newError = DioException(
      requestOptions: err.requestOptions,
      response: newResponse,
      type: err.type,
      error: friendlyMessage,
    );
    
    // 继续处理错误
    handler.next(newError);
  }
  
  /// 记录详细错误信息到日志
  void _logDetailedError(DioException err) {
    Logger.e('ErrorInterceptor', '请求错误: ${err.type}');
    Logger.e('ErrorInterceptor', '请求URL: ${err.requestOptions.uri}');
    Logger.e('ErrorInterceptor', '请求方法: ${err.requestOptions.method}');
    
    if (err.response != null) {
      Logger.e('ErrorInterceptor', '状态码: ${err.response!.statusCode}');
      Logger.e('ErrorInterceptor', '响应数据: ${err.response!.data}');
    }
    
    if (err.error != null) {
      Logger.e('ErrorInterceptor', '错误详情: ${err.error}');
    }
    
    Logger.e('ErrorInterceptor', '堆栈跟踪: ${err.stackTrace}');
  }
  
  /// 获取请求ID
  String _getRequestId(DioException err) {
    if (err.response?.data is Map && err.response!.data['request_id'] != null) {
      return err.response!.data['request_id'].toString();
    }
    
    // 生成随机请求ID
    return DateTime.now().millisecondsSinceEpoch.toString();
  }
}
