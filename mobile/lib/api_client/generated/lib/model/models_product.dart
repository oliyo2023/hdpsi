//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.12

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class ModelsProduct {
  /// Returns a new [ModelsProduct] instance.
  ModelsProduct({
    this.brand,
    this.brandID,
    this.category,
    this.categoryID,
    this.costPrice,
    this.createdAt,
    this.description,
    this.ID,
    this.image,
    this.images = const [],
    this.name,
    this.retailPrice,
    this.SKU,
    this.status,
    this.updatedAt,
    this.variants = const [],
  });

  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  ModelsProductBrand? brand;

  /// 品牌ID
  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  int? brandID;

  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  ModelsProductCategory? category;

  /// 商品类别ID
  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  int? categoryID;

  /// 成本价
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

  /// 商品描述
  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? description;

  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  int? ID;

  /// 主图
  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? image;

  /// 多张图片，不存储在数据库中，使用ProductImage关联
  List<String> images;

  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? name;

  /// 零售价
  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  double? retailPrice;

  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? SKU;

  /// 状态：上架/下架
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

  /// 商品变体
  List<ModelsProductVariant> variants;

  @override
  bool operator ==(Object other) => identical(this, other) || other is ModelsProduct &&
     other.brand == brand &&
     other.brandID == brandID &&
     other.category == category &&
     other.categoryID == categoryID &&
     other.costPrice == costPrice &&
     other.createdAt == createdAt &&
     other.description == description &&
     other.ID == ID &&
     other.image == image &&
     other.images == images &&
     other.name == name &&
     other.retailPrice == retailPrice &&
     other.SKU == SKU &&
     other.status == status &&
     other.updatedAt == updatedAt &&
     other.variants == variants;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (brand == null ? 0 : brand!.hashCode) +
    (brandID == null ? 0 : brandID!.hashCode) +
    (category == null ? 0 : category!.hashCode) +
    (categoryID == null ? 0 : categoryID!.hashCode) +
    (costPrice == null ? 0 : costPrice!.hashCode) +
    (createdAt == null ? 0 : createdAt!.hashCode) +
    (description == null ? 0 : description!.hashCode) +
    (ID == null ? 0 : ID!.hashCode) +
    (image == null ? 0 : image!.hashCode) +
    (images.hashCode) +
    (name == null ? 0 : name!.hashCode) +
    (retailPrice == null ? 0 : retailPrice!.hashCode) +
    (SKU == null ? 0 : SKU!.hashCode) +
    (status == null ? 0 : status!.hashCode) +
    (updatedAt == null ? 0 : updatedAt!.hashCode) +
    (variants.hashCode);

  @override
  String toString() => 'ModelsProduct[brand=$brand, brandID=$brandID, category=$category, categoryID=$categoryID, costPrice=$costPrice, createdAt=$createdAt, description=$description, ID=$ID, image=$image, images=$images, name=$name, retailPrice=$retailPrice, SKU=$SKU, status=$status, updatedAt=$updatedAt, variants=$variants]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
    if (this.brand != null) {
      json[r'Brand'] = this.brand;
    } else {
      json[r'Brand'] = null;
    }
    if (this.brandID != null) {
      json[r'BrandID'] = this.brandID;
    } else {
      json[r'BrandID'] = null;
    }
    if (this.category != null) {
      json[r'Category'] = this.category;
    } else {
      json[r'Category'] = null;
    }
    if (this.categoryID != null) {
      json[r'CategoryID'] = this.categoryID;
    } else {
      json[r'CategoryID'] = null;
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
    if (this.description != null) {
      json[r'Description'] = this.description;
    } else {
      json[r'Description'] = null;
    }
    if (this.ID != null) {
      json[r'ID'] = this.ID;
    } else {
      json[r'ID'] = null;
    }
    if (this.image != null) {
      json[r'Image'] = this.image;
    } else {
      json[r'Image'] = null;
    }
      json[r'Images'] = this.images;
    if (this.name != null) {
      json[r'Name'] = this.name;
    } else {
      json[r'Name'] = null;
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
      json[r'Variants'] = this.variants;
    return json;
  }

  /// Returns a new [ModelsProduct] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static ModelsProduct? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key), 'Required key "ModelsProduct[$key]" is missing from JSON.');
          assert(json[key] != null, 'Required key "ModelsProduct[$key]" has a null value in JSON.');
        });
        return true;
      }());

      return ModelsProduct(
        brand: ModelsProductBrand.fromJson(json[r'Brand']),
        brandID: mapValueOfType<int>(json, r'BrandID'),
        category: ModelsProductCategory.fromJson(json[r'Category']),
        categoryID: mapValueOfType<int>(json, r'CategoryID'),
        costPrice: json[r'CostPrice'] == null
            ? null
            : double.parse(json[r'CostPrice'].toString()),
        createdAt: mapValueOfType<String>(json, r'CreatedAt'),
        description: mapValueOfType<String>(json, r'Description'),
        ID: mapValueOfType<int>(json, r'ID'),
        image: mapValueOfType<String>(json, r'Image'),
        images: json[r'Images'] is List
            ? (json[r'Images'] as List).cast<String>()
            : const [],
        name: mapValueOfType<String>(json, r'Name'),
        retailPrice: json[r'RetailPrice'] == null
            ? null
            : double.parse(json[r'RetailPrice'].toString()),
        SKU: mapValueOfType<String>(json, r'SKU'),
        status: mapValueOfType<bool>(json, r'Status'),
        updatedAt: mapValueOfType<String>(json, r'UpdatedAt'),
        variants: ModelsProductVariant.listFromJson(json[r'Variants']),
      );
    }
    return null;
  }

  static List<ModelsProduct> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <ModelsProduct>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = ModelsProduct.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, ModelsProduct> mapFromJson(dynamic json) {
    final map = <String, ModelsProduct>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = ModelsProduct.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of ModelsProduct-objects as value to a dart map
  static Map<String, List<ModelsProduct>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<ModelsProduct>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = ModelsProduct.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
  };
}

