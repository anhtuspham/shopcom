import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shop_com/providers/favorite_provider.dart';

import '../../../utils/widgets/error_widget.dart';
import '../../../utils/widgets/loading_widget.dart';
import '../../../utils/widgets/product_bag_item.dart';

class FavoritesScreen extends ConsumerStatefulWidget {
  const FavoritesScreen({super.key});

  @override
  ConsumerState<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends ConsumerState<FavoritesScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(
      () {
        ref.read(favoriteProvider.notifier).fetchFavorite();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(favoriteProvider);
    if (state.isLoading) return const LoadingWidget();
    if (state.isError) return const ErrorsWidget();

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Yêu thích',
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

  Widget _buildFavoriteList(BuildContext context, FavoriteState state) {
    if (state.favorite.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.favorite_border, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            Text(
              'Không có sản phẩm',
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
        itemCount: state.favorite.length,
        separatorBuilder: (context, index) => const SizedBox(height: 16),
        // itemBuilder: (context, index) => _buildFavoriteItem(context, favoriteProducts[index]),
        itemBuilder: (context, index) => ProductBagItem(
              productId: state.favorite[index].id ?? '',
              index: index,
              isFavorite: true,
              imageUrl: state.favorite[index].defaultVariant?.images?[0],
              name: state.favorite[index].name,
              color: state.favorite[index].defaultVariant?.color,
              ram: state.favorite[index].defaultVariant?.ram,
              price: state.favorite[index].defaultVariant?.price,
              showToggleFavorite: true,
            ));
  }
}
