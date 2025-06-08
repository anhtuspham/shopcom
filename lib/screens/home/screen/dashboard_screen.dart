import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/model/product.dart';
import '../../../providers/favorite_provider.dart';
import '../../../providers/product_provider.dart';
import '../../../providers/recommend_provider.dart';
import '../../../utils/widgets/error_widget.dart';
import '../../../utils/widgets/loading_widget.dart';
import '../../../utils/widgets/product_card.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(productProvider.notifier).fetchProduct();
      ref.read(recommendProductProvider.notifier).fetchProduct();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(productProvider);
    final favoriteState = ref.watch(favoriteProvider);
    final favoriteList = favoriteState.favorite.map((e) => e.id).toList();
    if (state.isLoading) return const LoadingWidget();
    if (state.isError) return const ErrorsWidget();
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _bannerSection(),
              _salesSection(),
              _productSlideSection(),
              _newSection(),
              _productsGrid(state),
            ],
          ),
        ),
      ),
    );
  }

  Widget _bannerSection() {
    return Stack(
      children: [
        Container(
          height: 200,
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.grey[300],
            image: const DecorationImage(
              image: AssetImage('assets/images/banner.jpg'),
              fit: BoxFit.cover,
            ),
          ),
        ),
        const Positioned(
          bottom: 20,
          left: 20,
          child: Text(
            'Welcome to SHOPCOM',
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
              shadows: [
                Shadow(
                  blurRadius: 10,
                  color: Colors.black,
                  offset: Offset(2, 2),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _salesSection() {
    return const Padding(
      padding: EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Đề xuất',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Phù hợp với bạn',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey,
            ),
          ),
          SizedBox(height: 12),
        ],
      ),
    );
  }

  Widget _productSlideSection() {
    return Consumer(
      builder: (context, ref, child) {
        final recommendState = ref.watch(recommendProductProvider);
        if (recommendState.isLoading) {
          return const SizedBox(
            height: 280,
            child: Center(child: LoadingWidget()),
          );
        }
        if (recommendState.isError) {
          return const SizedBox(
            height: 280,
            child: Center(child: ErrorsWidget()),
          );
        }
        final products = recommendState.product;
        if (products.isEmpty) {
          return const SizedBox(
            height: 280,
            child: Center(child: Text('No recommendations available')),
          );
        }
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: SizedBox(
            height: 280,
            child: ListView.separated(
              itemCount: products.length > 5 ? 5 : products.length,
              itemBuilder: (context, index) {
                final product = products[index];
                return ProductCard(
                  id: product.id ?? '',
                  imageUrl: product.defaultVariant?.images?[0] ?? '',
                  isNew: false,
                  rating: product.ratings?.average ?? 0,
                  reviewCount: product.ratings?.count ?? 0,
                  brand: product.brand ?? '',
                  title: product.name,
                  originalPrice: product.defaultVariant?.price ?? 0,
                  isFavorite: ref
                      .watch(favoriteProvider)
                      .favorite
                      .any((fav) => fav.id == product.id),
                  showToggleFavorite: true,
                );
              },
              separatorBuilder: (context, index) => const SizedBox(width: 8),
              physics: const BouncingScrollPhysics(),
              scrollDirection: Axis.horizontal,
              shrinkWrap: true,
            ),
          ),
        );
      },
    );
  }

  Widget _newSection() {
    return const Padding(
      padding: EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'New',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'You\'ve never seen it before!',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey,
            ),
          ),
          SizedBox(height: 12),
        ],
      ),
    );
  }

  Widget _productsGrid(ProductState state) {
    final newestProduct = state.products.take(4).toList();
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.6,
          mainAxisSpacing: 12,
          crossAxisSpacing: 6,
        ),
        itemCount: newestProduct.length,
        itemBuilder: (context, index) => _buildProductCard(newestProduct[index]),
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
      ),
    );
  }

  Widget _buildProductCard(Product product) {
    return ProductCard(
      id: product.id ?? '',
      imageUrl: product.defaultVariant?.images?[0] ?? '',
      rating: product.ratings?.average ?? 0,
      reviewCount: product.ratings?.count ?? 0,
      brand: product.brand ?? '',
      title: product.name,
      originalPrice: product.defaultVariant?.price ?? 0,
      isNew: true,
      isFavorite: false,
      showToggleFavorite: false,
    );
  }
}