//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.12

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class ControllersCreateSupplierRequest {
  /// Returns a new [ControllersCreateSupplierRequest] instance.
  ControllersCreateSupplierRequest({
    required this.code,
    required this.name,
    required this.type,
    this.address,
    this.city,
    this.contactPerson,
    this.contactPhone,
    this.deliveryTerms,
    this.email,
    this.note,
    this.paymentTerms,
    this.qualification,
    this.rating,
    this.status,
  });

  String code;

  String name;

  ModelsSupplierType type;

  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? address;

  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? city;

  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? contactPerson;

  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? contactPhone;

  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? deliveryTerms;

  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? email;

  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? note;

  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? paymentTerms;

  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? qualification;

  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  ModelsSupplierRating? rating;

  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  bool? status;

  @override
  bool operator ==(Object other) => identical(this, other) || other is ControllersCreateSupplierRequest &&
     other.code == code &&
     other.name == name &&
     other.type == type &&
     other.address == address &&
     other.city == city &&
     other.contactPerson == contactPerson &&
     other.contactPhone == contactPhone &&
     other.deliveryTerms == deliveryTerms &&
     other.email == email &&
     other.note == note &&
     other.paymentTerms == paymentTerms &&
     other.qualification == qualification &&
     other.rating == rating &&
     other.status == status;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (code.hashCode) +
    (name.hashCode) +
    (type.hashCode) +
    (address == null ? 0 : address!.hashCode) +
    (city == null ? 0 : city!.hashCode) +
    (contactPerson == null ? 0 : contactPerson!.hashCode) +
    (contactPhone == null ? 0 : contactPhone!.hashCode) +
    (deliveryTerms == null ? 0 : deliveryTerms!.hashCode) +
    (email == null ? 0 : email!.hashCode) +
    (note == null ? 0 : note!.hashCode) +
    (paymentTerms == null ? 0 : paymentTerms!.hashCode) +
    (qualification == null ? 0 : qualification!.hashCode) +
    (rating == null ? 0 : rating!.hashCode) +
    (status == null ? 0 : status!.hashCode);

  @override
  String toString() => 'ControllersCreateSupplierRequest[code=$code, name=$name, type=$type, address=$address, city=$city, contactPerson=$contactPerson, contactPhone=$contactPhone, deliveryTerms=$deliveryTerms, email=$email, note=$note, paymentTerms=$paymentTerms, qualification=$qualification, rating=$rating, status=$status]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'code'] = this.code;
      json[r'name'] = this.name;
      json[r'type'] = this.type;
    if (this.address != null) {
      json[r'address'] = this.address;
    } else {
      json[r'address'] = null;
    }
    if (this.city != null) {
      json[r'city'] = this.city;
    } else {
      json[r'city'] = null;
    }
    if (this.contactPerson != null) {
      json[r'contact_person'] = this.contactPerson;
    } else {
      json[r'contact_person'] = null;
    }
    if (this.contactPhone != null) {
      json[r'contact_phone'] = this.contactPhone;
    } else {
      json[r'contact_phone'] = null;
    }
    if (this.deliveryTerms != null) {
      json[r'delivery_terms'] = this.deliveryTerms;
    } else {
      json[r'delivery_terms'] = null;
    }
    if (this.email != null) {
      json[r'email'] = this.email;
    } else {
      json[r'email'] = null;
    }
    if (this.note != null) {
      json[r'note'] = this.note;
    } else {
      json[r'note'] = null;
    }
    if (this.paymentTerms != null) {
      json[r'payment_terms'] = this.paymentTerms;
    } else {
      json[r'payment_terms'] = null;
    }
    if (this.qualification != null) {
      json[r'qualification'] = this.qualification;
    } else {
      json[r'qualification'] = null;
    }
    if (this.rating != null) {
      json[r'rating'] = this.rating;
    } else {
      json[r'rating'] = null;
    }
    if (this.status != null) {
      json[r'status'] = this.status;
    } else {
      json[r'status'] = null;
    }
    return json;
  }

  /// Returns a new [ControllersCreateSupplierRequest] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static ControllersCreateSupplierRequest? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key), 'Required key "ControllersCreateSupplierRequest[$key]" is missing from JSON.');
          assert(json[key] != null, 'Required key "ControllersCreateSupplierRequest[$key]" has a null value in JSON.');
        });
        return true;
      }());

      return ControllersCreateSupplierRequest(
        code: mapValueOfType<String>(json, r'code')!,
        name: mapValueOfType<String>(json, r'name')!,
        type: ModelsSupplierType.fromJson(json[r'type'])!,
        address: mapValueOfType<String>(json, r'address'),
        city: mapValueOfType<String>(json, r'city'),
        contactPerson: mapValueOfType<String>(json, r'contact_person'),
        contactPhone: mapValueOfType<String>(json, r'contact_phone'),
        deliveryTerms: mapValueOfType<String>(json, r'delivery_terms'),
        email: mapValueOfType<String>(json, r'email'),
        note: mapValueOfType<String>(json, r'note'),
        paymentTerms: mapValueOfType<String>(json, r'payment_terms'),
        qualification: mapValueOfType<String>(json, r'qualification'),
        rating: ModelsSupplierRating.fromJson(json[r'rating']),
        status: mapValueOfType<bool>(json, r'status'),
      );
    }
    return null;
  }

  static List<ControllersCreateSupplierRequest> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <ControllersCreateSupplierRequest>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = ControllersCreateSupplierRequest.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, ControllersCreateSupplierRequest> mapFromJson(dynamic json) {
    final map = <String, ControllersCreateSupplierRequest>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = ControllersCreateSupplierRequest.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of ControllersCreateSupplierRequest-objects as value to a dart map
  static Map<String, List<ControllersCreateSupplierRequest>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<ControllersCreateSupplierRequest>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = ControllersCreateSupplierRequest.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'code',
    'name',
    'type',
  };
}

