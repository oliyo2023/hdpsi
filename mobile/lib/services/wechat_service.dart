import 'package:fluwx/fluwx.dart' as fluwx;
import 'package:hd_psi_mobile/utils/logger.dart';

/// 微信服务
///
/// 提供微信SDK相关功能，包括初始化和登录
class WechatService {
  // 微信应用ID - 需要在微信开放平台申请
  static const String appId = 'your_wechat_app_id';

  /// 初始化微信SDK
  static Future<bool> init() async {
    try {
      final result = await fluwx.registerWxApi(
        appId: appId,
        doOnAndroid: true,
        doOnIOS: true,
      );

      Logger.i('WechatService', '微信SDK初始化结果: $result');
      return result;
    } catch (e) {
      Logger.e('WechatService', '微信SDK初始化失败: $e');
      return false;
    }
  }

  /// 检查微信是否已安装
  static Future<bool> isWechatInstalled() async {
    try {
      return await fluwx.isWeChatInstalled();
    } catch (e) {
      Logger.e('WechatService', '检查微信安装状态失败: $e');
      return false;
    }
  }

  /// 微信登录
  ///
  /// 返回授权码，如果登录失败或取消返回null
  static Future<String?> login() async {
    try {
      // 检查微信是否已安装
      final isInstalled = await isWechatInstalled();
      if (!isInstalled) {
        Logger.w('WechatService', '微信未安装');
        return null;
      }

      // 发起微信授权
      final result = await fluwx.sendWeChatAuth(
        scope: "snsapi_userinfo",
        state: "wechat_login_${DateTime.now().millisecondsSinceEpoch}",
      );

      if (result.isSuccessful && result.code != null) {
        Logger.i('WechatService', '微信登录成功，获取到授权码');
        return result.code;
      } else {
        Logger.w('WechatService', '微信登录失败: ${result.errorCode}');
        return null;
      }
    } catch (e) {
      Logger.e('WechatService', '微信登录异常: $e');
      return null;
    }
  }

  /// 获取微信登录错误信息
  static String getErrorMessage(int? errorCode) {
    switch (errorCode) {
      case -2:
        return '用户取消登录';
      case -3:
        return '发送被拒绝';
      case -4:
        return '不支持的请求';
      case -5:
        return '无效的参数';
      default:
        return '微信登录失败';
    }
  }
}
