# hd_psi_api.api.DefaultApi

## Load the API package
```dart
import 'package:hd_psi_api/api.dart';
```

All URIs are relative to *http://localhost*

Method | HTTP request | Description
------------- | ------------- | -------------
[**inventoryGet**](DefaultApi.md#inventoryget) | **GET** /inventory | 获取库存列表
[**inventoryIdDelete**](DefaultApi.md#inventoryiddelete) | **DELETE** /inventory/{id} | 删除库存
[**inventoryIdGet**](DefaultApi.md#inventoryidget) | **GET** /inventory/{id} | 获取库存详情
[**inventoryIdPut**](DefaultApi.md#inventoryidput) | **PUT** /inventory/{id} | 更新库存
[**inventoryPost**](DefaultApi.md#inventorypost) | **POST** /inventory | 创建库存
[**membersGet**](DefaultApi.md#membersget) | **GET** /members | 获取会员列表
[**membersIdDelete**](DefaultApi.md#membersiddelete) | **DELETE** /members/{id} | 删除会员
[**membersIdGet**](DefaultApi.md#membersidget) | **GET** /members/{id} | 获取会员详情
[**membersIdPut**](DefaultApi.md#membersidput) | **PUT** /members/{id} | 更新会员
[**membersPost**](DefaultApi.md#memberspost) | **POST** /members | 创建会员
[**productsGet**](DefaultApi.md#productsget) | **GET** /products | 获取商品列表
[**productsIdGet**](DefaultApi.md#productsidget) | **GET** /products/{id} | 获取商品详情
[**productsIdPut**](DefaultApi.md#productsidput) | **PUT** /products/{id} | 更新商品
[**productsPost**](DefaultApi.md#productspost) | **POST** /products | 创建商品
[**suppliersGet**](DefaultApi.md#suppliersget) | **GET** /suppliers | 获取供应商列表
[**suppliersIdDelete**](DefaultApi.md#suppliersiddelete) | **DELETE** /suppliers/{id} | 删除供应商
[**suppliersIdGet**](DefaultApi.md#suppliersidget) | **GET** /suppliers/{id} | 获取供应商详情
[**suppliersIdPut**](DefaultApi.md#suppliersidput) | **PUT** /suppliers/{id} | 更新供应商
[**suppliersPost**](DefaultApi.md#supplierspost) | **POST** /suppliers | 创建供应商


# **inventoryGet**
> InventoryGet200Response inventoryGet(productVariantId, storeId, page, pageSize)

获取库存列表

获取库存列表，支持按产品变体和店铺筛选，并支持分页

### Example
```dart
import 'package:hd_psi_api/api.dart';

final api_instance = DefaultApi();
final productVariantId = 56; // int | 产品变体ID
final storeId = 56; // int | 店铺ID
final page = 56; // int | 页码，默认1
final pageSize = 56; // int | 每页数量，默认10

try {
    final result = api_instance.inventoryGet(productVariantId, storeId, page, pageSize);
    print(result);
} catch (e) {
    print('Exception when calling DefaultApi->inventoryGet: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **productVariantId** | **int**| 产品变体ID | [optional] 
 **storeId** | **int**| 店铺ID | [optional] 
 **page** | **int**| 页码，默认1 | [optional] 
 **pageSize** | **int**| 每页数量，默认10 | [optional] 

### Return type

[**InventoryGet200Response**](InventoryGet200Response.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **inventoryIdDelete**
> ModelsAPIResponse inventoryIdDelete(id)

删除库存

删除指定ID的库存记录，此操作不可逆

### Example
```dart
import 'package:hd_psi_api/api.dart';

final api_instance = DefaultApi();
final id = 56; // int | 库存ID

try {
    final result = api_instance.inventoryIdDelete(id);
    print(result);
} catch (e) {
    print('Exception when calling DefaultApi->inventoryIdDelete: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **int**| 库存ID | 

### Return type

[**ModelsAPIResponse**](ModelsAPIResponse.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **inventoryIdGet**
> ModelsInventory inventoryIdGet(id)

获取库存详情

根据ID获取库存的详细信息，包括产品变体和店铺信息

### Example
```dart
import 'package:hd_psi_api/api.dart';

final api_instance = DefaultApi();
final id = 56; // int | 库存ID

try {
    final result = api_instance.inventoryIdGet(id);
    print(result);
} catch (e) {
    print('Exception when calling DefaultApi->inventoryIdGet: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **int**| 库存ID | 

### Return type

[**ModelsInventory**](ModelsInventory.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **inventoryIdPut**
> ModelsInventory inventoryIdPut(id, inventory)

更新库存

更新现有库存记录，可以修改库存数量并提供更新原因

### Example
```dart
import 'package:hd_psi_api/api.dart';

final api_instance = DefaultApi();
final id = 56; // int | 库存ID
final inventory = Object(); // Object | 库存信息

try {
    final result = api_instance.inventoryIdPut(id, inventory);
    print(result);
} catch (e) {
    print('Exception when calling DefaultApi->inventoryIdPut: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **int**| 库存ID | 
 **inventory** | **Object**| 库存信息 | 

### Return type

[**ModelsInventory**](ModelsInventory.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **inventoryPost**
> ModelsInventory inventoryPost(inventory)

创建库存

创建新的库存记录，需提供产品变体ID、店铺ID和库存数量

### Example
```dart
import 'package:hd_psi_api/api.dart';

final api_instance = DefaultApi();
final inventory = ModelsInventory(); // ModelsInventory | 库存信息

try {
    final result = api_instance.inventoryPost(inventory);
    print(result);
} catch (e) {
    print('Exception when calling DefaultApi->inventoryPost: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **inventory** | [**ModelsInventory**](ModelsInventory.md)| 库存信息 | 

### Return type

[**ModelsInventory**](ModelsInventory.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **membersGet**
> MembersGet200Response membersGet(name, phone, level, page, pageSize)

获取会员列表

获取会员列表，支持按名称、手机号和等级筛选，并支持分页

### Example
```dart
import 'package:hd_psi_api/api.dart';

final api_instance = DefaultApi();
final name = name_example; // String | 会员名称（模糊查询）
final phone = phone_example; // String | 手机号码（模糊查询）
final level = level_example; // String | 会员等级
final page = 56; // int | 页码，默认1
final pageSize = 56; // int | 每页数量，默认10

try {
    final result = api_instance.membersGet(name, phone, level, page, pageSize);
    print(result);
} catch (e) {
    print('Exception when calling DefaultApi->membersGet: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **name** | **String**| 会员名称（模糊查询） | [optional] 
 **phone** | **String**| 手机号码（模糊查询） | [optional] 
 **level** | **String**| 会员等级 | [optional] 
 **page** | **int**| 页码，默认1 | [optional] 
 **pageSize** | **int**| 每页数量，默认10 | [optional] 

### Return type

[**MembersGet200Response**](MembersGet200Response.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **membersIdDelete**
> ModelsAPIResponse membersIdDelete(id)

删除会员

删除指定ID的会员，此操作不可逆

### Example
```dart
import 'package:hd_psi_api/api.dart';

final api_instance = DefaultApi();
final id = 56; // int | 会员ID

try {
    final result = api_instance.membersIdDelete(id);
    print(result);
} catch (e) {
    print('Exception when calling DefaultApi->membersIdDelete: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **int**| 会员ID | 

### Return type

[**ModelsAPIResponse**](ModelsAPIResponse.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **membersIdGet**
> ModelsMember membersIdGet(id)

获取会员详情

根据ID获取会员的详细信息，包括基本信息、等级、积分等

### Example
```dart
import 'package:hd_psi_api/api.dart';

final api_instance = DefaultApi();
final id = 56; // int | 会员ID

try {
    final result = api_instance.membersIdGet(id);
    print(result);
} catch (e) {
    print('Exception when calling DefaultApi->membersIdGet: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **int**| 会员ID | 

### Return type

[**ModelsMember**](ModelsMember.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **membersIdPut**
> ModelsMember membersIdPut(id, member)

更新会员

更新现有会员的信息，需提供完整的会员信息

### Example
```dart
import 'package:hd_psi_api/api.dart';

final api_instance = DefaultApi();
final id = 56; // int | 会员ID
final member = ModelsMember(); // ModelsMember | 会员信息

try {
    final result = api_instance.membersIdPut(id, member);
    print(result);
} catch (e) {
    print('Exception when calling DefaultApi->membersIdPut: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **int**| 会员ID | 
 **member** | [**ModelsMember**](ModelsMember.md)| 会员信息 | 

### Return type

[**ModelsMember**](ModelsMember.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **membersPost**
> MembersPost201Response membersPost(member)

创建会员

创建新的会员，需提供必要的会员信息

### Example
```dart
import 'package:hd_psi_api/api.dart';

final api_instance = DefaultApi();
final member = ModelsMember(); // ModelsMember | 会员信息

try {
    final result = api_instance.membersPost(member);
    print(result);
} catch (e) {
    print('Exception when calling DefaultApi->membersPost: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **member** | [**ModelsMember**](ModelsMember.md)| 会员信息 | 

### Return type

[**MembersPost201Response**](MembersPost201Response.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **productsGet**
> ProductsGet200Response productsGet(name, sku, category, categoryId, page, pageSize)

获取商品列表

获取商品列表，支持按名称、SKU、分类等条件筛选，并支持分页

### Example
```dart
import 'package:hd_psi_api/api.dart';

final api_instance = DefaultApi();
final name = name_example; // String | 商品名称（模糊查询）
final sku = sku_example; // String | 商品SKU（模糊查询）
final category = category_example; // String | 商品分类
final categoryId = categoryId_example; // String | 商品分类ID
final page = 56; // int | 页码，默认1
final pageSize = 56; // int | 每页数量，默认10

try {
    final result = api_instance.productsGet(name, sku, category, categoryId, page, pageSize);
    print(result);
} catch (e) {
    print('Exception when calling DefaultApi->productsGet: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **name** | **String**| 商品名称（模糊查询） | [optional] 
 **sku** | **String**| 商品SKU（模糊查询） | [optional] 
 **category** | **String**| 商品分类 | [optional] 
 **categoryId** | **String**| 商品分类ID | [optional] 
 **page** | **int**| 页码，默认1 | [optional] 
 **pageSize** | **int**| 每页数量，默认10 | [optional] 

### Return type

[**ProductsGet200Response**](ProductsGet200Response.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **productsIdGet**
> ModelsProduct productsIdGet(id)

获取商品详情

根据ID获取商品的详细信息，包括基本信息、变体、价格等

### Example
```dart
import 'package:hd_psi_api/api.dart';

final api_instance = DefaultApi();
final id = 56; // int | 商品ID

try {
    final result = api_instance.productsIdGet(id);
    print(result);
} catch (e) {
    print('Exception when calling DefaultApi->productsIdGet: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **int**| 商品ID | 

### Return type

[**ModelsProduct**](ModelsProduct.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **productsIdPut**
> ModelsProduct productsIdPut(id, product)

更新商品

更新现有商品及其变体，需提供完整的商品信息

### Example
```dart
import 'package:hd_psi_api/api.dart';

final api_instance = DefaultApi();
final id = 56; // int | 商品ID
final product = Object(); // Object | 商品信息

try {
    final result = api_instance.productsIdPut(id, product);
    print(result);
} catch (e) {
    print('Exception when calling DefaultApi->productsIdPut: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **int**| 商品ID | 
 **product** | **Object**| 商品信息 | 

### Return type

[**ModelsProduct**](ModelsProduct.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **productsPost**
> ModelsProduct productsPost(product)

创建商品

创建新的商品及其变体，需提供商品基本信息和变体信息

### Example
```dart
import 'package:hd_psi_api/api.dart';

final api_instance = DefaultApi();
final product = Object(); // Object | 商品信息

try {
    final result = api_instance.productsPost(product);
    print(result);
} catch (e) {
    print('Exception when calling DefaultApi->productsPost: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **product** | **Object**| 商品信息 | 

### Return type

[**ModelsProduct**](ModelsProduct.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **suppliersGet**
> SuppliersGet200Response suppliersGet(name, code, type, status, page, limit)

获取供应商列表

获取供应商列表，支持按名称、编码、类型和状态筛选，并支持分页

### Example
```dart
import 'package:hd_psi_api/api.dart';

final api_instance = DefaultApi();
final name = name_example; // String | 供应商名称（模糊查询）
final code = code_example; // String | 供应商编码（模糊查询）
final type = type_example; // String | 供应商类型
final status = status_example; // String | 状态
final page = 56; // int | 页码，默认1
final limit = 56; // int | 每页数量，默认10

try {
    final result = api_instance.suppliersGet(name, code, type, status, page, limit);
    print(result);
} catch (e) {
    print('Exception when calling DefaultApi->suppliersGet: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **name** | **String**| 供应商名称（模糊查询） | [optional] 
 **code** | **String**| 供应商编码（模糊查询） | [optional] 
 **type** | **String**| 供应商类型 | [optional] 
 **status** | **String**| 状态 | [optional] 
 **page** | **int**| 页码，默认1 | [optional] 
 **limit** | **int**| 每页数量，默认10 | [optional] 

### Return type

[**SuppliersGet200Response**](SuppliersGet200Response.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **suppliersIdDelete**
> ModelsAPIResponse suppliersIdDelete(id)

删除供应商

删除指定ID的供应商，如果供应商已被采购单引用则无法删除

### Example
```dart
import 'package:hd_psi_api/api.dart';

final api_instance = DefaultApi();
final id = 56; // int | 供应商ID

try {
    final result = api_instance.suppliersIdDelete(id);
    print(result);
} catch (e) {
    print('Exception when calling DefaultApi->suppliersIdDelete: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **int**| 供应商ID | 

### Return type

[**ModelsAPIResponse**](ModelsAPIResponse.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **suppliersIdGet**
> ModelsSupplier suppliersIdGet(id)

获取供应商详情

根据ID获取供应商的详细信息，包括基本信息、联系方式、评级等

### Example
```dart
import 'package:hd_psi_api/api.dart';

final api_instance = DefaultApi();
final id = 56; // int | 供应商ID

try {
    final result = api_instance.suppliersIdGet(id);
    print(result);
} catch (e) {
    print('Exception when calling DefaultApi->suppliersIdGet: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **int**| 供应商ID | 

### Return type

[**ModelsSupplier**](ModelsSupplier.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: Not defined
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **suppliersIdPut**
> ModelsSupplier suppliersIdPut(id, supplier)

更新供应商

更新现有供应商的信息，需提供完整的供应商信息

### Example
```dart
import 'package:hd_psi_api/api.dart';

final api_instance = DefaultApi();
final id = 56; // int | 供应商ID
final supplier = ControllersCreateSupplierRequest(); // ControllersCreateSupplierRequest | 供应商信息

try {
    final result = api_instance.suppliersIdPut(id, supplier);
    print(result);
} catch (e) {
    print('Exception when calling DefaultApi->suppliersIdPut: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **id** | **int**| 供应商ID | 
 **supplier** | [**ControllersCreateSupplierRequest**](ControllersCreateSupplierRequest.md)| 供应商信息 | 

### Return type

[**ModelsSupplier**](ModelsSupplier.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

# **suppliersPost**
> ModelsSupplier suppliersPost(supplier)

创建供应商

创建新的供应商，需提供必要的供应商信息

### Example
```dart
import 'package:hd_psi_api/api.dart';

final api_instance = DefaultApi();
final supplier = ControllersCreateSupplierRequest(); // ControllersCreateSupplierRequest | 供应商信息

try {
    final result = api_instance.suppliersPost(supplier);
    print(result);
} catch (e) {
    print('Exception when calling DefaultApi->suppliersPost: $e\n');
}
```

### Parameters

Name | Type | Description  | Notes
------------- | ------------- | ------------- | -------------
 **supplier** | [**ControllersCreateSupplierRequest**](ControllersCreateSupplierRequest.md)| 供应商信息 | 

### Return type

[**ModelsSupplier**](ModelsSupplier.md)

### Authorization

No authorization required

### HTTP request headers

 - **Content-Type**: application/json
 - **Accept**: application/json

[[Back to top]](#) [[Back to API list]](../README.md#documentation-for-api-endpoints) [[Back to Model list]](../README.md#documentation-for-models) [[Back to README]](../README.md)

