import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/config/app_config.dart';
import '../data/model/cart.dart';

class CartState {
  final Cart cart;
  final bool isLoading;
  final bool isError;
  final String? errorMessage;

  const CartState(
      {required this.cart,
      this.isLoading = false,
      this.isError = false,
      this.errorMessage});

  factory CartState.initial() => CartState(cart: Cart.empty());

  CartState copyWith(
      {Cart? cart, bool? isLoading, bool? isError, String? errorMessage}) {
    return CartState(
        cart: cart ?? this.cart,
        isLoading: isLoading ?? this.isLoading,
        isError: isError ?? this.isError,
        errorMessage: errorMessage ?? this.errorMessage);
  }
}

class CartNotifier extends StateNotifier<CartState> {
  CartNotifier() : super(CartState.initial());

  Future<void> fetchCart() async {
    print('fetchCart: ');
    if (state.isLoading) return;
    state = state.copyWith(isLoading: true, isError: false);
    try {
      final cart = await api.fetchCart();
      state = state.copyWith(cart: cart, isLoading: false);
    } catch (e) {
      state = state.copyWith(
          isLoading: false, isError: true, errorMessage: e.toString());
    }
  }

  Future<void> refresh() async {
    state = state.copyWith(isLoading: true, isError: false, errorMessage: null);
    await _updateCartState();
  }

  Future<bool> addProductToCart({
    required String productId,
    required int variantIndex,
    required int quantity,
  }) async {
    state = state.copyWith(isLoading: false, isError: false);
    try{
      final result = await api.addProductToCart(
          productId: productId, variantIndex: variantIndex, quantity: quantity);
      if (result.isValue) {
        await _updateCartState();
        return true;
      } else {
        state = state.copyWith(isLoading: false, isError: true, errorMessage: "Failed to add product to cart");
        return false;
      }
    } catch(e){
      state = state.copyWith(isLoading: false, isError: true, errorMessage: e.toString());
      return false;
    }
  }

  Future<bool> removeProductFromCart({
    required String productId,
    required int variantIndex
  }) async {
    state = state.copyWith(isLoading: false, isError: false);
    try {
      final result = await api.removeProductFromCart(
          productId: productId, variantIndex: variantIndex);

      if (result.isValue) {
        await _updateCartState();
        return true;
      } else {
        state = state.copyWith(
          isLoading: false,
          isError: true,
          errorMessage: 'Failed to remove product from cart',
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

  Future<void> _updateCartState() async{
    try{
      final cart = await api.fetchCart();
      state = state.copyWith(cart: cart, isLoading: false);
    } catch(e){
      state = state.copyWith(isLoading: false, isError: true, errorMessage: e.toString());
    }
  }
}

final cartProvider = StateNotifierProvider<CartNotifier, CartState>((ref) {
  final notifier = CartNotifier();
  notifier.fetchCart();
  return notifier;
});
