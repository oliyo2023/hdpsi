//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.12

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

library openapi.api;

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart';
import 'package:intl/intl.dart';
import 'package:meta/meta.dart';

part 'api_client.dart';
part 'api_helper.dart';
part 'api_exception.dart';
part 'auth/authentication.dart';
part 'auth/api_key_auth.dart';
part 'auth/oauth.dart';
part 'auth/http_basic_auth.dart';
part 'auth/http_bearer_auth.dart';

part 'api/default_api.dart';

part 'model/controllers_create_supplier_request.dart';
part 'model/inventory_get200_response.dart';
part 'model/members_get200_response.dart';
part 'model/members_post201_response.dart';
part 'model/models_api_response.dart';
part 'model/models_consumption_level.dart';
part 'model/models_dictionary.dart';
part 'model/models_dictionary_item.dart';
part 'model/models_dictionary_item_dictionary.dart';
part 'model/models_error_response.dart';
part 'model/models_inventory.dart';
part 'model/models_inventory_product_variant.dart';
part 'model/models_inventory_store.dart';
part 'model/models_member.dart';
part 'model/models_member_level.dart';
part 'model/models_paginated_response.dart';
part 'model/models_product.dart';
part 'model/models_product_brand.dart';
part 'model/models_product_category.dart';
part 'model/models_product_variant.dart';
part 'model/models_product_variant_color.dart';
part 'model/models_product_variant_fabric.dart';
part 'model/models_product_variant_season.dart';
part 'model/models_product_variant_size.dart';
part 'model/models_store.dart';
part 'model/models_style_preference.dart';
part 'model/models_supplier.dart';
part 'model/models_supplier_rating.dart';
part 'model/models_supplier_type.dart';
part 'model/products_get200_response.dart';
part 'model/suppliers_get200_response.dart';


const _delimiters = {'csv': ',', 'ssv': ' ', 'tsv': '\t', 'pipes': '|'};
const _dateEpochMarker = 'epoch';
final _dateFormatter = DateFormat('yyyy-MM-dd');
final _regList = RegExp(r'^List<(.*)>$');
final _regSet = RegExp(r'^Set<(.*)>$');
final _regMap = RegExp(r'^Map<String,(.*)>$');

ApiClient defaultApiClient = ApiClient();
