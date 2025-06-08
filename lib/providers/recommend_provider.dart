import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/config/app_config.dart';
import '../data/model/product.dart';

class RecommendProductState {
  final List<Product> product;
  final bool isLoading;
  final bool isError;
  final String? errorMessage;

  const RecommendProductState(
      {required this.product,
        this.isLoading = false,
        this.isError = false,
        this.errorMessage});

  factory RecommendProductState.initial() => const RecommendProductState(product: []);

  RecommendProductState copyWith(
      {List<Product>? product, bool? isLoading, bool? isError, String? errorMessage}) {
    return RecommendProductState(
        product: product ?? this.product,
        isLoading: isLoading ?? this.isLoading,
        isError: isError ?? this.isError,
        errorMessage: errorMessage ?? this.errorMessage);
  }
}

class ProductNotifier extends StateNotifier<RecommendProductState> {
  ProductNotifier() : super(RecommendProductState.initial());

  Future<void> fetchProduct() async {
    print('fetchProduct recomend: ');
    if (state.isLoading) return;
    state = state.copyWith(isLoading: true, isError: false);
    try {
      final product = await api.fetchRecommendProduct();
      state = state.copyWith(product: product, isLoading: false);
    } catch (e) {
      state = state.copyWith(
          isLoading: false, isError: true, errorMessage: e.toString());
    }
  }

  Future<void> refresh() async {
    state = state.copyWith(isLoading: true, isError: false, errorMessage: null);
    await _updateRecommendProductState();
  }

  Future<void> _updateRecommendProductState() async{
    try{
      final product = await api.fetchProduct();
      state = state.copyWith(product: product, isLoading: false);
    } catch(e){
      state = state.copyWith(isLoading: false, isError: true, errorMessage: e.toString());
    }
  }
}

final recommendProductProvider = StateNotifierProvider<ProductNotifier, RecommendProductState>((ref) {
  final notifier = ProductNotifier();
  notifier.fetchProduct();
  return notifier;
});
