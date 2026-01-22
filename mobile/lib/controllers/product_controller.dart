import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hd_psi_mobile/models/product.dart';
import 'package:hd_psi_mobile/services/product_service.dart';
import 'package:hd_psi_mobile/utils/logger.dart';

/// 商品控制器 (GetX)
///
/// 管理商品相关的状态和业务逻辑
class ProductController extends GetxController {
  final ProductService _productService = ProductService();

  // 响应式状态
  final RxList<Product> _products = <Product>[].obs;
  final Rx<Product?> _selectedProduct = Rx<Product?>(null);
  final RxBool _isLoading = false.obs;
  final RxString _error = ''.obs;
  final RxInt _totalProducts = 0.obs;
  final RxInt _currentPage = 1.obs;
  final RxInt _pageSize = 10.obs;

  // Getters
  List<Product> get products => _products;
  Product? get selectedProduct => _selectedProduct.value;
  bool get isLoading => _isLoading.value;
  String get error => _error.value;
  bool get hasError => _error.value.isNotEmpty;
  int get totalProducts => _totalProducts.value;
  int get currentPage => _currentPage.value;
  int get pageSize => _pageSize.value;
  bool get hasMorePages =>
      _totalProducts.value > _currentPage.value * _pageSize.value;

  /// 加载商品列表
  Future<void> loadProducts({
    int page = 1,
    int pageSize = 10,
    String? name,
    String? sku,
    int? categoryId,
    bool refresh = false,
  }) async {
    try {
      if (refresh) {
        _products.clear();
        _currentPage.value = 1;
      } else {
        _currentPage.value = page;
      }
      _pageSize.value = pageSize;

      _isLoading.value = true;
      _error.value = '';

      final result = await _productService.getProducts(
        page: page,
        pageSize: pageSize,
        name: name,
        sku: sku,
        categoryId: categoryId,
      );

      if (refresh || page == 1) {
        _products.assignAll(result['items']);
      } else {
        _products.addAll(result['items']);
      }

      _totalProducts.value = result['total'];

      Logger.i('ProductController', '成功加载 ${result['items'].length} 个商品');
    } catch (e) {
      _error.value = '加载商品失败: ${e.toString()}';
      Logger.e('ProductController', '加载商品失败: $e');
    } finally {
      _isLoading.value = false;
    }
  }

  /// 加载更多商品
  Future<void> loadMoreProducts({
    String? name,
    String? sku,
    int? categoryId,
  }) async {
    if (_isLoading.value || !hasMorePages) return;

    await loadProducts(
      page: _currentPage.value + 1,
      pageSize: _pageSize.value,
      name: name,
      sku: sku,
      categoryId: categoryId,
    );
  }

  /// 获取单个商品
  Future<Product?> getProduct(int id) async {
    try {
      _isLoading.value = true;
      _error.value = '';

      final product = await _productService.getProduct(id);
      _selectedProduct.value = product;

      Logger.i('ProductController', '成功获取商品详情: ${product.name}');
      return product;
    } catch (e) {
      _error.value = '获取商品详情失败: ${e.toString()}';
      Logger.e('ProductController', '获取商品详情失败: $e');
      return null;
    } finally {
      _isLoading.value = false;
    }
  }

  /// 创建商品
  Future<bool> createProduct(
    Product product,
    List<ProductVariant> variants, {
    List<File>? images,
  }) async {
    try {
      _isLoading.value = true;
      _error.value = '';

      final newProduct = await _productService.createProduct(
        product,
        variants,
        images: images,
      );

      _products.insert(0, newProduct);
      _totalProducts.value += 1;

      Logger.i('ProductController', '成功创建商品: ${newProduct.name}');

      // 显示成功消息
      if (Get.context != null) {
        ScaffoldMessenger.of(
          Get.context!,
        ).showSnackBar(const SnackBar(content: Text('商品创建成功')));
      }

      return true;
    } catch (e) {
      _error.value = '创建商品失败: ${e.toString()}';
      Logger.e('ProductController', '创建商品失败: $e');

      // 显示错误消息
      if (Get.context != null) {
        ScaffoldMessenger.of(
          Get.context!,
        ).showSnackBar(SnackBar(content: Text('创建商品失败: ${e.toString()}')));
      }

      return false;
    } finally {
      _isLoading.value = false;
    }
  }

  /// 更新商品
  Future<bool> updateProduct(
    Product product,
    List<ProductVariant> variants, {
    List<File>? newImages,
    List<String>? deletedImageIds,
  }) async {
    try {
      _isLoading.value = true;
      _error.value = '';

      final updatedProduct = await _productService.updateProduct(
        product.id,
        product,
        variants,
        newImages: newImages,
      );

      // 更新列表中的商品
      final index = _products.indexWhere((p) => p.id == product.id);
      if (index != -1) {
        _products[index] = updatedProduct;
      }

      // 更新选中的商品
      if (_selectedProduct.value?.id == product.id) {
        _selectedProduct.value = updatedProduct;
      }

      Logger.i('ProductController', '成功更新商品: ${updatedProduct.name}');

      // 显示成功消息
      if (Get.context != null) {
        ScaffoldMessenger.of(
          Get.context!,
        ).showSnackBar(const SnackBar(content: Text('商品更新成功')));
      }

      return true;
    } catch (e) {
      _error.value = '更新商品失败: ${e.toString()}';
      Logger.e('ProductController', '更新商品失败: $e');

      // 显示错误消息
      if (Get.context != null) {
        ScaffoldMessenger.of(
          Get.context!,
        ).showSnackBar(SnackBar(content: Text('更新商品失败: ${e.toString()}')));
      }

      return false;
    } finally {
      _isLoading.value = false;
    }
  }

  /// 删除商品
  Future<bool> deleteProduct(int id) async {
    try {
      _isLoading.value = true;
      _error.value = '';

      await _productService.deleteProduct(id);

      // 从列表中移除商品
      _products.removeWhere((p) => p.id == id);
      _totalProducts.value -= 1;

      // 如果删除的是当前选中的商品，清空选中状态
      if (_selectedProduct.value?.id == id) {
        _selectedProduct.value = null;
      }

      Logger.i('ProductController', '成功删除商品: $id');

      // 显示成功消息
      if (Get.context != null) {
        ScaffoldMessenger.of(
          Get.context!,
        ).showSnackBar(const SnackBar(content: Text('商品删除成功')));
      }

      return true;
    } catch (e) {
      _error.value = '删除商品失败: ${e.toString()}';
      Logger.e('ProductController', '删除商品失败: $e');

      // 显示错误消息
      if (Get.context != null) {
        ScaffoldMessenger.of(
          Get.context!,
        ).showSnackBar(SnackBar(content: Text('删除商品失败: ${e.toString()}')));
      }

      return false;
    } finally {
      _isLoading.value = false;
    }
  }

  /// 搜索商品
  Future<void> searchProducts(String keyword) async {
    await loadProducts(name: keyword, refresh: true);
  }

  /// 刷新商品列表
  Future<void> refreshProducts() async {
    await loadProducts(refresh: true);
  }

  /// 清除错误信息
  void clearError() {
    _error.value = '';
  }

  /// 清除选中的商品
  void clearSelectedProduct() {
    _selectedProduct.value = null;
  }
}
