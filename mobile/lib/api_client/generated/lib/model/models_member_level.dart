//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.12

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;


class ModelsMemberLevel {
  /// Instantiate a new enum with the provided [value].
  const ModelsMemberLevel._(this.value);

  /// The underlying value of this enum member.
  final String value;

  @override
  String toString() => value;

  String toJson() => value;

  static const Regular = ModelsMemberLevel._(r'regular');
  static const Silver = ModelsMemberLevel._(r'silver');
  static const Gold = ModelsMemberLevel._(r'gold');
  static const Platinum = ModelsMemberLevel._(r'platinum');
  static const Diamond = ModelsMemberLevel._(r'diamond');

  /// List of all possible values in this [enum][ModelsMemberLevel].
  static const values = <ModelsMemberLevel>[
    Regular,
    Silver,
    Gold,
    Platinum,
    Diamond,
  ];

  static ModelsMemberLevel? fromJson(dynamic value) => ModelsMemberLevelTypeTransformer().decode(value);

  static List<ModelsMemberLevel> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <ModelsMemberLevel>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = ModelsMemberLevel.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }
}

/// Transformation class that can [encode] an instance of [ModelsMemberLevel] to String,
/// and [decode] dynamic data back to [ModelsMemberLevel].
class ModelsMemberLevelTypeTransformer {
  factory ModelsMemberLevelTypeTransformer() => _instance ??= const ModelsMemberLevelTypeTransformer._();

  const ModelsMemberLevelTypeTransformer._();

  String encode(ModelsMemberLevel data) => data.value;

  /// Decodes a [dynamic value][data] to a ModelsMemberLevel.
  ///
  /// If [allowNull] is true and the [dynamic value][data] cannot be decoded successfully,
  /// then null is returned. However, if [allowNull] is false and the [dynamic value][data]
  /// cannot be decoded successfully, then an [UnimplementedError] is thrown.
  ///
  /// The [allowNull] is very handy when an API changes and a new enum value is added or removed,
  /// and users are still using an old app with the old code.
  ModelsMemberLevel? decode(dynamic data, {bool allowNull = true}) {
    if (data != null) {
      switch (data) {
        case r'regular': return ModelsMemberLevel.Regular;
        case r'silver': return ModelsMemberLevel.Silver;
        case r'gold': return ModelsMemberLevel.Gold;
        case r'platinum': return ModelsMemberLevel.Platinum;
        case r'diamond': return ModelsMemberLevel.Diamond;
        default:
          if (!allowNull) {
            throw ArgumentError('Unknown enum value to decode: $data');
          }
      }
    }
    return null;
  }

  /// Singleton [ModelsMemberLevelTypeTransformer] instance.
  static ModelsMemberLevelTypeTransformer? _instance;
}

