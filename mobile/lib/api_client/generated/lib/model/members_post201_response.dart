//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.12

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class MembersPost201Response {
  /// Returns a new [MembersPost201Response] instance.
  MembersPost201Response({
    this.data,
    this.modelsPeriodAPIResponse,
  });

  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  ModelsMember? data;

  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  ModelsAPIResponse? modelsPeriodAPIResponse;

  @override
  bool operator ==(Object other) => identical(this, other) || other is MembersPost201Response &&
     other.data == data &&
     other.modelsPeriodAPIResponse == modelsPeriodAPIResponse;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (data == null ? 0 : data!.hashCode) +
    (modelsPeriodAPIResponse == null ? 0 : modelsPeriodAPIResponse!.hashCode);

  @override
  String toString() => 'MembersPost201Response[data=$data, modelsPeriodAPIResponse=$modelsPeriodAPIResponse]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
    if (this.data != null) {
      json[r'data'] = this.data;
    } else {
      json[r'data'] = null;
    }
    if (this.modelsPeriodAPIResponse != null) {
      json[r'models.APIResponse'] = this.modelsPeriodAPIResponse;
    } else {
      json[r'models.APIResponse'] = null;
    }
    return json;
  }

  /// Returns a new [MembersPost201Response] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static MembersPost201Response? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key), 'Required key "MembersPost201Response[$key]" is missing from JSON.');
          assert(json[key] != null, 'Required key "MembersPost201Response[$key]" has a null value in JSON.');
        });
        return true;
      }());

      return MembersPost201Response(
        data: ModelsMember.fromJson(json[r'data']),
        modelsPeriodAPIResponse: ModelsAPIResponse.fromJson(json[r'models.APIResponse']),
      );
    }
    return null;
  }

  static List<MembersPost201Response> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <MembersPost201Response>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = MembersPost201Response.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, MembersPost201Response> mapFromJson(dynamic json) {
    final map = <String, MembersPost201Response>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = MembersPost201Response.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of MembersPost201Response-objects as value to a dart map
  static Map<String, List<MembersPost201Response>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<MembersPost201Response>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = MembersPost201Response.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
  };
}

