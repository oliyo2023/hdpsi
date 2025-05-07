import 'package:flutter/material.dart';
import '../models/supplier.dart';
import '../services/supplier_service.dart';

class SupplierProvider with ChangeNotifier {
  final SupplierService _supplierService;

  List<Supplier> _suppliers = [];
  List<Supplier> get suppliers => _suppliers;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  SupplierProvider(this._supplierService);

  Future<void> fetchSuppliers() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _suppliers = await _supplierService.getSuppliers();
    } catch (e) {
      _errorMessage = 'Failed to fetch suppliers: ${e.toString()}';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> createSupplier(Supplier supplier) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _supplierService.createSupplier(supplier);
      // After creating, refresh the list
      fetchSuppliers();
    } catch (e) {
      _errorMessage = 'Failed to create supplier: ${e.toString()}';
      _isLoading = false; // Stop loading on error
      notifyListeners();
    }
  }

  Future<void> updateSupplier(Supplier supplier) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _supplierService.updateSupplier(supplier);
      // After updating, refresh the list
      fetchSuppliers();
    } catch (e) {
      _errorMessage = 'Failed to update supplier: ${e.toString()}';
      _isLoading = false; // Stop loading on error
      notifyListeners();
    }
  }

  // TODO: Add method for deleting suppliers
}
