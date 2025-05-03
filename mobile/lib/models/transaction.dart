class Transaction {
  final int id;
  final int memberId;
  final String memberName;
  final String type; // purchase, refund, points_adjustment
  final double amount;
  final int pointsEarned;
  final int pointsUsed;
  final String? note;
  final List<TransactionItem>? items;
  final String createdAt;
  final String? staffName;

  Transaction({
    required this.id,
    required this.memberId,
    required this.memberName,
    required this.type,
    required this.amount,
    required this.pointsEarned,
    required this.pointsUsed,
    this.note,
    this.items,
    required this.createdAt,
    this.staffName,
  });

  factory Transaction.fromJson(Map<String, dynamic> json) {
    List<TransactionItem>? items;
    if (json['Items'] != null) {
      items =
          (json['Items'] as List)
              .map((item) => TransactionItem.fromJson(item))
              .toList();
    }

    // 处理积分交易记录的特殊字段
    int pointsEarned = 0;
    int pointsUsed = 0;

    // 如果是积分交易记录（来自会员积分交易API）
    if (json['Points'] != null) {
      // Points字段：正数表示获得积分，负数表示使用积分
      int points =
          json['Points'] is int
              ? json['Points']
              : int.parse(json['Points'].toString());
      if (points > 0) {
        pointsEarned = points;
      } else if (points < 0) {
        pointsUsed = -points; // 转为正数
      }
    } else {
      // 常规交易记录
      pointsEarned = json['PointsEarned'] ?? 0;
      pointsUsed = json['PointsUsed'] ?? 0;
    }

    return Transaction(
      id: json['ID'] ?? json['id'] ?? 0,
      memberId: json['MemberID'] ?? json['member_id'] ?? 0,
      memberName: json['MemberName'] ?? '',
      type: json['Type'] ?? json['type'] ?? 'unknown',
      amount: json['Amount']?.toDouble() ?? 0.0,
      pointsEarned: pointsEarned,
      pointsUsed: pointsUsed,
      note: json['Note'] ?? json['Description'] ?? '',
      items: items,
      createdAt:
          json['CreatedAt'] ??
          json['created_at'] ??
          DateTime.now().toIso8601String(),
      staffName: json['StaffName'] ?? json['OperatorID']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'ID': id,
      'MemberID': memberId,
      'MemberName': memberName,
      'Type': type,
      'Amount': amount,
      'PointsEarned': pointsEarned,
      'PointsUsed': pointsUsed,
      'Note': note,
      'Items': items?.map((item) => item.toJson()).toList(),
      'CreatedAt': createdAt,
      'StaffName': staffName,
    };
  }
}

class TransactionItem {
  final int id;
  final int transactionId;
  final int productId;
  final String productName;
  final String? productSku;
  final int quantity;
  final double price;
  final double discount;
  final double subtotal;

  TransactionItem({
    required this.id,
    required this.transactionId,
    required this.productId,
    required this.productName,
    this.productSku,
    required this.quantity,
    required this.price,
    required this.discount,
    required this.subtotal,
  });

  factory TransactionItem.fromJson(Map<String, dynamic> json) {
    return TransactionItem(
      id: json['ID'],
      transactionId: json['TransactionID'],
      productId: json['ProductID'],
      productName: json['ProductName'] ?? '',
      productSku: json['ProductSKU'],
      quantity: json['Quantity'] ?? 0,
      price: json['Price']?.toDouble() ?? 0.0,
      discount: json['Discount']?.toDouble() ?? 0.0,
      subtotal: json['Subtotal']?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'ID': id,
      'TransactionID': transactionId,
      'ProductID': productId,
      'ProductName': productName,
      'ProductSKU': productSku,
      'Quantity': quantity,
      'Price': price,
      'Discount': discount,
      'Subtotal': subtotal,
    };
  }
}
