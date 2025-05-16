import 'dart:io';
import 'package:dio/dio.dart';
import 'package:http_parser/http_parser.dart';
import 'package:hd_psi_mobile/models/product.dart';
import 'package:hd_psi_mobile/utils/config.dart';
import 'package:hd_psi_mobile/utils/logger.dart';
import 'package:hd_psi_mobile/services/api_service.dart';

class ProductService {
  final ApiService _apiService = ApiService();

  // 获取商品列表
  Future<Map<String, dynamic>> getProducts({
    int page = 1,
    int pageSize = 10,
    String? name,
    String? sku,
    int? categoryId,
  }) async {
    try {
      Map<String, dynamic> params = {'page': page, 'pageSize': pageSize};

      if (name != null && name.isNotEmpty) {
        params['name'] = name;
      }

      if (sku != null && sku.isNotEmpty) {
        params['sku'] = sku;
      }

      if (categoryId != null) {
        params['category_id'] = categoryId;
      }

      final response = await _apiService.get(
        AppConfig.productsPath,
        queryParameters: params,
      );

      List<Product> products = [];
      if (response['items'] != null) {
        products = List<Product>.from(
          response['items'].map((item) => Product.fromJson(item)),
        );
      }

      return {
        'items': products,
        'total': response['total'] ?? 0,
        'page': response['page'] ?? 1,
        'pageSize': response['pageSize'] ?? 10,
      };
    } catch (e) {
      rethrow;
    }
  }

  // 获取单个商品
  Future<Product> getProduct(int id) async {
    try {
      final response = await _apiService.get('${AppConfig.productsPath}/$id');

      Logger.d('ProductService', 'Raw API response for product $id: $response');
      return Product.fromJson(response['product']);
    } catch (e) {
      rethrow;
    }
  }

  // 创建商品
  Future<Product> createProduct(
    Product product,
    List<ProductVariant> variants, {
    List<File>? images,
  }) async {
    try {
      // 如果有图片，先上传图片
      List<String> imageUrls = [];
      if (images != null && images.isNotEmpty) {
        imageUrls = await _uploadImages(images);
      }

      // 准备请求数据
      Map<String, dynamic> data = {
        'product': {...product.toJson(), 'Images': imageUrls},
        'variants': variants.map((v) => v.toJson()).toList(),
      };

      final response = await _apiService.post(
        AppConfig.productsPath,
        data: data,
      );

      return Product.fromJson(response['product']);
    } catch (e) {
      rethrow;
    }
  }

  // 更新商品
  Future<Product> updateProduct(
    int id,
    Product product,
    List<ProductVariant> variants, {
    List<File>? newImages,
  }) async {
    try {
      // 如果有新图片，先上传图片
      List<String> imageUrls = List<String>.from(product.images);
      if (newImages != null && newImages.isNotEmpty) {
        List<String> newImageUrls = await _uploadImages(newImages);
        imageUrls.addAll(newImageUrls);
      }

      // 准备请求数据
      Map<String, dynamic> data = {
        'product': {...product.toJson(), 'Images': imageUrls},
        'variants': variants.map((v) => v.toJson()).toList(),
      };

      final response = await _apiService.put(
        '${AppConfig.productsPath}/$id',
        data: data,
      );

      return Product.fromJson(response['product']);
    } catch (e) {
      rethrow;
    }
  }

  // 删除商品
  Future<void> deleteProduct(int id) async {
    try {
      await _apiService.delete('${AppConfig.productsPath}/$id');
    } catch (e) {
      rethrow;
    }
  }

  // 上传图片
  Future<List<String>> _uploadImages(List<File> images) async {
    try {
      List<String> imageUrls = [];

      for (var image in images) {
        String fileName = image.path.split('/').last;
        String extension = fileName.split('.').last.toLowerCase();

        FormData formData = FormData.fromMap({
          'file': await MultipartFile.fromFile(
            image.path,
            filename: fileName,
            contentType: MediaType('image', extension),
          ),
        });

        final response = await Dio().post(
          '${AppConfig.apiBaseUrl}/api/upload/image',
          data: formData,
          options: Options(headers: {'Content-Type': 'multipart/form-data'}),
        );

        if (response.statusCode == 200 && response.data['url'] != null) {
          imageUrls.add(response.data['url']);
        }
      }

      return imageUrls;
    } catch (e) {
      rethrow;
    }
  }
}
