import 'package:dio/dio.dart';
import 'package:hd_psi_mobile/utils/error_handler.dart';
import 'package:hd_psi_mobile/utils/logger.dart';

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
    final newResponse =
        err.response != null
            ? Response(
              requestOptions: err.requestOptions,
              statusCode: err.response!.statusCode,
              data: {
                'code': _getErrorCode(err),
                'message': friendlyMessage,
                'error': _getErrorDetails(err),
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

  /// 获取错误码
  int _getErrorCode(DioException err) {
    // 如果响应中已经包含错误码，直接使用
    if (err.response?.data is Map && err.response!.data['code'] != null) {
      return err.response!.data['code'] as int;
    }

    // 根据HTTP状态码映射错误码
    switch (err.response?.statusCode) {
      case 400:
        return 40000; // 请求参数错误
      case 401:
        return 40100; // 未授权
      case 403:
        return 40300; // 禁止访问
      case 404:
        return 40400; // 资源不存在
      case 405:
        return 40500; // 方法不允许
      case 409:
        return 40900; // 资源冲突
      case 429:
        return 42900; // 请求过于频繁
      case 500:
        return 50000; // 服务器内部错误
      case 502:
      case 503:
      case 504:
        return 50300; // 服务不可用
      default:
        return 50000; // 默认为服务器内部错误
    }
  }

  /// 获取错误详情
  String _getErrorDetails(DioException err) {
    // 如果响应中已经包含错误详情，直接使用
    if (err.response?.data is Map) {
      if (err.response!.data['error'] != null) {
        return err.response!.data['error'].toString();
      }
      if (err.response!.data['details'] != null) {
        return err.response!.data['details'].toString();
      }
    }

    // 返回错误类型作为详情
    return err.type.toString();
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
