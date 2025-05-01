class AppConfig {
  // API基础URL
  static const String apiBaseUrl = 'http://192.168.1.4:8081';

  // API路径
  static const String loginPath = '/api/auth/login';
  static const String productsPath = '/api/products';
  static const String membersPath = '/api/members';
  static const String inventoryPath = '/api/inventory';
  static const String inventoryTransactionsPath = '/api/inventory-transactions';

  // 应用名称
  static const String appName = '服装进销存系统';

  // 版本号
  static const String appVersion = '1.0.0';

  // 超时设置（毫秒）
  static const int connectTimeout = 15000;
  static const int receiveTimeout = 15000;

  // 令牌存储键
  static const String tokenKey = 'auth_token';
  static const String refreshTokenKey = 'refresh_token';
  static const String userKey = 'user_info';
}
