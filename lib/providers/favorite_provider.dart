import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/config/app_config.dart';
import '../data/model/product.dart';

class FavoriteState {
  final List<Product> favorite;
  final bool isLoading;
  final bool isError;
  final String? errorMessage;

  const FavoriteState(
      {required this.favorite,
        this.isLoading = false,
        this.isError = false,
        this.errorMessage});

  factory FavoriteState.initial() => const FavoriteState(favorite: []);

  FavoriteState copyWith(
      {List<Product>? favorite, bool? isLoading, bool? isError, String? errorMessage}) {
    return FavoriteState(
        favorite: favorite ?? this.favorite,
        isLoading: isLoading ?? this.isLoading,
        isError: isError ?? this.isError,
        errorMessage: errorMessage ?? this.errorMessage);
  }
}

class FavoriteNotifier extends StateNotifier<FavoriteState> {
  FavoriteNotifier() : super(FavoriteState.initial());

  Future<void> fetchFavorite() async {
    if (state.isLoading) return;
    state = state.copyWith(isLoading: true, isError: false);
    try {
      final favorite = await api.fetchFavoriteProduct();
      state = state.copyWith(favorite: favorite, isLoading: false);
    } catch (e) {
      state = state.copyWith(
          isLoading: false, isError: true, errorMessage: e.toString());
    }
  }

  Future<void> refresh() async {
    state = state.copyWith(isLoading: true, isError: false, errorMessage: null);
    await _updateFavoriteState();
  }

  Future<bool> addProductToFavorite({
    required String productId,
  }) async {
    state = state.copyWith(isLoading: false, isError: false);
    try{
      final result = await api.addProductFavorite(
          productId: productId);
      if (result.isValue) {
        await _updateFavoriteState();
        return true;
      } else {
        state = state.copyWith(isLoading: false, isError: true, errorMessage: "Failed to add product to favorite");
        return false;
      }
    } catch(e){
      state = state.copyWith(isLoading: false, isError: true, errorMessage: e.toString());
      return false;
    }
  }

  Future<bool> removeProductFromFavorite({
    required String productId,
  }) async {
    state = state.copyWith(isLoading: false, isError: false);
    try {
      final result = await api.removeProductFavorite(
          productId: productId);

      if (result.isValue) {
        await _updateFavoriteState();
        return true;
      } else {
        state = state.copyWith(
          isLoading: false,
          isError: true,
          errorMessage: 'Failed to remove product from favorite',
        );
        return false;
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        isError: true,
        errorMessage: e.toString(),
      );
      return false;
    }
  }

  Future<void> _updateFavoriteState() async{
    try{
      final favorite = await api.fetchFavoriteProduct();
      state = state.copyWith(favorite: favorite, isLoading: false);
    } catch(e){
      state = state.copyWith(isLoading: false, isError: true, errorMessage: e.toString());
    }
  }
}

final favoriteProvider = StateNotifierProvider<FavoriteNotifier, FavoriteState>((ref) {
  final notifier = FavoriteNotifier();
  notifier.fetchFavorite();
  return notifier;
});
