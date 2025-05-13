//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.12

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class ModelsInventory {
  /// Returns a new [ModelsInventory] instance.
  ModelsInventory({
    this.alertQuantity,
    this.createdAt,
    this.id,
    this.lastCheckTime,
    this.productVariant,
    this.productVariantID,
    this.quantity,
    this.store,
    this.storeID,
    this.updatedAt,
  });

  /// 预警数量
  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  int? alertQuantity;

  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? createdAt;

  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  int? id;

  /// 最后盘点时间
  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? lastCheckTime;

  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  ModelsInventoryProductVariant? productVariant;

  /// 商品变体ID
  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  int? productVariantID;

  /// 库存数量
  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  int? quantity;

  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  ModelsInventoryStore? store;

  /// 店铺ID
  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  int? storeID;

  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? updatedAt;

  @override
  bool operator ==(Object other) => identical(this, other) || other is ModelsInventory &&
     other.alertQuantity == alertQuantity &&
     other.createdAt == createdAt &&
     other.id == id &&
     other.lastCheckTime == lastCheckTime &&
     other.productVariant == productVariant &&
     other.productVariantID == productVariantID &&
     other.quantity == quantity &&
     other.store == store &&
     other.storeID == storeID &&
     other.updatedAt == updatedAt;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (alertQuantity == null ? 0 : alertQuantity!.hashCode) +
    (createdAt == null ? 0 : createdAt!.hashCode) +
    (id == null ? 0 : id!.hashCode) +
    (lastCheckTime == null ? 0 : lastCheckTime!.hashCode) +
    (productVariant == null ? 0 : productVariant!.hashCode) +
    (productVariantID == null ? 0 : productVariantID!.hashCode) +
    (quantity == null ? 0 : quantity!.hashCode) +
    (store == null ? 0 : store!.hashCode) +
    (storeID == null ? 0 : storeID!.hashCode) +
    (updatedAt == null ? 0 : updatedAt!.hashCode);

  @override
  String toString() => 'ModelsInventory[alertQuantity=$alertQuantity, createdAt=$createdAt, id=$id, lastCheckTime=$lastCheckTime, productVariant=$productVariant, productVariantID=$productVariantID, quantity=$quantity, store=$store, storeID=$storeID, updatedAt=$updatedAt]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
    if (this.alertQuantity != null) {
      json[r'alertQuantity'] = this.alertQuantity;
    } else {
      json[r'alertQuantity'] = null;
    }
    if (this.createdAt != null) {
      json[r'createdAt'] = this.createdAt;
    } else {
      json[r'createdAt'] = null;
    }
    if (this.id != null) {
      json[r'id'] = this.id;
    } else {
      json[r'id'] = null;
    }
    if (this.lastCheckTime != null) {
      json[r'lastCheckTime'] = this.lastCheckTime;
    } else {
      json[r'lastCheckTime'] = null;
    }
    if (this.productVariant != null) {
      json[r'productVariant'] = this.productVariant;
    } else {
      json[r'productVariant'] = null;
    }
    if (this.productVariantID != null) {
      json[r'productVariantID'] = this.productVariantID;
    } else {
      json[r'productVariantID'] = null;
    }
    if (this.quantity != null) {
      json[r'quantity'] = this.quantity;
    } else {
      json[r'quantity'] = null;
    }
    if (this.store != null) {
      json[r'store'] = this.store;
    } else {
      json[r'store'] = null;
    }
    if (this.storeID != null) {
      json[r'storeID'] = this.storeID;
    } else {
      json[r'storeID'] = null;
    }
    if (this.updatedAt != null) {
      json[r'updatedAt'] = this.updatedAt;
    } else {
      json[r'updatedAt'] = null;
    }
    return json;
  }

  /// Returns a new [ModelsInventory] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static ModelsInventory? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key), 'Required key "ModelsInventory[$key]" is missing from JSON.');
          assert(json[key] != null, 'Required key "ModelsInventory[$key]" has a null value in JSON.');
        });
        return true;
      }());

      return ModelsInventory(
        alertQuantity: mapValueOfType<int>(json, r'alertQuantity'),
        createdAt: mapValueOfType<String>(json, r'createdAt'),
        id: mapValueOfType<int>(json, r'id'),
        lastCheckTime: mapValueOfType<String>(json, r'lastCheckTime'),
        productVariant: ModelsInventoryProductVariant.fromJson(json[r'productVariant']),
        productVariantID: mapValueOfType<int>(json, r'productVariantID'),
        quantity: mapValueOfType<int>(json, r'quantity'),
        store: ModelsInventoryStore.fromJson(json[r'store']),
        storeID: mapValueOfType<int>(json, r'storeID'),
        updatedAt: mapValueOfType<String>(json, r'updatedAt'),
      );
    }
    return null;
  }

  static List<ModelsInventory> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <ModelsInventory>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = ModelsInventory.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, ModelsInventory> mapFromJson(dynamic json) {
    final map = <String, ModelsInventory>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = ModelsInventory.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of ModelsInventory-objects as value to a dart map
  static Map<String, List<ModelsInventory>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<ModelsInventory>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = ModelsInventory.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
  };
}

