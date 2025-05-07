// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'supplier.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Supplier _$SupplierFromJson(Map<String, dynamic> json) => Supplier(
  id: (json['id'] as num).toInt(),
  name: json['name'] as String,
  code: json['code'] as String,
  type: $enumDecode(_$SupplierTypeEnumMap, json['type']),
  contactPerson: json['contactPerson'] as String?,
  contactPhone: json['contactPhone'] as String?,
  email: json['email'] as String?,
  address: json['address'] as String?,
  city: json['city'] as String?,
  rating: $enumDecodeNullable(_$SupplierRatingEnumMap, json['rating']),
  qualification: json['qualification'] as String?,
  paymentTerms: json['paymentTerms'] as String?,
  deliveryTerms: json['deliveryTerms'] as String?,
  status: json['status'] as bool,
  note: json['note'] as String?,
  createdAt: DateTime.parse(json['created_at'] as String),
  updatedAt: DateTime.parse(json['updated_at'] as String),
);

Map<String, dynamic> _$SupplierToJson(Supplier instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'code': instance.code,
  'type': _$SupplierTypeEnumMap[instance.type]!,
  'contactPerson': instance.contactPerson,
  'contactPhone': instance.contactPhone,
  'email': instance.email,
  'address': instance.address,
  'city': instance.city,
  'rating': _$SupplierRatingEnumMap[instance.rating],
  'qualification': instance.qualification,
  'paymentTerms': instance.paymentTerms,
  'deliveryTerms': instance.deliveryTerms,
  'status': instance.status,
  'note': instance.note,
  'created_at': instance.createdAt.toIso8601String(),
  'updated_at': instance.updatedAt.toIso8601String(),
};

const _$SupplierTypeEnumMap = {
  SupplierType.manufacturer: 'manufacturer',
  SupplierType.distributor: 'distributor',
  SupplierType.retailer: 'retailer',
  SupplierType.other: 'other',
};

const _$SupplierRatingEnumMap = {
  SupplierRating.A: 'A',
  SupplierRating.B: 'B',
  SupplierRating.C: 'C',
  SupplierRating.D: 'D',
};
