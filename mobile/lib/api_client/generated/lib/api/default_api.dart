//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.12

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;


class DefaultApi {
  DefaultApi([ApiClient? apiClient]) : apiClient = apiClient ?? defaultApiClient;

  final ApiClient apiClient;

  /// 获取库存列表
  ///
  /// 获取库存列表，支持按产品变体和店铺筛选，并支持分页
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [int] productVariantId:
  ///   产品变体ID
  ///
  /// * [int] storeId:
  ///   店铺ID
  ///
  /// * [int] page:
  ///   页码，默认1
  ///
  /// * [int] pageSize:
  ///   每页数量，默认10
  Future<Response> inventoryGetWithHttpInfo({ int? productVariantId, int? storeId, int? page, int? pageSize, }) async {
    // ignore: prefer_const_declarations
    final path = r'/inventory';

    // ignore: prefer_final_locals
    Object? postBody;

    final queryParams = <QueryParam>[];
    final headerParams = <String, String>{};
    final formParams = <String, String>{};

    if (productVariantId != null) {
      queryParams.addAll(_queryParams('', 'product_variant_id', productVariantId));
    }
    if (storeId != null) {
      queryParams.addAll(_queryParams('', 'store_id', storeId));
    }
    if (page != null) {
      queryParams.addAll(_queryParams('', 'page', page));
    }
    if (pageSize != null) {
      queryParams.addAll(_queryParams('', 'pageSize', pageSize));
    }

    const contentTypes = <String>[];


    return apiClient.invokeAPI(
      path,
      'GET',
      queryParams,
      postBody,
      headerParams,
      formParams,
      contentTypes.isEmpty ? null : contentTypes.first,
    );
  }

