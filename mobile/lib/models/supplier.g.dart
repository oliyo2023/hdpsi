// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'supplier.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Supplier _$SupplierFromJson(Map<String, dynamic> json) => Supplier(
      id: (json['ID'] as num).toInt(),
      name: json['Name'] as String,
      code: json['Code'] as String,
      type: $enumDecode(_$SupplierTypeEnumMap, json['Type']),
      contactPerson: json['ContactPerson'] as String?,
      contactPhone: json['ContactPhone'] as String?,
      email: json['Email'] as String?,
      address: json['Address'] as String?,
      city: json['City'] as String?,
      rating: $enumDecodeNullable(_$SupplierRatingEnumMap, json['Rating']),
      qualification: json['Qualification'] as String?,
      paymentTerms: json['PaymentTerms'] as String?,
      deliveryTerms: json['DeliveryTerms'] as String?,
      status: json['Status'] as bool,
      note: json['Note'] as String?,
      createdAt: DateTime.parse(json['CreatedAt'] as String),
      updatedAt: DateTime.parse(json['UpdatedAt'] as String),
    );

Map<String, dynamic> _$SupplierToJson(Supplier instance) => <String, dynamic>{
      'ID': instance.id,
      'Name': instance.name,
      'Code': instance.code,
      'Type': _$SupplierTypeEnumMap[instance.type]!,
      'ContactPerson': instance.contactPerson,
      'ContactPhone': instance.contactPhone,
      'Email': instance.email,
      'Address': instance.address,
      'City': instance.city,
      'Rating': _$SupplierRatingEnumMap[instance.rating],
      'Qualification': instance.qualification,
      'PaymentTerms': instance.paymentTerms,
      'DeliveryTerms': instance.deliveryTerms,
      'Status': instance.status,
      'Note': instance.note,
      'CreatedAt': instance.createdAt.toIso8601String(),
      'UpdatedAt': instance.updatedAt.toIso8601String(),
    };

const _$SupplierTypeEnumMap = {
  SupplierType.manufacturer: 'manufacturer',
  SupplierType.distributor: 'distributor',
  SupplierType.retailer: 'retailer',
  SupplierType.wholesaler: 'wholesaler',
  SupplierType.other: 'other',
};

const _$SupplierRatingEnumMap = {
  SupplierRating.S: 'S',
  SupplierRating.A: 'A',
  SupplierRating.B: 'B',
  SupplierRating.C: 'C',
  SupplierRating.D: 'D',
};
