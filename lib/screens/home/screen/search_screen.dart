import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shop_com/utils/screen_size_checker.dart';
import '../../../data/model/product.dart';
import '../../../providers/favorite_provider.dart';
import '../../../providers/product_provider.dart';
import '../../../utils/color_value_key.dart';
import '../../../utils/widgets/loading_widget.dart';
import '../../../utils/widgets/error_widget.dart';
import '../../../utils/widgets/product_card.dart';
import '../../product_detail/screen/product_detail_screen.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(productProvider);
    final notifier = ref.read(productProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _searchController,
          autofocus: true,
          style: TextStyle(color: ColorValueKey.textColor),
          decoration: InputDecoration(
            hintText: 'Tìm kiếm sản phẩm...',
            hintStyle:
                TextStyle(color: Colors.grey[600], fontWeight: FontWeight.w600, fontSize: 22),
            border: InputBorder.none,
          ),
          onChanged: (value) {
            notifier.search(value);
          },
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.clear, color: ColorValueKey.textColor),
            onPressed: () {
              _searchController.clear();
              notifier.search('');
            },
          ),
        ],
      ),
      body: state.isLoading
          ? const LoadingWidget()
          : state.isError
              ? const ErrorsWidget()
              : state.filtered.isEmpty
                  ? const Center(child: Text('No products found'))
                  : GridView.builder(
                      padding: const EdgeInsets.all(10),
                      gridDelegate:
                          SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: ScreenSizeChecker.isTabletLandscape(context) ? 5 : 3,
                        childAspectRatio: 0.7,
                        mainAxisSpacing: 12,
                        crossAxisSpacing: 6,
                      ),
                      itemCount: state.filtered.length,
                      itemBuilder: (context, index) {
                        final product = state.filtered[index];
                        return GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    ProductDetailScreen(id: product.id ?? ''),
                              ),
                            );
                          },
                          child: ProductCard(
                            id: product.id ?? '',
                            imageUrl: product.defaultVariant?.images?[0] ?? '',
                            rating: product.ratings?.average ?? 0,
                            reviewCount: product.ratings?.count ?? 0,
                            brand: product.brand ?? '',
                            title: product.name,
                            originalPrice:
                                (product.defaultVariant?.price ?? 0) * 1.1,
                            discountedPrice: product.defaultVariant?.price ?? 0,
                            isNew: true,
                            isFavorite: ref
                                .watch(favoriteProvider)
                                .favorite
                                .any((fav) => fav.id == product.id),
                            showToggleFavorite: true,
                          ),
                        );
                      },
                    ),
    );
  }
}
