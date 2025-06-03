import 'package:async/async.dart';
import 'package:dio/dio.dart';
import '../data/config/app_config.dart';
import '../data/model/auth_user.dart';
import 'base_api.dart';

mixin AuthUserApi on BaseApi {
  static const String PATH_LOGIN = "/api/users/login";
  static const String PATH_RENEWTOKEN = "/User/renewToken";

  Future<AuthUser?> login(String email, String password) async {
    try {
      print('email $email password $password');
      Map<String, dynamic> headers = <String, dynamic>{};
      headers['Content-Type'] = 'application/json';
      headers['accept'] = '*/*';
      Object body = {'email':email, 'password':password};

      Response response = await dio.post(PATH_LOGIN, options: Options(headers: headers), data: body);
      if (response.statusCode == 200) {
        app_config.printLog("i", " API_USER_LOGIN : ${response.data} ");
        AuthUser user = AuthUser.fromJson(response.data);
        if(user.token == null || user.token!.isEmpty) {
          return null;
        } else {
          return user;
        }
      } else {
        return null;
      }
    } catch(e) {
      app_config.printLog("e", " API_USER_LOGIN : ${e.toString()} ");
      return null;
    }
  }

  Future<AuthUser?> renewToken(String token) async {
    try {
      Map<String, dynamic> headers = <String, dynamic>{};
      headers['Content-Type'] = 'application/json';
      headers['accept'] = '*/*';
      headers['Authorization'] = "Bearer $token";
      Response response = await dio.get(PATH_RENEWTOKEN, options: Options(headers: headers), data: null);
      if (response.statusCode == 200) {
        app_config.printLog("i", " API_USER_RENEWTOKEN : ${response.data} ");
        AuthUser user = AuthUser.fromJson(response.data);
        if(user.token == null || user.token!.isEmpty) {
          return null;
        } else {
          return user;
        }
      } else {
        return null;
      }
    } catch(e) {
      app_config.printLog("e", " API_USER_RENEWTOKEN : ${e.toString()} ");
      return null;
    }
  }

}
