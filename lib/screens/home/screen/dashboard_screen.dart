import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/model/product.dart';
import '../../../providers/favorite_provider.dart';
import '../../../providers/product_provider.dart';
import '../../../providers/recommend_provider.dart';
import '../../../utils/screen_size_checker.dart';
import '../../../utils/widgets/error_widget.dart';
import '../../../utils/widgets/loading_widget.dart';
import '../../../utils/widgets/product_card.dart';
import '../../shop/widgets/search_product.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  int _currentPageIndex = 0;

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
    final recommendProductState = ref.watch(recommendProductProvider);
    final favoriteState = ref.watch(favoriteProvider);
    final favoriteList = favoriteState.favorite.map((e) => e.id).toList();
    if (state.isLoading) return const LoadingWidget();
    if (state.isError) return const ErrorsWidget();
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        automaticallyImplyLeading: false,
        title: const SearchProduct(),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // const SearchProduct(),
            _bannerSection(),
            _recommendSection(),
            // _productSlideSection(),
            _productsRecommendGrid(recommendProductState),
            _newSection(),
            _productsGrid(state),
            const SizedBox(height: 20)
          ],
        ),
      ),
    );
  }

  Widget _bannerSection() {
    final List<String> bannerImages = [
      // 'assets/images/banner-1.jpg',
      'assets/images/banner-2.jpg',
      'assets/images/b2.jpg',
      'assets/images/9222_generated.png',
      'assets/images/banner-4.png'
    ];
    return Stack(
      children: [
        CarouselSlider(
          options: CarouselOptions(
            height: 200,
            autoPlay: true,
            autoPlayInterval: const Duration(seconds: 4),
            autoPlayAnimationDuration: const Duration(milliseconds: 800),
            enlargeCenterPage: true,
            aspectRatio: 16 / 9,
            viewportFraction: 0.65,
            enableInfiniteScroll: true,
            initialPage: 1,
            onPageChanged: (index, reason) {
              setState(() {
                _currentPageIndex = index;
              });
            },
          ),
          items: bannerImages.map((imagePath) {
            return Builder(builder: (context) {
              return Container(
                // height: 200,
                margin: const EdgeInsets.symmetric(horizontal: 5),
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: Colors.grey[200],
                  image: DecorationImage(
                    image: AssetImage(imagePath),
                    fit: ScreenSizeChecker.isTabletLandscape(context) ? BoxFit.fill : BoxFit.fill,
                  ),
                  boxShadow: [BoxShadow(color: Colors.black87.withValues(alpha: 0.1), blurRadius: 1, offset: const Offset(0, 2))]
                ),
              );
            });
          },).toList(),
        ),
        Positioned(
          right: 8,
          bottom: 0,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.6),
              borderRadius: BorderRadius.circular(12)
            ),
            child: Text(
              '${_currentPageIndex % bannerImages.length + 1}/${bannerImages.length}',
              style: const TextStyle(fontSize: 14, color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
        )
      ],
    );
  }

  Widget _recommendSection() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Gợi ý cho bạn',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Dựa trên sở thích và lựa chọn gần đây của bạn',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 12),
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
                return SizedBox(
                  width: 160,
                  child: ProductCard(
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
                  ),
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

  Widget _productsRecommendGrid(RecommendProductState state) {
    // final newestProduct = state.products.take(4).toList();
    final newestProduct = state.product;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: ScreenSizeChecker.isTabletLandscape(context) ? 5 : 3,
          childAspectRatio: 0.7,
          mainAxisSpacing: 12,
          crossAxisSpacing: 6,
        ),
        itemCount: state.product.length > 5 ? 5 : state.product.length,
        itemBuilder: (context, index) => _buildProductCard(newestProduct[index]),
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
      ),
    );
  }

  Widget _newSection() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Khám phá sản phẩm mới',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Bộ sưu tập vừa cập bến, mời bạn khám phá',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }

  Widget _productsGrid(ProductState state) {
    // final newestProduct = state.products.take(4).toList();
    final newestProduct = state.products;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: ScreenSizeChecker.isTabletLandscape(context) ? 5 : 3,
          childAspectRatio: 0.7,
          mainAxisSpacing: 12,
          crossAxisSpacing: 6,
        ),
        itemCount: state.products.length,
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
      originalPrice: (product.defaultVariant?.price ?? 0) * 1.1,
      discount: '10',
      discountedPrice: product.defaultVariant?.price ?? 0,
      isNew: true,
      isFavorite: false,
      showToggleFavorite: false,
    );
  }
}