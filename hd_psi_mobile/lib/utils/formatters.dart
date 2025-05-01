import 'package:intl/intl.dart';

class Formatters {
  // 格式化日期
  static String formatDate(String? dateString) {
    if (dateString == null || dateString.isEmpty) {
      return '';
    }
    
    try {
      final date = DateTime.parse(dateString);
      return DateFormat('yyyy-MM-dd').format(date);
    } catch (e) {
      return dateString;
    }
  }
  
  // 格式化日期时间
  static String formatDateTime(String? dateTimeString) {
    if (dateTimeString == null || dateTimeString.isEmpty) {
      return '';
    }
    
    try {
      final dateTime = DateTime.parse(dateTimeString);
      return DateFormat('yyyy-MM-dd HH:mm').format(dateTime);
    } catch (e) {
      return dateTimeString;
    }
  }
  
  // 格式化价格
  static String formatPrice(double? price) {
    if (price == null) {
      return '¥0.00';
    }
    
    final formatter = NumberFormat.currency(
      locale: 'zh_CN',
      symbol: '¥',
      decimalDigits: 2,
    );
    
    return formatter.format(price);
  }
  
  // 格式化数量
  static String formatQuantity(int? quantity) {
    if (quantity == null) {
      return '0';
    }
    
    return quantity.toString();
  }
  
  // 格式化会员等级
  static String formatMemberLevel(String? level) {
    if (level == null || level.isEmpty) {
      return '普通会员';
    }
    
    switch (level) {
      case 'regular':
        return '普通会员';
      case 'silver':
        return '白银会员';
      case 'gold':
        return '黄金会员';
      case 'platinum':
        return '铂金会员';
      case 'diamond':
        return '钻石会员';
      default:
        return level;
    }
  }
  
  // 格式化交易类型
  static String formatTransactionType(String? type) {
    if (type == null || type.isEmpty) {
      return '未知';
    }
    
    switch (type) {
      case 'purchase_in':
        return '采购入库';
      case 'return_in':
        return '退货入库';
      case 'transfer_in':
        return '调拨入库';
      case 'sale_out':
        return '销售出库';
      case 'exchange_out':
        return '换货出库';
      case 'damage_out':
        return '报损出库';
      case 'transfer_out':
        return '调拨出库';
      default:
        return type;
    }
  }
}
