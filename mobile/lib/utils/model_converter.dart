import 'package:hd_psi_mobile/api_client/generated/lib/api.dart' as api;
import '../models/supplier.dart';

/// 模型转换器
///
/// 用于在旧模型和新模型之间进行转换
class ModelConverter {
  /// 将API供应商模型转换为应用供应商模型
  static Supplier apiSupplierToAppSupplier(api.ModelsSupplier apiSupplier) {
    return Supplier(
      id: apiSupplier.id ?? 0,
      name: apiSupplier.name ?? '',
      code: apiSupplier.code ?? '',
      type: _convertSupplierType(apiSupplier.type),
      contactPerson: apiSupplier.contactPerson,
      contactPhone: apiSupplier.contactPhone,
      email: apiSupplier.email,
      address: apiSupplier.address,
      city: apiSupplier.city,
      rating: _convertSupplierRating(apiSupplier.rating),
      qualification: apiSupplier.qualification,
      paymentTerms: apiSupplier.paymentTerms,
      deliveryTerms: apiSupplier.deliveryTerms,
      status: apiSupplier.status ?? true,
      note: apiSupplier.note,
      createdAt: _parseDateTime(apiSupplier.createdAt) ?? DateTime.now(),
      updatedAt: _parseDateTime(apiSupplier.updatedAt) ?? DateTime.now(),
    );
  }

  /// 将应用供应商模型转换为API供应商模型
  static api.ModelsSupplier appSupplierToApiSupplier(Supplier appSupplier) {
    return api.ModelsSupplier(
      id: appSupplier.id,
      name: appSupplier.name,
      code: appSupplier.code,
      type: _convertToApiSupplierType(appSupplier.type),
      contactPerson: appSupplier.contactPerson,
      contactPhone: appSupplier.contactPhone,
      email: appSupplier.email,
      address: appSupplier.address,
      city: appSupplier.city,
      rating:
          appSupplier.rating != null
              ? _convertToApiSupplierRating(appSupplier.rating!)
              : null,
      qualification: appSupplier.qualification,
      paymentTerms: appSupplier.paymentTerms,
      deliveryTerms: appSupplier.deliveryTerms,
      status: appSupplier.status,
      note: appSupplier.note,
      createdAt: appSupplier.createdAt.toIso8601String(),
      updatedAt: appSupplier.updatedAt.toIso8601String(),
    );
  }

  /// 将API供应商类型转换为应用供应商类型
  static SupplierType _convertSupplierType(api.ModelsSupplierType? apiType) {
    if (apiType == null) return SupplierType.other;

    switch (apiType) {
      case api.ModelsSupplierType.SupplierManufacturer:
        return SupplierType.manufacturer;
      case api.ModelsSupplierType.SupplierWholesaler:
        return SupplierType.wholesaler;
      case api.ModelsSupplierType.SupplierAgent:
        return SupplierType.retailer; // 最接近的匹配
      case api.ModelsSupplierType.SupplierOther:
        return SupplierType.other;
      default:
        return SupplierType.other;
    }
  }

  /// 将应用供应商类型转换为API供应商类型
  static api.ModelsSupplierType _convertToApiSupplierType(
    SupplierType appType,
  ) {
    switch (appType) {
      case SupplierType.manufacturer:
        return api.ModelsSupplierType.SupplierManufacturer;
      case SupplierType.wholesaler:
        return api.ModelsSupplierType.SupplierWholesaler;
      case SupplierType.retailer:
        return api.ModelsSupplierType.SupplierAgent; // 最接近的匹配
      case SupplierType.distributor:
        return api.ModelsSupplierType.SupplierWholesaler; // 最接近的匹配
      case SupplierType.other:
        return api.ModelsSupplierType.SupplierOther;
    }
  }

  /// 将API供应商评级转换为应用供应商评级
  static SupplierRating? _convertSupplierRating(
    api.ModelsSupplierRating? apiRating,
  ) {
    if (apiRating == null) return null;

    switch (apiRating) {
      case api.ModelsSupplierRating.SupplierS:
        return SupplierRating.S;
      case api.ModelsSupplierRating.SupplierA:
        return SupplierRating.A;
      case api.ModelsSupplierRating.SupplierB:
        return SupplierRating.B;
      case api.ModelsSupplierRating.SupplierC:
        return SupplierRating.C;
      case api.ModelsSupplierRating.SupplierD:
        return SupplierRating.D;
      default:
        return SupplierRating.C;
    }
  }

  /// 将应用供应商评级转换为API供应商评级
  static api.ModelsSupplierRating _convertToApiSupplierRating(
    SupplierRating appRating,
  ) {
    switch (appRating) {
      case SupplierRating.S:
        return api.ModelsSupplierRating.SupplierS;
      case SupplierRating.A:
        return api.ModelsSupplierRating.SupplierA;
      case SupplierRating.B:
        return api.ModelsSupplierRating.SupplierB;
      case SupplierRating.C:
        return api.ModelsSupplierRating.SupplierC;
      case SupplierRating.D:
        return api.ModelsSupplierRating.SupplierD;
    }
  }

  /// 解析日期时间字符串
  static DateTime? _parseDateTime(String? dateTimeStr) {
    if (dateTimeStr == null || dateTimeStr.isEmpty) return null;
    return DateTime.tryParse(dateTimeStr);
  }
}
