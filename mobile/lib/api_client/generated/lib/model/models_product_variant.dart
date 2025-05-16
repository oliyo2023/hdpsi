//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.12

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class ModelsProductVariant {
  /// Returns a new [ModelsProductVariant] instance.
  ModelsProductVariant({
    this.barcode,
    this.color,
    this.colorID,
    this.costPrice,
    this.createdAt,
    this.fabric,
    this.fabricID,
    this.ID,
    this.productID,
    this.qRCode,
    this.retailPrice,
    this.SKU,
    this.season,
    this.seasonID,
    this.size,
    this.sizeID,
    this.status,
    this.updatedAt,
  });

  /// 条形码
  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? barcode;

  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  ModelsProductVariantColor? color;

  /// 颜色ID
  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  int? colorID;

  /// 成本价（可能与主商品不同）
  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  double? costPrice;

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
  ModelsProductVariantFabric? fabric;

  /// 面料ID
  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  int? fabricID;

  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  int? ID;

  /// 关联的商品ID
  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  int? productID;

  /// 二维码数据
  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? qRCode;

  /// 零售价（可能与主商品不同）
  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  double? retailPrice;

  /// 变体SKU
  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? SKU;

  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  ModelsProductVariantSeason? season;

  /// 季节ID
  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  int? seasonID;

  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  ModelsProductVariantSize? size;

  /// 尺码ID
  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  int? sizeID;

  /// 状态：启用/禁用
  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  bool? status;

  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? updatedAt;

  @override
  bool operator ==(Object other) => identical(this, other) || other is ModelsProductVariant &&
     other.barcode == barcode &&
     other.color == color &&
     other.colorID == colorID &&
     other.costPrice == costPrice &&
     other.createdAt == createdAt &&
     other.fabric == fabric &&
     other.fabricID == fabricID &&
     other.ID == ID &&
     other.productID == productID &&
     other.qRCode == qRCode &&
     other.retailPrice == retailPrice &&
     other.SKU == SKU &&
     other.season == season &&
     other.seasonID == seasonID &&
     other.size == size &&
     other.sizeID == sizeID &&
     other.status == status &&
     other.updatedAt == updatedAt;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (barcode == null ? 0 : barcode!.hashCode) +
    (color == null ? 0 : color!.hashCode) +
    (colorID == null ? 0 : colorID!.hashCode) +
    (costPrice == null ? 0 : costPrice!.hashCode) +
    (createdAt == null ? 0 : createdAt!.hashCode) +
    (fabric == null ? 0 : fabric!.hashCode) +
    (fabricID == null ? 0 : fabricID!.hashCode) +
    (ID == null ? 0 : ID!.hashCode) +
    (productID == null ? 0 : productID!.hashCode) +
    (qRCode == null ? 0 : qRCode!.hashCode) +
    (retailPrice == null ? 0 : retailPrice!.hashCode) +
    (SKU == null ? 0 : SKU!.hashCode) +
    (season == null ? 0 : season!.hashCode) +
    (seasonID == null ? 0 : seasonID!.hashCode) +
    (size == null ? 0 : size!.hashCode) +
    (sizeID == null ? 0 : sizeID!.hashCode) +
    (status == null ? 0 : status!.hashCode) +
    (updatedAt == null ? 0 : updatedAt!.hashCode);

  @override
  String toString() => 'ModelsProductVariant[barcode=$barcode, color=$color, colorID=$colorID, costPrice=$costPrice, createdAt=$createdAt, fabric=$fabric, fabricID=$fabricID, ID=$ID, productID=$productID, qRCode=$qRCode, retailPrice=$retailPrice, SKU=$SKU, season=$season, seasonID=$seasonID, size=$size, sizeID=$sizeID, status=$status, updatedAt=$updatedAt]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
    if (this.barcode != null) {
      json[r'Barcode'] = this.barcode;
    } else {
      json[r'Barcode'] = null;
    }
    if (this.color != null) {
      json[r'Color'] = this.color;
    } else {
      json[r'Color'] = null;
    }
    if (this.colorID != null) {
      json[r'ColorID'] = this.colorID;
    } else {
      json[r'ColorID'] = null;
    }
    if (this.costPrice != null) {
      json[r'CostPrice'] = this.costPrice;
    } else {
      json[r'CostPrice'] = null;
    }
    if (this.createdAt != null) {
      json[r'CreatedAt'] = this.createdAt;
    } else {
      json[r'CreatedAt'] = null;
    }
    if (this.fabric != null) {
      json[r'Fabric'] = this.fabric;
    } else {
      json[r'Fabric'] = null;
    }
    if (this.fabricID != null) {
      json[r'FabricID'] = this.fabricID;
    } else {
      json[r'FabricID'] = null;
    }
    if (this.ID != null) {
      json[r'ID'] = this.ID;
    } else {
      json[r'ID'] = null;
    }
    if (this.productID != null) {
      json[r'ProductID'] = this.productID;
    } else {
      json[r'ProductID'] = null;
    }
    if (this.qRCode != null) {
      json[r'QRCode'] = this.qRCode;
    } else {
      json[r'QRCode'] = null;
    }
    if (this.retailPrice != null) {
      json[r'RetailPrice'] = this.retailPrice;
    } else {
      json[r'RetailPrice'] = null;
    }
    if (this.SKU != null) {
      json[r'SKU'] = this.SKU;
    } else {
      json[r'SKU'] = null;
    }
    if (this.season != null) {
      json[r'Season'] = this.season;
    } else {
      json[r'Season'] = null;
    }
    if (this.seasonID != null) {
      json[r'SeasonID'] = this.seasonID;
    } else {
      json[r'SeasonID'] = null;
    }
    if (this.size != null) {
      json[r'Size'] = this.size;
    } else {
      json[r'Size'] = null;
    }
    if (this.sizeID != null) {
      json[r'SizeID'] = this.sizeID;
    } else {
      json[r'SizeID'] = null;
    }
    if (this.status != null) {
      json[r'Status'] = this.status;
    } else {
      json[r'Status'] = null;
    }
    if (this.updatedAt != null) {
      json[r'UpdatedAt'] = this.updatedAt;
    } else {
      json[r'UpdatedAt'] = null;
    }
    return json;
  }

  /// Returns a new [ModelsProductVariant] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static ModelsProductVariant? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key), 'Required key "ModelsProductVariant[$key]" is missing from JSON.');
          assert(json[key] != null, 'Required key "ModelsProductVariant[$key]" has a null value in JSON.');
        });
        return true;
      }());

      return ModelsProductVariant(
        barcode: mapValueOfType<String>(json, r'Barcode'),
        color: ModelsProductVariantColor.fromJson(json[r'Color']),
        colorID: mapValueOfType<int>(json, r'ColorID'),
        costPrice: json[r'CostPrice'] == null
            ? null
            : double.parse(json[r'CostPrice'].toString()),
        createdAt: mapValueOfType<String>(json, r'CreatedAt'),
        fabric: ModelsProductVariantFabric.fromJson(json[r'Fabric']),
        fabricID: mapValueOfType<int>(json, r'FabricID'),
        ID: mapValueOfType<int>(json, r'ID'),
        productID: mapValueOfType<int>(json, r'ProductID'),
        qRCode: mapValueOfType<String>(json, r'QRCode'),
        retailPrice: json[r'RetailPrice'] == null
            ? null
            : double.parse(json[r'RetailPrice'].toString()),
        SKU: mapValueOfType<String>(json, r'SKU'),
        season: ModelsProductVariantSeason.fromJson(json[r'Season']),
        seasonID: mapValueOfType<int>(json, r'SeasonID'),
        size: ModelsProductVariantSize.fromJson(json[r'Size']),
        sizeID: mapValueOfType<int>(json, r'SizeID'),
        status: mapValueOfType<bool>(json, r'Status'),
        updatedAt: mapValueOfType<String>(json, r'UpdatedAt'),
      );
    }
    return null;
  }

  static List<ModelsProductVariant> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <ModelsProductVariant>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = ModelsProductVariant.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, ModelsProductVariant> mapFromJson(dynamic json) {
    final map = <String, ModelsProductVariant>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = ModelsProductVariant.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of ModelsProductVariant-objects as value to a dart map
  static Map<String, List<ModelsProductVariant>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<ModelsProductVariant>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = ModelsProductVariant.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
  };
}

