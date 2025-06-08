import 'package:dio/dio.dart';
import 'package:shop_com/apis/base_url.dart';
import 'package:shop_com/apis/cart_api.dart';
import 'package:shop_com/apis/favorite_api.dart';
import 'package:shop_com/apis/order_api.dart';
import 'package:shop_com/apis/product_api.dart';
import 'package:shop_com/apis/recommend_api.dart';
import 'package:shop_com/apis/review_api.dart';
import 'package:shop_com/apis/user_api.dart';
import 'package:shop_com/data/config/app_config.dart';
import 'package:async/async.dart';

import 'api_exception.dart';
import 'auth_user_api.dart';
import 'custom_interceptor_api.dart';

class BaseApi{
  String base_url = baseUrl;
  late Dio dio;
  BaseApi(){
    dio = Dio(BaseOptions(
      baseUrl: base_url,
      headers: {
        "Access-Control-Allow-Origin": "*",
        if (app_config.user != null) 'Authorization': 'Bearer ${app_config.user?.token}',
      },
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(minutes: 5),
    ));
    dio.interceptors.add(CustomInterceptorsApi());
  }

  Future<Response> get(
      String path, {
        Map<String, dynamic>? queryParameters,
        Map<String, dynamic>? data,
        CancelToken? cancelToken,
      }) async {
    final response = await dio.get(
      path,
      queryParameters: queryParameters,
      data: data,
      cancelToken: cancelToken,
    );
    return response;
  }

  Future<Response> post(
      String path, {
        Map<String, dynamic>? queryParameters,
        dynamic data,
        FormData? formData,
        CancelToken? cancelToken,
      }) async {
    final response = await dio.post(
      path,
      queryParameters: queryParameters,
      data: formData ?? data,
      cancelToken: cancelToken,
    );
    return response;
  }

  Future<Response> put(
      String path, {
        Map<String, dynamic>? queryParameters,
        dynamic data,
      }) async {
    final response = await dio.put(path, queryParameters: queryParameters, data: data);
    return response;
  }

  Future<Response> delete(
      String path, {
        Map<String, dynamic>? queryParameters,
        Object? data,
      }) async {
    final response = await dio.delete(path, queryParameters: queryParameters, data: data);
    return response;
  }

  Future<Response> patch(
      String path, {
        Map<String, dynamic>? queryParameters,
        Map<String, String?>? data,
      }) async {
    final response = await dio.patch(path, queryParameters: queryParameters, data: data);
    return response;
  }

  Future<Result> handleRequest({
    required Future<Response> Function() request,
  }) async {
    try {
      final response = await request();
      if (response.statusCode == 200 || response.statusCode == 201) {
        return Result.value(response.data);
      } else {
        throw DioException.badResponse(
          statusCode: response.statusCode ?? 400,
          requestOptions: response.requestOptions,
          response: response,
        );
      }
    } on DioException catch (e) {
      final err = AppException.fromDioError(e);
      return Result.error(err.errorMessage);
    } catch (e) {
      return Result.error("Some error happen ${e.toString()}");
    }
  }
}

class Api extends BaseApi with AuthUserApi, UserApi, ProductApi, CartApi, OrderApi, FavoriteApiApi, ReviewApi, RecommendApi{
  Api();
}