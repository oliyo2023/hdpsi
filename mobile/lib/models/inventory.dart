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
      id: json['ID'] ?? json['id'] ?? 0,
      storeId: json['StoreID'] ?? json['storeId'] ?? json['store_id'] ?? 0,
      productVariantId:
          json['ProductVariantID'] ??
          json['productVariantId'] ??
          json['product_variant_id'] ??
          0,
      quantity: json['Quantity'] ?? json['quantity'] ?? 0,
      alertQuantity:
          json['AlertQuantity'] ??
          json['alertQuantity'] ??
          json['alert_quantity'] ??
          0,
      lastCheckTime:
          json['LastCheckTime'] ??
          json['lastCheckTime'] ??
          json['last_check_time'],
      createdAt:
          json['CreatedAt'] ?? json['createdAt'] ?? json['created_at'] ?? '',
      updatedAt:
          json['UpdatedAt'] ?? json['updatedAt'] ?? json['updated_at'] ?? '',
      store: json['Store'] ?? json['store'],
      productVariant:
          json['ProductVariant'] ??
          json['productVariant'] ??
          json['product_variant'],
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
      id: json['ID'] ?? json['id'] ?? 0,
      transactionType:
          json['TransactionType'] ??
          json['transactionType'] ??
          json['transaction_type'] ??
          '',
      productVariantId:
          json['ProductVariantID'] ??
          json['productVariantId'] ??
          json['product_variant_id'] ??
          0,
      storeId: json['StoreID'] ?? json['storeId'] ?? json['store_id'] ?? 0,
      quantity: json['Quantity'] ?? json['quantity'] ?? 0,
      batchNumber:
          json['BatchNumber'] ?? json['batchNumber'] ?? json['batch_number'],
      sourceStoreId:
          json['SourceStoreID'] ??
          json['sourceStoreId'] ??
          json['source_store_id'],
      referenceId:
          json['ReferenceID'] ?? json['referenceId'] ?? json['reference_id'],
      referenceType:
          json['ReferenceType'] ??
          json['referenceType'] ??
          json['reference_type'],
      operatorId:
          json['OperatorID'] ?? json['operatorId'] ?? json['operator_id'] ?? 0,
      note: json['Note'] ?? json['note'] ?? '',
      createdAt:
          json['CreatedAt'] ?? json['createdAt'] ?? json['created_at'] ?? '',
      updatedAt:
          json['UpdatedAt'] ?? json['updatedAt'] ?? json['updated_at'] ?? '',
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