  /// 获取库存列表
  ///
  /// 获取库存列表，支持按产品变体和店铺筛选，并支持分页
  ///
  /// Parameters:
  ///
  /// * [int] productVariantId:
  ///   产品变体ID
  ///
  /// * [int] storeId:
  ///   店铺ID
  ///
  /// * [int] page:
  ///   页码，默认1
  ///
  /// * [int] pageSize:
  ///   每页数量，默认10
  Future<InventoryGet200Response?> inventoryGet({ int? productVariantId, int? storeId, int? page, int? pageSize, }) async {
    final response = await inventoryGetWithHttpInfo( productVariantId: productVariantId, storeId: storeId, page: page, pageSize: pageSize, );
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'InventoryGet200Response',) as InventoryGet200Response;
    
    }
    return null;
  }

  /// 删除库存
  ///
  /// 删除指定ID的库存记录，此操作不可逆
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [int] id (required):
  ///   库存ID
  Future<Response> inventoryIdDeleteWithHttpInfo(int id,) async {
    // ignore: prefer_const_declarations
    final path = r'/inventory/{id}'
      .replaceAll('{id}', id.toString());

    // ignore: prefer_final_locals
    Object? postBody;

    final queryParams = <QueryParam>[];
    final headerParams = <String, String>{};
    final formParams = <String, String>{};

    const contentTypes = <String>[];


    return apiClient.invokeAPI(
      path,
      'DELETE',
      queryParams,
      postBody,
      headerParams,
      formParams,
      contentTypes.isEmpty ? null : contentTypes.first,
    );
  }

  /// 删除库存
  ///
  /// 删除指定ID的库存记录，此操作不可逆
  ///
  /// Parameters:
  ///
  /// * [int] id (required):
  ///   库存ID
  Future<ModelsAPIResponse?> inventoryIdDelete(int id,) async {
    final response = await inventoryIdDeleteWithHttpInfo(id,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'ModelsAPIResponse',) as ModelsAPIResponse;
    
    }
    return null;
  }

  /// 获取库存详情
  ///
  /// 根据ID获取库存的详细信息，包括产品变体和店铺信息
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [int] id (required):
  ///   库存ID
  Future<Response> inventoryIdGetWithHttpInfo(int id,) async {
    // ignore: prefer_const_declarations
    final path = r'/inventory/{id}'
      .replaceAll('{id}', id.toString());

    // ignore: prefer_final_locals
    Object? postBody;

    final queryParams = <QueryParam>[];
    final headerParams = <String, String>{};
    final formParams = <String, String>{};

    const contentTypes = <String>[];


    return apiClient.invokeAPI(
      path,
      'GET',
      queryParams,
      postBody,
      headerParams,
      formParams,
      contentTypes.isEmpty ? null : contentTypes.first,
    );
  }

  /// 获取库存详情
  ///
  /// 根据ID获取库存的详细信息，包括产品变体和店铺信息
  ///
  /// Parameters:
  ///
  /// * [int] id (required):
  ///   库存ID
  Future<ModelsInventory?> inventoryIdGet(int id,) async {
    final response = await inventoryIdGetWithHttpInfo(id,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'ModelsInventory',) as ModelsInventory;
    
    }
    return null;
  }

  /// 更新库存
  ///
  /// 更新现有库存记录，可以修改库存数量并提供更新原因
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [int] id (required):
  ///   库存ID
  ///
  /// * [Object] inventory (required):
  ///   库存信息
  Future<Response> inventoryIdPutWithHttpInfo(int id, Object inventory,) async {
    // ignore: prefer_const_declarations
    final path = r'/inventory/{id}'
      .replaceAll('{id}', id.toString());

    // ignore: prefer_final_locals
    Object? postBody = inventory;

    final queryParams = <QueryParam>[];
    final headerParams = <String, String>{};
    final formParams = <String, String>{};

    const contentTypes = <String>['application/json'];


    return apiClient.invokeAPI(
      path,
      'PUT',
      queryParams,
      postBody,
      headerParams,
      formParams,
      contentTypes.isEmpty ? null : contentTypes.first,
    );
  }

  /// 更新库存
  ///
  /// 更新现有库存记录，可以修改库存数量并提供更新原因
  ///
  /// Parameters:
  ///
  /// * [int] id (required):
  ///   库存ID
  ///
  /// * [Object] inventory (required):
  ///   库存信息
  Future<ModelsInventory?> inventoryIdPut(int id, Object inventory,) async {
    final response = await inventoryIdPutWithHttpInfo(id, inventory,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'ModelsInventory',) as ModelsInventory;
    
    }
    return null;
  }

  /// 创建库存
  ///
  /// 创建新的库存记录，需提供产品变体ID、店铺ID和库存数量
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [ModelsInventory] inventory (required):
  ///   库存信息
  Future<Response> inventoryPostWithHttpInfo(ModelsInventory inventory,) async {
    // ignore: prefer_const_declarations
    final path = r'/inventory';

    // ignore: prefer_final_locals
    Object? postBody = inventory;

    final queryParams = <QueryParam>[];
    final headerParams = <String, String>{};
    final formParams = <String, String>{};

    const contentTypes = <String>['application/json'];


    return apiClient.invokeAPI(
      path,
      'POST',
      queryParams,
      postBody,
      headerParams,
      formParams,
      contentTypes.isEmpty ? null : contentTypes.first,
    );
  }

  /// 创建库存
  ///
  /// 创建新的库存记录，需提供产品变体ID、店铺ID和库存数量
  ///
  /// Parameters:
  ///
  /// * [ModelsInventory] inventory (required):
  ///   库存信息
  Future<ModelsInventory?> inventoryPost(ModelsInventory inventory,) async {
    final response = await inventoryPostWithHttpInfo(inventory,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'ModelsInventory',) as ModelsInventory;
    
    }
    return null;
  }

  /// 获取会员列表
  ///
  /// 获取会员列表，支持按名称、手机号和等级筛选，并支持分页
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [String] name:
  ///   会员名称（模糊查询）
  ///
  /// * [String] phone:
  ///   手机号码（模糊查询）
  ///
  /// * [String] level:
  ///   会员等级
  ///
  /// * [int] page:
  ///   页码，默认1
  ///
  /// * [int] pageSize:
  ///   每页数量，默认10
  Future<Response> membersGetWithHttpInfo({ String? name, String? phone, String? level, int? page, int? pageSize, }) async {
    // ignore: prefer_const_declarations
    final path = r'/members';

    // ignore: prefer_final_locals
    Object? postBody;

    final queryParams = <QueryParam>[];
    final headerParams = <String, String>{};
    final formParams = <String, String>{};

    if (name != null) {
      queryParams.addAll(_queryParams('', 'name', name));
    }
    if (phone != null) {
      queryParams.addAll(_queryParams('', 'phone', phone));
    }
    if (level != null) {
      queryParams.addAll(_queryParams('', 'level', level));
    }
    if (page != null) {
      queryParams.addAll(_queryParams('', 'page', page));
    }
    if (pageSize != null) {
      queryParams.addAll(_queryParams('', 'pageSize', pageSize));
    }

    const contentTypes = <String>[];


    return apiClient.invokeAPI(
      path,
      'GET',
      queryParams,
      postBody,
      headerParams,
      formParams,
      contentTypes.isEmpty ? null : contentTypes.first,
    );
  }

  /// 获取会员列表
  ///
  /// 获取会员列表，支持按名称、手机号和等级筛选，并支持分页
  ///
  /// Parameters:
  ///
  /// * [String] name:
  ///   会员名称（模糊查询）
  ///
  /// * [String] phone:
  ///   手机号码（模糊查询）
  ///
  /// * [String] level:
  ///   会员等级
  ///
  /// * [int] page:
  ///   页码，默认1
  ///
  /// * [int] pageSize:
  ///   每页数量，默认10
  Future<MembersGet200Response?> membersGet({ String? name, String? phone, String? level, int? page, int? pageSize, }) async {
    final response = await membersGetWithHttpInfo( name: name, phone: phone, level: level, page: page, pageSize: pageSize, );
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'MembersGet200Response',) as MembersGet200Response;
    
    }
    return null;
  }

  /// 删除会员
  ///
  /// 删除指定ID的会员，此操作不可逆
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [int] id (required):
  ///   会员ID
  Future<Response> membersIdDeleteWithHttpInfo(int id,) async {
    // ignore: prefer_const_declarations
    final path = r'/members/{id}'
      .replaceAll('{id}', id.toString());

    // ignore: prefer_final_locals
    Object? postBody;

    final queryParams = <QueryParam>[];
    final headerParams = <String, String>{};
    final formParams = <String, String>{};

    const contentTypes = <String>[];


    return apiClient.invokeAPI(
      path,
      'DELETE',
      queryParams,
      postBody,
      headerParams,
      formParams,
      contentTypes.isEmpty ? null : contentTypes.first,
    );
  }

  /// 删除会员
  ///
  /// 删除指定ID的会员，此操作不可逆
  ///
  /// Parameters:
  ///
  /// * [int] id (required):
  ///   会员ID
  Future<ModelsAPIResponse?> membersIdDelete(int id,) async {
    final response = await membersIdDeleteWithHttpInfo(id,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'ModelsAPIResponse',) as ModelsAPIResponse;
    
    }
    return null;
  }

  /// 获取会员详情
  ///
  /// 根据ID获取会员的详细信息，包括基本信息、等级、积分等
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [int] id (required):
  ///   会员ID
  Future<Response> membersIdGetWithHttpInfo(int id,) async {
    // ignore: prefer_const_declarations
    final path = r'/members/{id}'
      .replaceAll('{id}', id.toString());

    // ignore: prefer_final_locals
    Object? postBody;

    final queryParams = <QueryParam>[];
    final headerParams = <String, String>{};
    final formParams = <String, String>{};

    const contentTypes = <String>[];


    return apiClient.invokeAPI(
      path,
      'GET',
      queryParams,
      postBody,
      headerParams,
      formParams,
      contentTypes.isEmpty ? null : contentTypes.first,
    );
  }

  /// 获取会员详情
  ///
  /// 根据ID获取会员的详细信息，包括基本信息、等级、积分等
  ///
  /// Parameters:
  ///
  /// * [int] id (required):
  ///   会员ID
  Future<ModelsMember?> membersIdGet(int id,) async {
    final response = await membersIdGetWithHttpInfo(id,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'ModelsMember',) as ModelsMember;
    
    }
    return null;
  }

  /// 更新会员
  ///
  /// 更新现有会员的信息，需提供完整的会员信息
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [int] id (required):
  ///   会员ID
  ///
  /// * [ModelsMember] member (required):
  ///   会员信息
  Future<Response> membersIdPutWithHttpInfo(int id, ModelsMember member,) async {
    // ignore: prefer_const_declarations
    final path = r'/members/{id}'
      .replaceAll('{id}', id.toString());

    // ignore: prefer_final_locals
    Object? postBody = member;

    final queryParams = <QueryParam>[];
    final headerParams = <String, String>{};
    final formParams = <String, String>{};

    const contentTypes = <String>['application/json'];


    return apiClient.invokeAPI(
      path,
      'PUT',
      queryParams,
      postBody,
      headerParams,
      formParams,
      contentTypes.isEmpty ? null : contentTypes.first,
    );
  }

  /// 更新会员
  ///
  /// 更新现有会员的信息，需提供完整的会员信息
  ///
  /// Parameters:
  ///
  /// * [int] id (required):
  ///   会员ID
  ///
  /// * [ModelsMember] member (required):
  ///   会员信息
  Future<ModelsMember?> membersIdPut(int id, ModelsMember member,) async {
    final response = await membersIdPutWithHttpInfo(id, member,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'ModelsMember',) as ModelsMember;
    
    }
    return null;
  }

  /// 创建会员
  ///
  /// 创建新的会员，需提供必要的会员信息
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [ModelsMember] member (required):
  ///   会员信息
  Future<Response> membersPostWithHttpInfo(ModelsMember member,) async {
    // ignore: prefer_const_declarations
    final path = r'/members';

    // ignore: prefer_final_locals
    Object? postBody = member;

    final queryParams = <QueryParam>[];
    final headerParams = <String, String>{};
    final formParams = <String, String>{};

    const contentTypes = <String>['application/json'];


    return apiClient.invokeAPI(
      path,
      'POST',
      queryParams,
      postBody,
      headerParams,
      formParams,
      contentTypes.isEmpty ? null : contentTypes.first,
    );
  }

  /// 创建会员
  ///
  /// 创建新的会员，需提供必要的会员信息
  ///
  /// Parameters:
  ///
  /// * [ModelsMember] member (required):
  ///   会员信息
  Future<MembersPost201Response?> membersPost(ModelsMember member,) async {
    final response = await membersPostWithHttpInfo(member,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'MembersPost201Response',) as MembersPost201Response;
    
    }
    return null;
  }

  /// 获取商品列表
  ///
  /// 获取商品列表，支持按名称、SKU、分类等条件筛选，并支持分页
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [String] name:
  ///   商品名称（模糊查询）
  ///
  /// * [String] sku:
  ///   商品SKU（模糊查询）
  ///
  /// * [String] category:
  ///   商品分类
  ///
  /// * [String] categoryId:
  ///   商品分类ID
  ///
  /// * [int] page:
  ///   页码，默认1
  ///
  /// * [int] pageSize:
  ///   每页数量，默认10
  Future<Response> productsGetWithHttpInfo({ String? name, String? sku, String? category, String? categoryId, int? page, int? pageSize, }) async {
    // ignore: prefer_const_declarations
    final path = r'/products';

    // ignore: prefer_final_locals
    Object? postBody;

    final queryParams = <QueryParam>[];
    final headerParams = <String, String>{};
    final formParams = <String, String>{};

    if (name != null) {
      queryParams.addAll(_queryParams('', 'name', name));
    }
    if (sku != null) {
      queryParams.addAll(_queryParams('', 'sku', sku));
    }
    if (category != null) {
      queryParams.addAll(_queryParams('', 'category', category));
    }
    if (categoryId != null) {
      queryParams.addAll(_queryParams('', 'category_id', categoryId));
    }
    if (page != null) {
      queryParams.addAll(_queryParams('', 'page', page));
    }
    if (pageSize != null) {
      queryParams.addAll(_queryParams('', 'pageSize', pageSize));
    }

    const contentTypes = <String>[];


    return apiClient.invokeAPI(
      path,
      'GET',
      queryParams,
      postBody,
      headerParams,
      formParams,
      contentTypes.isEmpty ? null : contentTypes.first,
    );
  }

  /// 获取商品列表
  ///
  /// 获取商品列表，支持按名称、SKU、分类等条件筛选，并支持分页
  ///
  /// Parameters:
  ///
  /// * [String] name:
  ///   商品名称（模糊查询）
  ///
  /// * [String] sku:
  ///   商品SKU（模糊查询）
  ///
  /// * [String] category:
  ///   商品分类
  ///
  /// * [String] categoryId:
  ///   商品分类ID
  ///
  /// * [int] page:
  ///   页码，默认1
  ///
  /// * [int] pageSize:
  ///   每页数量，默认10
  Future<ProductsGet200Response?> productsGet({ String? name, String? sku, String? category, String? categoryId, int? page, int? pageSize, }) async {
    final response = await productsGetWithHttpInfo( name: name, sku: sku, category: category, categoryId: categoryId, page: page, pageSize: pageSize, );
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'ProductsGet200Response',) as ProductsGet200Response;
    
    }
    return null;
  }

  /// 获取商品详情
  ///
  /// 根据ID获取商品的详细信息，包括基本信息、变体、价格等
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [int] id (required):
  ///   商品ID
  Future<Response> productsIdGetWithHttpInfo(int id,) async {
    // ignore: prefer_const_declarations
    final path = r'/products/{id}'
      .replaceAll('{id}', id.toString());

    // ignore: prefer_final_locals
    Object? postBody;

    final queryParams = <QueryParam>[];
    final headerParams = <String, String>{};
    final formParams = <String, String>{};

    const contentTypes = <String>[];


    return apiClient.invokeAPI(
      path,
      'GET',
      queryParams,
      postBody,
      headerParams,
      formParams,
      contentTypes.isEmpty ? null : contentTypes.first,
    );
  }

  /// 获取商品详情
  ///
  /// 根据ID获取商品的详细信息，包括基本信息、变体、价格等
  ///
  /// Parameters:
  ///
  /// * [int] id (required):
  ///   商品ID
  Future<ModelsProduct?> productsIdGet(int id,) async {
    final response = await productsIdGetWithHttpInfo(id,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'ModelsProduct',) as ModelsProduct;
    
    }
    return null;
  }

  /// 更新商品
  ///
  /// 更新现有商品及其变体，需提供完整的商品信息
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [int] id (required):
  ///   商品ID
  ///
  /// * [Object] product (required):
  ///   商品信息
  Future<Response> productsIdPutWithHttpInfo(int id, Object product,) async {
    // ignore: prefer_const_declarations
    final path = r'/products/{id}'
      .replaceAll('{id}', id.toString());

    // ignore: prefer_final_locals
    Object? postBody = product;

    final queryParams = <QueryParam>[];
    final headerParams = <String, String>{};
    final formParams = <String, String>{};

    const contentTypes = <String>['application/json'];


    return apiClient.invokeAPI(
      path,
      'PUT',
      queryParams,
      postBody,
      headerParams,
      formParams,
      contentTypes.isEmpty ? null : contentTypes.first,
    );
  }

  /// 更新商品
  ///
  /// 更新现有商品及其变体，需提供完整的商品信息
  ///
  /// Parameters:
  ///
  /// * [int] id (required):
  ///   商品ID
  ///
  /// * [Object] product (required):
  ///   商品信息
  Future<ModelsProduct?> productsIdPut(int id, Object product,) async {
    final response = await productsIdPutWithHttpInfo(id, product,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'ModelsProduct',) as ModelsProduct;
    
    }
    return null;
  }

  /// 创建商品
  ///
  /// 创建新的商品及其变体，需提供商品基本信息和变体信息
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [Object] product (required):
  ///   商品信息
  Future<Response> productsPostWithHttpInfo(Object product,) async {
    // ignore: prefer_const_declarations
    final path = r'/products';

    // ignore: prefer_final_locals
    Object? postBody = product;

    final queryParams = <QueryParam>[];
    final headerParams = <String, String>{};
    final formParams = <String, String>{};

    const contentTypes = <String>['application/json'];


    return apiClient.invokeAPI(
      path,
      'POST',
      queryParams,
      postBody,
      headerParams,
      formParams,
      contentTypes.isEmpty ? null : contentTypes.first,
    );
  }

  /// 创建商品
  ///
  /// 创建新的商品及其变体，需提供商品基本信息和变体信息
  ///
  /// Parameters:
  ///
  /// * [Object] product (required):
  ///   商品信息
  Future<ModelsProduct?> productsPost(Object product,) async {
    final response = await productsPostWithHttpInfo(product,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'ModelsProduct',) as ModelsProduct;
    
    }
    return null;
  }

  /// 获取供应商列表
  ///
  /// 获取供应商列表，支持按名称、编码、类型和状态筛选，并支持分页
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [String] name:
  ///   供应商名称（模糊查询）
  ///
  /// * [String] code:
  ///   供应商编码（模糊查询）
  ///
  /// * [String] type:
  ///   供应商类型
  ///
  /// * [String] status:
  ///   状态
  ///
  /// * [int] page:
  ///   页码，默认1
  ///
  /// * [int] limit:
  ///   每页数量，默认10
  Future<Response> suppliersGetWithHttpInfo({ String? name, String? code, String? type, String? status, int? page, int? limit, }) async {
    // ignore: prefer_const_declarations
    final path = r'/suppliers';

    // ignore: prefer_final_locals
    Object? postBody;

    final queryParams = <QueryParam>[];
    final headerParams = <String, String>{};
    final formParams = <String, String>{};

    if (name != null) {
      queryParams.addAll(_queryParams('', 'name', name));
    }
    if (code != null) {
      queryParams.addAll(_queryParams('', 'code', code));
    }
    if (type != null) {
      queryParams.addAll(_queryParams('', 'type', type));
    }
    if (status != null) {
      queryParams.addAll(_queryParams('', 'status', status));
    }
    if (page != null) {
      queryParams.addAll(_queryParams('', 'page', page));
    }
    if (limit != null) {
      queryParams.addAll(_queryParams('', 'limit', limit));
    }

    const contentTypes = <String>[];


    return apiClient.invokeAPI(
      path,
      'GET',
      queryParams,
      postBody,
      headerParams,
      formParams,
      contentTypes.isEmpty ? null : contentTypes.first,
    );
  }

  /// 获取供应商列表
  ///
  /// 获取供应商列表，支持按名称、编码、类型和状态筛选，并支持分页
  ///
  /// Parameters:
  ///
  /// * [String] name:
  ///   供应商名称（模糊查询）
  ///
  /// * [String] code:
  ///   供应商编码（模糊查询）
  ///
  /// * [String] type:
  ///   供应商类型
  ///
  /// * [String] status:
  ///   状态
  ///
  /// * [int] page:
  ///   页码，默认1
  ///
  /// * [int] limit:
  ///   每页数量，默认10
  Future<SuppliersGet200Response?> suppliersGet({ String? name, String? code, String? type, String? status, int? page, int? limit, }) async {
    final response = await suppliersGetWithHttpInfo( name: name, code: code, type: type, status: status, page: page, limit: limit, );
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'SuppliersGet200Response',) as SuppliersGet200Response;
    
    }
    return null;
  }

  /// 删除供应商
  ///
  /// 删除指定ID的供应商，如果供应商已被采购单引用则无法删除
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [int] id (required):
  ///   供应商ID
  Future<Response> suppliersIdDeleteWithHttpInfo(int id,) async {
    // ignore: prefer_const_declarations
    final path = r'/suppliers/{id}'
      .replaceAll('{id}', id.toString());

    // ignore: prefer_final_locals
    Object? postBody;

    final queryParams = <QueryParam>[];
    final headerParams = <String, String>{};
    final formParams = <String, String>{};

    const contentTypes = <String>[];


    return apiClient.invokeAPI(
      path,
      'DELETE',
      queryParams,
      postBody,
      headerParams,
      formParams,
      contentTypes.isEmpty ? null : contentTypes.first,
    );
  }

  /// 删除供应商
  ///
  /// 删除指定ID的供应商，如果供应商已被采购单引用则无法删除
  ///
  /// Parameters:
  ///
  /// * [int] id (required):
  ///   供应商ID
  Future<ModelsAPIResponse?> suppliersIdDelete(int id,) async {
    final response = await suppliersIdDeleteWithHttpInfo(id,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'ModelsAPIResponse',) as ModelsAPIResponse;
    
    }
    return null;
  }

  /// 获取供应商详情
  ///
  /// 根据ID获取供应商的详细信息，包括基本信息、联系方式、评级等
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [int] id (required):
  ///   供应商ID
  Future<Response> suppliersIdGetWithHttpInfo(int id,) async {
    // ignore: prefer_const_declarations
    final path = r'/suppliers/{id}'
      .replaceAll('{id}', id.toString());

    // ignore: prefer_final_locals
    Object? postBody;

    final queryParams = <QueryParam>[];
    final headerParams = <String, String>{};
    final formParams = <String, String>{};

    const contentTypes = <String>[];


    return apiClient.invokeAPI(
      path,
      'GET',
      queryParams,
      postBody,
      headerParams,
      formParams,
      contentTypes.isEmpty ? null : contentTypes.first,
    );
  }

  /// 获取供应商详情
  ///
  /// 根据ID获取供应商的详细信息，包括基本信息、联系方式、评级等
  ///
  /// Parameters:
  ///
  /// * [int] id (required):
  ///   供应商ID
  Future<ModelsSupplier?> suppliersIdGet(int id,) async {
    final response = await suppliersIdGetWithHttpInfo(id,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'ModelsSupplier',) as ModelsSupplier;
    
    }
    return null;
  }

  /// 更新供应商
  ///
  /// 更新现有供应商的信息，需提供完整的供应商信息
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [int] id (required):
  ///   供应商ID
  ///
  /// * [ControllersCreateSupplierRequest] supplier (required):
  ///   供应商信息
  Future<Response> suppliersIdPutWithHttpInfo(int id, ControllersCreateSupplierRequest supplier,) async {
    // ignore: prefer_const_declarations
    final path = r'/suppliers/{id}'
      .replaceAll('{id}', id.toString());

    // ignore: prefer_final_locals
    Object? postBody = supplier;

    final queryParams = <QueryParam>[];
    final headerParams = <String, String>{};
    final formParams = <String, String>{};

    const contentTypes = <String>['application/json'];


    return apiClient.invokeAPI(
      path,
      'PUT',
      queryParams,
      postBody,
      headerParams,
      formParams,
      contentTypes.isEmpty ? null : contentTypes.first,
    );
  }

  /// 更新供应商
  ///
  /// 更新现有供应商的信息，需提供完整的供应商信息
  ///
  /// Parameters:
  ///
  /// * [int] id (required):
  ///   供应商ID
  ///
  /// * [ControllersCreateSupplierRequest] supplier (required):
  ///   供应商信息
  Future<ModelsSupplier?> suppliersIdPut(int id, ControllersCreateSupplierRequest supplier,) async {
    final response = await suppliersIdPutWithHttpInfo(id, supplier,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'ModelsSupplier',) as ModelsSupplier;
    
    }
    return null;
  }

  /// 创建供应商
  ///
  /// 创建新的供应商，需提供必要的供应商信息
  ///
  /// Note: This method returns the HTTP [Response].
  ///
  /// Parameters:
  ///
  /// * [ControllersCreateSupplierRequest] supplier (required):
  ///   供应商信息
  Future<Response> suppliersPostWithHttpInfo(ControllersCreateSupplierRequest supplier,) async {
    // ignore: prefer_const_declarations
    final path = r'/suppliers';

    // ignore: prefer_final_locals
    Object? postBody = supplier;

    final queryParams = <QueryParam>[];
    final headerParams = <String, String>{};
    final formParams = <String, String>{};

    const contentTypes = <String>['application/json'];


    return apiClient.invokeAPI(
      path,
      'POST',
      queryParams,
      postBody,
      headerParams,
      formParams,
      contentTypes.isEmpty ? null : contentTypes.first,
    );
  }

  /// 创建供应商
  ///
  /// 创建新的供应商，需提供必要的供应商信息
  ///
  /// Parameters:
  ///
  /// * [ControllersCreateSupplierRequest] supplier (required):
  ///   供应商信息
  Future<ModelsSupplier?> suppliersPost(ControllersCreateSupplierRequest supplier,) async {
    final response = await suppliersPostWithHttpInfo(supplier,);
    if (response.statusCode >= HttpStatus.badRequest) {
      throw ApiException(response.statusCode, await _decodeBodyBytes(response));
    }
    // When a remote server returns no body with a status of 204, we shall not decode it.
    // At the time of writing this, `dart:convert` will throw an "Unexpected end of input"
    // FormatException when trying to decode an empty string.
    if (response.body.isNotEmpty && response.statusCode != HttpStatus.noContent) {
      return await apiClient.deserializeAsync(await _decodeBodyBytes(response), 'ModelsSupplier',) as ModelsSupplier;
    
    }
    return null;
  }
}
