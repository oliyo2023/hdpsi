//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.12

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;


class ModelsStylePreference {
  /// Instantiate a new enum with the provided [value].
  const ModelsStylePreference._(this.value);

  /// The underlying value of this enum member.
  final String value;

  @override
  String toString() => value;

  String toJson() => value;

  static const Casual = ModelsStylePreference._(r'casual');
  static const Formal = ModelsStylePreference._(r'formal');
  static const Sportswear = ModelsStylePreference._(r'sportswear');
  static const Vintage = ModelsStylePreference._(r'vintage');
  static const Minimalist = ModelsStylePreference._(r'minimalist');
  static const Romantic = ModelsStylePreference._(r'romantic');
  static const Bohemian = ModelsStylePreference._(r'bohemian');
  static const Street = ModelsStylePreference._(r'street');

  /// List of all possible values in this [enum][ModelsStylePreference].
  static const values = <ModelsStylePreference>[
    Casual,
    Formal,
    Sportswear,
    Vintage,
    Minimalist,
    Romantic,
    Bohemian,
    Street,
  ];

  static ModelsStylePreference? fromJson(dynamic value) => ModelsStylePreferenceTypeTransformer().decode(value);

  static List<ModelsStylePreference> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <ModelsStylePreference>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = ModelsStylePreference.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }
}

/// Transformation class that can [encode] an instance of [ModelsStylePreference] to String,
/// and [decode] dynamic data back to [ModelsStylePreference].
class ModelsStylePreferenceTypeTransformer {
  factory ModelsStylePreferenceTypeTransformer() => _instance ??= const ModelsStylePreferenceTypeTransformer._();

  const ModelsStylePreferenceTypeTransformer._();

  String encode(ModelsStylePreference data) => data.value;

  /// Decodes a [dynamic value][data] to a ModelsStylePreference.
  ///
  /// If [allowNull] is true and the [dynamic value][data] cannot be decoded successfully,
  /// then null is returned. However, if [allowNull] is false and the [dynamic value][data]
  /// cannot be decoded successfully, then an [UnimplementedError] is thrown.
  ///
  /// The [allowNull] is very handy when an API changes and a new enum value is added or removed,
  /// and users are still using an old app with the old code.
  ModelsStylePreference? decode(dynamic data, {bool allowNull = true}) {
    if (data != null) {
      switch (data) {
        case r'casual': return ModelsStylePreference.Casual;
        case r'formal': return ModelsStylePreference.Formal;
        case r'sportswear': return ModelsStylePreference.Sportswear;
        case r'vintage': return ModelsStylePreference.Vintage;
        case r'minimalist': return ModelsStylePreference.Minimalist;
        case r'romantic': return ModelsStylePreference.Romantic;
        case r'bohemian': return ModelsStylePreference.Bohemian;
        case r'street': return ModelsStylePreference.Street;
        default:
          if (!allowNull) {
            throw ArgumentError('Unknown enum value to decode: $data');
          }
      }
    }
    return null;
  }

  /// Singleton [ModelsStylePreferenceTypeTransformer] instance.
  static ModelsStylePreferenceTypeTransformer? _instance;
}

