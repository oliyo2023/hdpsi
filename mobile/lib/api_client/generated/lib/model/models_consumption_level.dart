//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.12

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;


class ModelsConsumptionLevel {
  /// Instantiate a new enum with the provided [value].
  const ModelsConsumptionLevel._(this.value);

  /// The underlying value of this enum member.
  final String value;

  @override
  String toString() => value;

  String toJson() => value;

  static const Low = ModelsConsumptionLevel._(r'low');
  static const Medium = ModelsConsumptionLevel._(r'medium');
  static const High = ModelsConsumptionLevel._(r'high');
  static const Luxury = ModelsConsumptionLevel._(r'luxury');

  /// List of all possible values in this [enum][ModelsConsumptionLevel].
  static const values = <ModelsConsumptionLevel>[
    Low,
    Medium,
    High,
    Luxury,
  ];

  static ModelsConsumptionLevel? fromJson(dynamic value) => ModelsConsumptionLevelTypeTransformer().decode(value);

  static List<ModelsConsumptionLevel> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <ModelsConsumptionLevel>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = ModelsConsumptionLevel.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }
}

/// Transformation class that can [encode] an instance of [ModelsConsumptionLevel] to String,
/// and [decode] dynamic data back to [ModelsConsumptionLevel].
class ModelsConsumptionLevelTypeTransformer {
  factory ModelsConsumptionLevelTypeTransformer() => _instance ??= const ModelsConsumptionLevelTypeTransformer._();

  const ModelsConsumptionLevelTypeTransformer._();

  String encode(ModelsConsumptionLevel data) => data.value;

  /// Decodes a [dynamic value][data] to a ModelsConsumptionLevel.
  ///
  /// If [allowNull] is true and the [dynamic value][data] cannot be decoded successfully,
  /// then null is returned. However, if [allowNull] is false and the [dynamic value][data]
  /// cannot be decoded successfully, then an [UnimplementedError] is thrown.
  ///
  /// The [allowNull] is very handy when an API changes and a new enum value is added or removed,
  /// and users are still using an old app with the old code.
  ModelsConsumptionLevel? decode(dynamic data, {bool allowNull = true}) {
    if (data != null) {
      switch (data) {
        case r'low': return ModelsConsumptionLevel.Low;
        case r'medium': return ModelsConsumptionLevel.Medium;
        case r'high': return ModelsConsumptionLevel.High;
        case r'luxury': return ModelsConsumptionLevel.Luxury;
        default:
          if (!allowNull) {
            throw ArgumentError('Unknown enum value to decode: $data');
          }
      }
    }
    return null;
  }

  /// Singleton [ModelsConsumptionLevelTypeTransformer] instance.
  static ModelsConsumptionLevelTypeTransformer? _instance;
}

