import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/config/app_config.dart';
import '../data/model/coupon.dart';

class CouponState {
  final List<Coupon> coupon;
  final Coupon? couponDetail;
  final bool isLoading;
  final bool isError;
  final String? errorMessage;

  const CouponState(
      {required this.coupon,
        this.couponDetail,
      this.isLoading = false,
      this.isError = false,
      this.errorMessage});

  factory CouponState.initial() => const CouponState(coupon: []);

  CouponState copyWith(
      {List<Coupon>? coupon,
        Coupon? couponDetail,
      bool? isLoading,
      bool? isError,
      String? errorMessage}) {
    return CouponState(
        coupon: coupon ?? this.coupon,
        couponDetail: couponDetail ?? this.couponDetail,
        isLoading: isLoading ?? this.isLoading,
        isError: isError ?? this.isError,
        errorMessage: errorMessage ?? this.errorMessage);
  }
}

class CouponNotifier extends StateNotifier<CouponState> {
  CouponNotifier() : super(CouponState.initial());

  Future<void> fetchCoupons() async {
    if (state.isLoading) return;
    state = state.copyWith(isLoading: true, isError: false);
    try {
      final coupon = await api.fetchCoupons();
      state = state.copyWith(coupon: coupon, isLoading: false);
    } catch (e) {
      state = state.copyWith(
          isLoading: false, isError: true, errorMessage: e.toString());
    }
  }

  Future<void> refresh() async {
    state = state.copyWith(isLoading: true, isError: false, errorMessage: null);
    await _updateCouponState();
  }

  Future<bool> createCoupon(
      {String? code,
      String? discountType,
      int? discountValue,
      int? minOrderValue,
      int? maxDiscountAmount,
      DateTime? expirationDate,
      int? usageLimit}) async {
    state = state.copyWith(isLoading: true, isError: false);
    try {
      final result = await api.createCoupon(
          code: code,
          discountType: discountType,
          discountValue: discountValue,
          minOrderValue: minOrderValue,
          maxDiscountAmount: maxDiscountAmount,
          expirationDate: expirationDate,
          usageLimit: usageLimit);
      if (result.isValue) {
        await _updateCouponState();
        return true;
      } else {
        state = state.copyWith(
            isLoading: false,
            isError: true,
            errorMessage: "Failed to create coupon");
        return false;
      }
    } catch (e) {
      state = state.copyWith(
          isLoading: false, isError: true, errorMessage: e.toString());
      return false;
    }
  }

  Future<Coupon> getCoupon({required String couponCode}) async{
    state = state.copyWith(isLoading: true, isError: false);
    try {
      final coupon = await api.getCoupon(couponCode: couponCode);
      state = state.copyWith(coupon: [coupon], isLoading: false, couponDetail: coupon);
      return coupon;
    } catch (e) {
      state = state.copyWith(
          isLoading: false, isError: true, errorMessage: e.toString());
      rethrow;
    }
  }

  Future<bool> updateCoupon(
      {String? id,
      String? code,
      String? discountType,
      int? discountValue,
      int? minOrderValue,
      int? maxDiscountAmount,
      DateTime? expirationDate,
      int? usageLimit}) async {
    state = state.copyWith(isLoading: true, isError: false);
    try {
      final result = await api.editCoupon(
          id: id,
          code: code,
          discountType: discountType,
          discountValue: discountValue,
          minOrderValue: minOrderValue,
          maxDiscountAmount: maxDiscountAmount,
          expirationDate: expirationDate,
          usageLimit: usageLimit);
      if (result.isValue) {
        await _updateCouponState();
        return true;
      } else {
        state = state.copyWith(
            isLoading: false,
            isError: true,
            errorMessage: "Failed to update info");
        return false;
      }
    } catch (e) {
      state = state.copyWith(
          isLoading: false, isError: true, errorMessage: e.toString());
      return false;
    }
  }

  Future<bool> deleteCoupon({
    required String id,
  }) async {
    state = state.copyWith(isLoading: true, isError: false);
    try {
      final result = await api.deleteCoupon(id: id);
      if (result.isValue) {
        await _updateCouponState();
        return true;
      } else {
        state = state.copyWith(
            isLoading: false,
            isError: true,
            errorMessage: "Failed to delete coupon");
        return false;
      }
    } catch (e) {
      state = state.copyWith(
          isLoading: false, isError: true, errorMessage: e.toString());
      return false;
    }
  }

  Future<void> _updateCouponState() async {
    try {
      final coupon = await api.fetchCoupons();
      state = state.copyWith(coupon: coupon, isLoading: false);
    } catch (e) {
      state = state.copyWith(
          isLoading: false, isError: true, errorMessage: e.toString());
    }
  }
}

final couponProvider =
    StateNotifierProvider<CouponNotifier, CouponState>((ref) {
  final notifier = CouponNotifier();
  notifier.fetchCoupons();
  return notifier;
});
