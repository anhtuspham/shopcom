import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shop_com/providers/coupon_provider.dart';
import 'package:shop_com/providers/favorite_provider.dart';
import 'package:shop_com/utils/widgets/coupon_card.dart';

import '../../../utils/widgets/error_widget.dart';
import '../../../utils/widgets/loading_widget.dart';
import '../../../utils/widgets/product_bag_item.dart';

class CouponsScreen extends ConsumerStatefulWidget {
  const CouponsScreen({super.key});

  @override
  ConsumerState<CouponsScreen> createState() => _CouponsScreenState();
}

class _CouponsScreenState extends ConsumerState<CouponsScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(
          () {
        ref.read(couponProvider.notifier).fetchCoupons();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(couponProvider);
    if (state.isLoading) return const LoadingWidget();
    if (state.isError) return const ErrorsWidget();

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Mã giảm giá',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {},
          ),
        ],
      ),
      body: _buildFavoriteList(context, state),
    );
  }

  Widget _buildFavoriteList(BuildContext context, CouponState state) {
    if (state.coupon.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.favorite_border, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            Text(
              'Không có mã giảm giá',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: state.coupon.length,
        separatorBuilder: (context, index) => const SizedBox(height: 16),
        // itemBuilder: (context, index) => _buildFavoriteItem(context, favoriteProducts[index]),
        itemBuilder: (context, index) => CouponCard(
          code: state.coupon[index].code ?? '',
          discountType: state.coupon[index].discountType ?? '',
          discountValue: state.coupon[index].discountValue ?? 0,
          minOrderValue: state.coupon[index].minOrderValue,
          expirationDate: state.coupon[index].expirationDate,
          isActive: state.coupon[index].isActive ?? false,
        ));
  }
}
