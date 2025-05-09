import 'package:json_annotation/json_annotation.dart';

part 'supplier.g.dart';

enum SupplierType {
  @JsonValue('manufacturer')
  manufacturer,
  @JsonValue('distributor')
  distributor,
  @JsonValue('retailer')
  retailer,
  @JsonValue('wholesaler')
  wholesaler,
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
      case SupplierType.wholesaler:
        return 'wholesaler';
      case SupplierType.other:
        return 'other';
    }
  }
}

enum SupplierRating {
  @JsonValue('S')
  S,
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
  @JsonKey(name: 'ID')
  final int id;
  @JsonKey(name: 'Name')
  final String name;
  @JsonKey(name: 'Code')
  final String code;
  @JsonKey(name: 'Type')
  final SupplierType type;
  @JsonKey(name: 'ContactPerson')
  final String? contactPerson;
  @JsonKey(name: 'ContactPhone')
  final String? contactPhone;
  @JsonKey(name: 'Email')
  final String? email;
  @JsonKey(name: 'Address')
  final String? address;
  @JsonKey(name: 'City')
  final String? city;
  @JsonKey(name: 'Rating')
  final SupplierRating? rating;
  @JsonKey(name: 'Qualification')
  final String? qualification;
  @JsonKey(name: 'PaymentTerms')
  final String? paymentTerms;
  @JsonKey(name: 'DeliveryTerms')
  final String? deliveryTerms;
  @JsonKey(name: 'Status')
  final bool status;
  @JsonKey(name: 'Note')
  final String? note;
  @JsonKey(name: 'CreatedAt')
  final DateTime createdAt;
  @JsonKey(name: 'UpdatedAt')
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
