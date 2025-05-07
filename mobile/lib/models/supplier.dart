import 'package:json_annotation/json_annotation.dart';

part 'supplier.g.dart';

enum SupplierType {
  @JsonValue('manufacturer')
  manufacturer,
  @JsonValue('distributor')
  distributor,
  @JsonValue('retailer')
  retailer,
  @JsonValue('other')
  other,
}

extension SupplierTypeExtension on SupplierType {
  String toJson() {
    switch (this) {
      case SupplierType.manufacturer:
        return 'manufacturer';
      case SupplierType.distributor:
        return 'distributor';
      case SupplierType.retailer:
        return 'retailer';
      case SupplierType.other:
        return 'other';
    }
  }
}

enum SupplierRating {
  @JsonValue('A')
  A,
  @JsonValue('B')
  B,
  @JsonValue('C')
  C,
  @JsonValue('D')
  D,
}

@JsonSerializable()
class Supplier {
  final int id;
  final String name;
  final String code;
  final SupplierType type;
  final String? contactPerson;
  final String? contactPhone;
  final String? email;
  final String? address;
  final String? city;
  final SupplierRating? rating;
  final String? qualification;
  final String? paymentTerms;
  final String? deliveryTerms;
  final bool status;
  final String? note;
  @JsonKey(name: 'created_at')
  final DateTime createdAt;
  @JsonKey(name: 'updated_at')
  final DateTime updatedAt;

  Supplier({
    required this.id,
    required this.name,
    required this.code,
    required this.type,
    this.contactPerson,
    this.contactPhone,
    this.email,
    this.address,
    this.city,
    this.rating,
    this.qualification,
    this.paymentTerms,
    this.deliveryTerms,
    required this.status,
    this.note,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Supplier.fromJson(Map<String, dynamic> json) =>
      _$SupplierFromJson(json);

  Map<String, dynamic> toJson() => _$SupplierToJson(this);
}
