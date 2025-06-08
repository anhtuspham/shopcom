import 'package:async/async.dart';
import 'package:shop_com/apis/base_api.dart';
import 'package:shop_com/data/model/product.dart';

import '../data/config/app_config.dart';

mixin RecommendApi on BaseApi {
  Future<List<Product>> fetchRecommendProduct() async {
    Result result = await handleRequest(
      request: () => get('/api/recommend/fetch-product'),
    );
    try {
      final List rawList = result.asValue!.value;
      return safeParseProducts(rawList);
    } catch (e) {
      return [];
    }
  }

  List<Product> safeParseProducts(List rawList) {
    return rawList
        .map<Product?>((e) {
          try {
            return Product.fromJson(e);
          } catch (err) {
            app_config.printLog(
                "e", " API_USER_FETCH_RECOMMEND_PRODUCT : ${err.toString()} ");
            return null;
          }
        })
        .whereType<Product>()
        .toList();
  }
}
