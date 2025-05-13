# hd_psi_api.model.ModelsProduct

## Load the model package
```dart
import 'package:hd_psi_api/api.dart';
```

## Properties
Name | Type | Description | Notes
------------ | ------------- | ------------- | -------------
**brand** | [**ModelsProductBrand**](ModelsProductBrand.md) |  | [optional] 
**brandID** | **int** | 品牌ID | [optional] 
**category** | [**ModelsProductCategory**](ModelsProductCategory.md) |  | [optional] 
**categoryID** | **int** | 商品类别ID | [optional] 
**costPrice** | **double** | 成本价 | [optional] 
**createdAt** | **String** |  | [optional] 
**description** | **String** | 商品描述 | [optional] 
**ID** | **int** |  | [optional] 
**image** | **String** | 主图 | [optional] 
**images** | **List<String>** | 多张图片，不存储在数据库中，使用ProductImage关联 | [optional] [default to const []]
**name** | **String** |  | [optional] 
**retailPrice** | **double** | 零售价 | [optional] 
**SKU** | **String** |  | [optional] 
**status** | **bool** | 状态：上架/下架 | [optional] 
**updatedAt** | **String** |  | [optional] 
**variants** | [**List<ModelsProductVariant>**](ModelsProductVariant.md) | 商品变体 | [optional] [default to const []]

[[Back to Model list]](../README.md#documentation-for-models) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to README]](../README.md)


