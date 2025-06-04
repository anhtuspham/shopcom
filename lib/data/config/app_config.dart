import 'dart:convert';

import 'package:encrypt/encrypt.dart' as EncryptSys;
import 'package:logger/logger.dart';
import 'package:shop_com/data/model/auth_user.dart';
import 'package:shop_com/providers/auth_provider.dart';
import 'package:shop_com/utils/app_color.dart';

import '../../apis/base_api.dart';
import '../../utils/data_store.dart';

const bool app_encryption = false;
final EncryptSys.IV app_iv = EncryptSys.IV.fromUtf8('uUuGe4Zw1F4rGbOs');
final EncryptSys.Key app_key = EncryptSys.Key.fromUtf8('G3jxGfmjXOztJAyxA8zNFsJ33hZVFzap');

final logger = Logger(
  filter: null, // Use the default LogFilter (-> only log in debug mode)
  printer: PrettyPrinter(
    methodCount: 2,
    // Number of method calls to be displayed
    errorMethodCount: 8,
    // Number of method calls if stacktrace is provided
    lineLength: 120,
    // Width of the output
    colors: true,
    // Colorful log messages
    printEmojis: true, // Print an emoji for each log message
  ), // Use the PrettyPrinter to format and print log
  output: null, // Use the default LogOutput (-> send everything to console)
);

class AppConfig {
  final DataStore app_dataStore = DataStore(key: app_key, iv: app_iv, isEncryption: app_encryption);
  final List<ItemAppColor> store_color = [];
  String _selected_color = "";

  AuthUser? _user;

  AuthUser? get user => _user;

  void set user(AuthUser? tmp) {
    _user = tmp;
  }

  AppColor? get appColor {
    ItemAppColor? tmp = store_color
        .where((s) => s.code.compareTo(_selected_color) == 0)
        .firstOrNull;
    if (tmp == null) {
      return null;
    } else {
      return tmp.keys;
    }
  }

  Future<void> init() async{
    await app_dataStore.initStore();
    loadUser();
  }

  void printLog(String type, String txt) {
    switch (type) {
      case "i":
        logger.i(txt);
        break;
      case "d":
        logger.d(txt);
        break;
      case "e":
        logger.e(txt);
        break;
      default:
        logger.i(txt);
        break;
    }
  }

  Future<bool> saveUser() async {
    if (user != null) {
      try {
        String data = jsonEncode(user!);
        return app_dataStore.saveToLocal("AuthUser", data).then((value) {
          return value;
        });
      } catch (e) {
        printLog("e", e.toString());
        return false;
      }
    } else {
      return app_dataStore.saveToLocal("AuthUser", "").then((value) {
        return false;
      });
      // return false;
    }
  }

  void loadUser() {
    try {
      final String? data = app_dataStore.loadFromLocal("AuthUser");
      if (data == null || data.isEmpty) {
        _user = null;
      } else {
        Map<String, dynamic> map = jsonDecode(data);
        _user = AuthUser.fromJson(map);
      }
    } catch (e) {
      printLog("e", e.toString());
      _user = null;
    }
  }

  void clearUser() {
    try {
      app_dataStore.deleteLocal("AuthUser");
      _user = null;
      reloadApiUrl();
      // final String? data = app_dataStore.loadFromLocal("AuthUser");
      // if(data == null || data.isEmpty) {
      //   _user = null;
      // } else {
      //   Map<String, dynamic> map = jsonDecode(data);
      //   _user = AuthUser.fromJson(map);
      // }
    } catch (e) {
      printLog("e", e.toString());
      _user = null;
    }
  }
}

final AppConfig app_config = AppConfig();
final AuthProvider authProvider = AuthProvider();
Api api = Api();

void reloadApiUrl() {
  api = Api();
}