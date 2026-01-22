import 'package:fluwx/fluwx.dart';
import 'package:hd_psi_mobile/utils/logger.dart';

/// 微信服务
///
/// 提供微信SDK相关功能，包括初始化和登录
class WechatService {
  // 微信应用ID - 需要在微信开放平台申请
  static const String appId = 'your_wechat_app_id';

  // Fluwx 实例
  static final Fluwx _fluwx = Fluwx();

  /// 初始化微信SDK
  static Future<bool> init() async {
    try {
      await _fluwx.registerApi(
        appId: appId,
        doOnAndroid: true,
        doOnIOS: true,
        universalLink: 'https://your.univerallink.com/link/', // 可选，iOS需要
      );

      Logger.i('WechatService', '微信SDK初始化成功');
      return true;
    } catch (e) {
      Logger.e('WechatService', '微信SDK初始化失败: $e');
      return false;
    }
  }

  /// 检查微信是否已安装
  static Future<bool> isWechatInstalled() async {
    try {
      return await _fluwx.isWeChatInstalled;
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
      final success = await _fluwx.authBy(
        which: NormalAuth(
          scope: "snsapi_userinfo",
          state: "wechat_login_${DateTime.now().millisecondsSinceEpoch}",
        ),
      );

      if (success) {
        Logger.i('WechatService', '微信授权请求发送成功');
        // 注意：实际的授权结果需要通过监听器获取
        // 这里只是表示授权请求发送成功
        return "auth_request_sent";
      } else {
        Logger.w('WechatService', '微信授权请求发送失败');
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
