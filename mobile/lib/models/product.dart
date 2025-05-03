class Product {
  final int id;
  final String sku;
  final String name;
  final int? categoryId;
  final int? brandId;
  final String image;
  final List<String> images;
  final String description;
  final double costPrice;
  final double retailPrice;
  final bool status;
  final String createdAt;
  final String updatedAt;
  final Map<String, dynamic>? category;
  final Map<String, dynamic>? brand;
  final List<ProductVariant>? variants;
  
  Product({
    required this.id,
    required this.sku,
    required this.name,
    this.categoryId,
    this.brandId,
    required this.image,
    required this.images,
    required this.description,
    required this.costPrice,
    required this.retailPrice,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    this.category,
    this.brand,
    this.variants,
  });
  
  factory Product.fromJson(Map<String, dynamic> json) {
    List<String> imagesList = [];
    if (json['Images'] != null) {
      imagesList = List<String>.from(json['Images']);
    }
    
    List<ProductVariant>? variantsList;
    if (json['Variants'] != null) {
      variantsList = List<ProductVariant>.from(
        json['Variants'].map((v) => ProductVariant.fromJson(v))
      );
    }
    
    return Product(
      id: json['ID'],
      sku: json['SKU'],
      name: json['Name'],
      categoryId: json['CategoryID'],
      brandId: json['BrandID'],
      image: json['Image'] ?? '',
      images: imagesList,
      description: json['Description'] ?? '',
      costPrice: json['CostPrice']?.toDouble() ?? 0.0,
      retailPrice: json['RetailPrice']?.toDouble() ?? 0.0,
      status: json['Status'],
      createdAt: json['CreatedAt'],
      updatedAt: json['UpdatedAt'],
      category: json['Category'],
      brand: json['Brand'],
      variants: variantsList,
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'ID': id,
      'SKU': sku,
      'Name': name,
      'CategoryID': categoryId,
      'BrandID': brandId,
      'Image': image,
      'Images': images,
      'Description': description,
      'CostPrice': costPrice,
      'RetailPrice': retailPrice,
      'Status': status,
      'CreatedAt': createdAt,
      'UpdatedAt': updatedAt,
      'Category': category,
      'Brand': brand,
      'Variants': variants?.map((v) => v.toJson()).toList(),
    };
  }
}

class ProductVariant {
  final int id;
  final int productId;
  final String sku;
  final int? colorId;
  final int? sizeId;
  final int? seasonId;
  final int? fabricId;
  final String barcode;
  final String qrCode;
  final double costPrice;
  final double retailPrice;
  final bool status;
  final Map<String, dynamic>? color;
  final Map<String, dynamic>? size;
  final Map<String, dynamic>? season;
  final Map<String, dynamic>? fabric;
  
  ProductVariant({
    required this.id,
    required this.productId,
    required this.sku,
    this.colorId,
    this.sizeId,
    this.seasonId,
    this.fabricId,
    required this.barcode,
    required this.qrCode,
    required this.costPrice,
    required this.retailPrice,
    required this.status,
    this.color,
    this.size,
    this.season,
    this.fabric,
  });
  
  factory ProductVariant.fromJson(Map<String, dynamic> json) {
    return ProductVariant(
      id: json['ID'],
      productId: json['ProductID'],
      sku: json['SKU'],
      colorId: json['ColorID'],
      sizeId: json['SizeID'],
      seasonId: json['SeasonID'],
      fabricId: json['FabricID'],
      barcode: json['Barcode'] ?? '',
      qrCode: json['QRCode'] ?? '',
      costPrice: json['CostPrice']?.toDouble() ?? 0.0,
      retailPrice: json['RetailPrice']?.toDouble() ?? 0.0,
      status: json['Status'],
      color: json['Color'],
      size: json['Size'],
      season: json['Season'],
      fabric: json['Fabric'],
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'ID': id,
      'ProductID': productId,
      'SKU': sku,
      'ColorID': colorId,
      'SizeID': sizeId,
      'SeasonID': seasonId,
      'FabricID': fabricId,
      'Barcode': barcode,
      'QRCode': qrCode,
      'CostPrice': costPrice,
      'RetailPrice': retailPrice,
      'Status': status,
      'Color': color,
      'Size': size,
      'Season': season,
      'Fabric': fabric,
    };
  }
}
