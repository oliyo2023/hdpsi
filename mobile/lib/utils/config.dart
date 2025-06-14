class AppConfig {
  // API基础URL - 默认值，可以通过setApiBaseUrl方法修改
  static String _apiBaseUrl = 'http://localhost:8080';

  // 获取当前API基础URL
  static String get apiBaseUrl => _apiBaseUrl;

  // 设置API基础URL
  static void setApiBaseUrl(String url) {
    _apiBaseUrl = url;
  }

  // 预定义的环境配置
  static const Map<String, String> environments = {
    'local': 'http://localhost:8080',
    'dev': 'https://8.140.206.248/hdpsi/',
    'test': 'https://8.140.206.248/hdpsi/',
    'prod': 'https://api.example.com',
  };

  // 设置预定义环境
  static void setEnvironment(String env) {
    if (environments.containsKey(env)) {
      _apiBaseUrl = environments[env]!;
    }
  }

  // API路径
  static const String loginPath = '/api/auth/login';
  static const String productsPath = '/api/products';
  static const String membersPath = '/api/members';
  static const String inventoryPath = '/api/inventory';
  static const String inventoryTransactionsPath = '/api/inventory-transactions';
  static const String suppliersPath = '/api/suppliers';

  // 应用名称
  static const String appName = '宏店';

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
