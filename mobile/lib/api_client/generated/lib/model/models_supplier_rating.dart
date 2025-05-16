//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.12

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;


class ModelsSupplierRating {
  /// Instantiate a new enum with the provided [value].
  const ModelsSupplierRating._(this.value);

  /// The underlying value of this enum member.
  final String value;

  @override
  String toString() => value;

  String toJson() => value;

  static const SupplierS = ModelsSupplierRating._(r'S');
  static const SupplierA = ModelsSupplierRating._(r'A');
  static const SupplierB = ModelsSupplierRating._(r'B');
  static const SupplierC = ModelsSupplierRating._(r'C');
  static const SupplierD = ModelsSupplierRating._(r'D');

  /// List of all possible values in this [enum][ModelsSupplierRating].
  static const values = <ModelsSupplierRating>[
    SupplierS,
    SupplierA,
    SupplierB,
    SupplierC,
    SupplierD,
  ];

  static ModelsSupplierRating? fromJson(dynamic value) => ModelsSupplierRatingTypeTransformer().decode(value);

  static List<ModelsSupplierRating> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <ModelsSupplierRating>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = ModelsSupplierRating.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }
}

/// Transformation class that can [encode] an instance of [ModelsSupplierRating] to String,
/// and [decode] dynamic data back to [ModelsSupplierRating].
class ModelsSupplierRatingTypeTransformer {
  factory ModelsSupplierRatingTypeTransformer() => _instance ??= const ModelsSupplierRatingTypeTransformer._();

  const ModelsSupplierRatingTypeTransformer._();

  String encode(ModelsSupplierRating data) => data.value;

  /// Decodes a [dynamic value][data] to a ModelsSupplierRating.
  ///
  /// If [allowNull] is true and the [dynamic value][data] cannot be decoded successfully,
  /// then null is returned. However, if [allowNull] is false and the [dynamic value][data]
  /// cannot be decoded successfully, then an [UnimplementedError] is thrown.
  ///
  /// The [allowNull] is very handy when an API changes and a new enum value is added or removed,
  /// and users are still using an old app with the old code.
  ModelsSupplierRating? decode(dynamic data, {bool allowNull = true}) {
    if (data != null) {
      switch (data) {
        case r'S': return ModelsSupplierRating.SupplierS;
        case r'A': return ModelsSupplierRating.SupplierA;
        case r'B': return ModelsSupplierRating.SupplierB;
        case r'C': return ModelsSupplierRating.SupplierC;
        case r'D': return ModelsSupplierRating.SupplierD;
        default:
          if (!allowNull) {
            throw ArgumentError('Unknown enum value to decode: $data');
          }
      }
    }
    return null;
  }

  /// Singleton [ModelsSupplierRatingTypeTransformer] instance.
  static ModelsSupplierRatingTypeTransformer? _instance;
}

