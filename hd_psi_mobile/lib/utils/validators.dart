class Validators {
  // 验证手机号
  static String? validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return '请输入手机号';
    }
    if (!RegExp(r'^1[3-9]\d{9}$').hasMatch(value)) {
      return '请输入有效的手机号';
    }
    return null;
  }
  
  // 验证必填字段
  static String? validateRequired(String? value, String fieldName) {
    if (value == null || value.isEmpty) {
      return '请输入$fieldName';
    }
    return null;
  }
  
  // 验证数字
  static String? validateNumber(String? value, String fieldName) {
    if (value == null || value.isEmpty) {
      return null; // 允许为空
    }
    if (!RegExp(r'^\d+$').hasMatch(value)) {
      return '$fieldName必须是数字';
    }
    return null;
  }
  
  // 验证价格
  static String? validatePrice(String? value, String fieldName) {
    if (value == null || value.isEmpty) {
      return '请输入$fieldName';
    }
    if (!RegExp(r'^\d+(\.\d{1,2})?$').hasMatch(value)) {
      return '$fieldName格式不正确，请输入有效的金额';
    }
    return null;
  }
  
  // 验证邮箱
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return null; // 允许为空
    }
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
      return '请输入有效的邮箱地址';
    }
    return null;
  }
}
