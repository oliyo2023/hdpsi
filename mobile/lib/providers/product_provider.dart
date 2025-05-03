import 'dart:io';
import 'package:flutter/material.dart';
import '../models/product.dart';
import '../services/product_service.dart';

class ProductProvider extends ChangeNotifier {
  final ProductService _productService = ProductService();
  
  List<Product> _products = [];
  Product? _selectedProduct;
  bool _isLoading = false;
  String? _error;
  int _totalProducts = 0;
  int _currentPage = 1;
  int _pageSize = 10;
  
  List<Product> get products => _products;
  Product? get selectedProduct => _selectedProduct;
  bool get isLoading => _isLoading;
  String? get error => _error;
  int get totalProducts => _totalProducts;
  int get currentPage => _currentPage;
  int get pageSize => _pageSize;
  bool get hasMorePages => _totalProducts > _currentPage * _pageSize;
  
  // 加载商品列表
  Future<void> loadProducts({
    int page = 1,
    int pageSize = 10,
    String? name,
    String? sku,
    int? categoryId,
    bool refresh = false,
  }) async {
    if (refresh) {
      _products = [];
      _currentPage = 1;
    } else {
      _currentPage = page;
    }
    _pageSize = pageSize;
    
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      final result = await _productService.getProducts(
        page: page,
        pageSize: pageSize,
        name: name,
        sku: sku,
        categoryId: categoryId,
      );
      
      if (refresh || page == 1) {
        _products = result['items'];
      } else {
        _products.addAll(result['items']);
      }
      
      _totalProducts = result['total'];
      _error = null;
    } catch (e) {
      _error = '加载商品失败: ${e.toString()}';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  // 加载更多商品
  Future<void> loadMoreProducts({
    String? name,
    String? sku,
    int? categoryId,
  }) async {
    if (_isLoading || !hasMorePages) return;
    
    await loadProducts(
      page: _currentPage + 1,
      pageSize: _pageSize,
      name: name,
      sku: sku,
      categoryId: categoryId,
    );
  }
  
  // 获取单个商品
  Future<void> getProduct(int id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      _selectedProduct = await _productService.getProduct(id);
      _error = null;
    } catch (e) {
      _error = '获取商品详情失败: ${e.toString()}';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  // 创建商品
  Future<bool> createProduct(Product product, List<ProductVariant> variants, {List<File>? images}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      final newProduct = await _productService.createProduct(product, variants, images: images);
      _products.insert(0, newProduct);
      _totalProducts += 1;
      _error = null;
      return true;
    } catch (e) {
      _error = '创建商品失败: ${e.toString()}';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  // 更新商品
  Future<bool> updateProduct(int id, Product product, List<ProductVariant> variants, {List<File>? newImages}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      final updatedProduct = await _productService.updateProduct(id, product, variants, newImages: newImages);
      
      // 更新列表中的商品
      final index = _products.indexWhere((p) => p.id == id);
      if (index != -1) {
        _products[index] = updatedProduct;
      }
      
      // 更新选中的商品
      if (_selectedProduct?.id == id) {
        _selectedProduct = updatedProduct;
      }
      
      _error = null;
      return true;
    } catch (e) {
      _error = '更新商品失败: ${e.toString()}';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  // 删除商品
  Future<bool> deleteProduct(int id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      await _productService.deleteProduct(id);
      
      // 从列表中移除商品
      _products.removeWhere((p) => p.id == id);
      _totalProducts -= 1;
      
      // 清除选中的商品
      if (_selectedProduct?.id == id) {
        _selectedProduct = null;
      }
      
      _error = null;
      return true;
    } catch (e) {
      _error = '删除商品失败: ${e.toString()}';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  // 清除选中的商品
  void clearSelectedProduct() {
    _selectedProduct = null;
    notifyListeners();
  }
  
  // 清除错误
  void clearError() {
    _error = null;
    notifyListeners();
  }
}
