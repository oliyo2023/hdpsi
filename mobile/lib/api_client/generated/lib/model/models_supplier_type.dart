//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.12

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;


class ModelsSupplierType {
  /// Instantiate a new enum with the provided [value].
  const ModelsSupplierType._(this.value);

  /// The underlying value of this enum member.
  final String value;

  @override
  String toString() => value;

  String toJson() => value;

  static const SupplierManufacturer = ModelsSupplierType._(r'manufacturer');
  static const SupplierWholesaler = ModelsSupplierType._(r'wholesaler');
  static const SupplierAgent = ModelsSupplierType._(r'agent');
  static const SupplierOther = ModelsSupplierType._(r'other');

  /// List of all possible values in this [enum][ModelsSupplierType].
  static const values = <ModelsSupplierType>[
    SupplierManufacturer,
    SupplierWholesaler,
    SupplierAgent,
    SupplierOther,
  ];

  static ModelsSupplierType? fromJson(dynamic value) => ModelsSupplierTypeTypeTransformer().decode(value);

  static List<ModelsSupplierType> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <ModelsSupplierType>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = ModelsSupplierType.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }
}

/// Transformation class that can [encode] an instance of [ModelsSupplierType] to String,
/// and [decode] dynamic data back to [ModelsSupplierType].
class ModelsSupplierTypeTypeTransformer {
  factory ModelsSupplierTypeTypeTransformer() => _instance ??= const ModelsSupplierTypeTypeTransformer._();

  const ModelsSupplierTypeTypeTransformer._();

  String encode(ModelsSupplierType data) => data.value;

  /// Decodes a [dynamic value][data] to a ModelsSupplierType.
  ///
  /// If [allowNull] is true and the [dynamic value][data] cannot be decoded successfully,
  /// then null is returned. However, if [allowNull] is false and the [dynamic value][data]
  /// cannot be decoded successfully, then an [UnimplementedError] is thrown.
  ///
  /// The [allowNull] is very handy when an API changes and a new enum value is added or removed,
  /// and users are still using an old app with the old code.
  ModelsSupplierType? decode(dynamic data, {bool allowNull = true}) {
    if (data != null) {
      switch (data) {
        case r'manufacturer': return ModelsSupplierType.SupplierManufacturer;
        case r'wholesaler': return ModelsSupplierType.SupplierWholesaler;
        case r'agent': return ModelsSupplierType.SupplierAgent;
        case r'other': return ModelsSupplierType.SupplierOther;
        default:
          if (!allowNull) {
            throw ArgumentError('Unknown enum value to decode: $data');
          }
      }
    }
    return null;
  }

  /// Singleton [ModelsSupplierTypeTypeTransformer] instance.
  static ModelsSupplierTypeTypeTransformer? _instance;
}

