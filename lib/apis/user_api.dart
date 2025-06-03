import 'package:dio/dio.dart';
import 'package:shop_com/data/config/app_config.dart';

import '../data/model/user.dart';
import 'base_api.dart';
import 'package:async/async.dart';

mixin UserApi on BaseApi {
  Future<List<User>> fetchUsers() async {
    Result result = await handleRequest(
      request: () async {
        return get('/User/list');
      },
    );
    try {
      final List rawList = result.asValue!.value;
      return rawList.map((e) => User.fromJson(e)).toList();
    } catch (e) {
      return [];
    }
  }

  Future<User> getUserInfo() async {
    Result result = await handleRequest(
      request: () => get('/api/users/profile'),
    );
    try {
      return User.fromJson(result.asValue!.value);
    } catch (e) {
      app_config.printLog("e", " API_FETCH_USER_INFO : ${e.toString()}");
      return User.empty();
    }
  }

  Future<Result> createUser({
    required String code,
    required String username,
    required String name,
    required String password,
    required String des,
    required String role,
    required String phone,
  }) async {
    return handleRequest(
      request: () => post(
        '/User/create',
        data: {
          'code': code,
          'username': username,
          'name': name,
          'password': password,
          'des': des,
          'role': role,
          'phone': phone,
        },
      ),
    );
  }

  Future<Result> signup(
      {required String name,
      required String email,
      required String password}) async {
    return handleRequest(
        request: () => post('/api/users/register',
            data: {'name': name, 'email': email, 'password': password}));
  }

  Future<Result> verifyOtpEmail({
    String? email,
    String? otp,
  }) async {
    return handleRequest(
      request: () => post(
        '/api/users/verify-otp',
        data: {
          'email': email,
          'otp': otp,
        },
      ),
    );
  }

  Future<Result> editUser({
    String? email,
    String? name,
    String? password,
    String? address,
  }) async {
    return handleRequest(
      request: () => put(
        '/api/users/profile',
        data: {
          'email': email,
          'name': name,
          'password': password,
          'address': address,
        },
      ),
    );
  }

  Future<Result> changePassword(
      {required String confirmPassword,
      required String oldPassword,
      required String newPassword}) async {
    return handleRequest(
      request: () => put(
        '/User/changePassword',
        data: {
          'oldPassword': oldPassword,
          'newPassword': newPassword,
          'confirmPassword': confirmPassword
        },
      ),
    );
  }
}
