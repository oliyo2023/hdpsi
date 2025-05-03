class Inventory {
  final int id;
  final int storeId;
  final int productVariantId;
  final int quantity;
  final int alertQuantity;
  final String? lastCheckTime;
  final String createdAt;
  final String updatedAt;
  final Map<String, dynamic>? store;
  final Map<String, dynamic>? productVariant;
  
  Inventory({
    required this.id,
    required this.storeId,
    required this.productVariantId,
    required this.quantity,
    required this.alertQuantity,
    this.lastCheckTime,
    required this.createdAt,
    required this.updatedAt,
    this.store,
    this.productVariant,
  });
  
  factory Inventory.fromJson(Map<String, dynamic> json) {
    return Inventory(
      id: json['ID'],
      storeId: json['StoreID'],
      productVariantId: json['ProductVariantID'],
      quantity: json['Quantity'],
      alertQuantity: json['AlertQuantity'],
      lastCheckTime: json['LastCheckTime'],
      createdAt: json['CreatedAt'],
      updatedAt: json['UpdatedAt'],
      store: json['Store'],
      productVariant: json['ProductVariant'],
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'ID': id,
      'StoreID': storeId,
      'ProductVariantID': productVariantId,
      'Quantity': quantity,
      'AlertQuantity': alertQuantity,
      'LastCheckTime': lastCheckTime,
      'CreatedAt': createdAt,
      'UpdatedAt': updatedAt,
      'Store': store,
      'ProductVariant': productVariant,
    };
  }
}

class InventoryTransaction {
  final int id;
  final String transactionType;
  final int productVariantId;
  final int storeId;
  final int quantity;
  final String? batchNumber;
  final int? sourceStoreId;
  final int? referenceId;
  final String? referenceType;
  final int operatorId;
  final String note;
  final String createdAt;
  final String updatedAt;
  
  InventoryTransaction({
    required this.id,
    required this.transactionType,
    required this.productVariantId,
    required this.storeId,
    required this.quantity,
    this.batchNumber,
    this.sourceStoreId,
    this.referenceId,
    this.referenceType,
    required this.operatorId,
    required this.note,
    required this.createdAt,
    required this.updatedAt,
  });
  
  factory InventoryTransaction.fromJson(Map<String, dynamic> json) {
    return InventoryTransaction(
      id: json['ID'],
      transactionType: json['TransactionType'],
      productVariantId: json['ProductVariantID'],
      storeId: json['StoreID'],
      quantity: json['Quantity'],
      batchNumber: json['BatchNumber'],
      sourceStoreId: json['SourceStoreID'],
      referenceId: json['ReferenceID'],
      referenceType: json['ReferenceType'],
      operatorId: json['OperatorID'],
      note: json['Note'] ?? '',
      createdAt: json['CreatedAt'],
      updatedAt: json['UpdatedAt'],
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'ID': id,
      'TransactionType': transactionType,
      'ProductVariantID': productVariantId,
      'StoreID': storeId,
      'Quantity': quantity,
      'BatchNumber': batchNumber,
      'SourceStoreID': sourceStoreId,
      'ReferenceID': referenceId,
      'ReferenceType': referenceType,
      'OperatorID': operatorId,
      'Note': note,
      'CreatedAt': createdAt,
      'UpdatedAt': updatedAt,
    };
  }
}
