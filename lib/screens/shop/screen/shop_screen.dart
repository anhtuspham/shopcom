import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:provider/provider.dart';
import 'package:shop_com/providers/favorite_provider.dart';
import 'package:shop_com/providers/product_provider.dart';
import 'package:shop_com/screens/shop/widgets/search_product.dart';

import '../../../utils/screen_size_checker.dart';
import '../../../utils/widgets/error_widget.dart';
import '../../../utils/widgets/loading_widget.dart';
import '../../../utils/widgets/product_card.dart';

class ShopScreen extends ConsumerStatefulWidget {
  const ShopScreen({super.key});

  @override
  ConsumerState<ShopScreen> createState() => _ShopScreenState();
}

class _ShopScreenState extends ConsumerState<ShopScreen> {
  final ScrollController _scrollController = ScrollController();
  bool showSortPrice = false;
  String? _currentSort;

  @override
  void dispose() {
    super.dispose();
    _scrollController.dispose();
  }

  @override
  void initState() {
    super.initState();
    Future.microtask(
      () {
        ref.read(productProvider.notifier).fetchProduct(sort: _currentSort);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(productProvider);
    final favoriteState = ref.watch(favoriteProvider);
    final favoriteList = favoriteState.favorite.map((e) => e.id).toList();

    if (state.isLoading) return const LoadingWidget();
    if (state.isError) return const ErrorsWidget();

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Shop',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: false,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              _buildHeaderSection(),
              const SizedBox(height: 10),
              const SearchProduct(),
              const SizedBox(
                height: 10,
              ),
              Expanded(
                child: _buildProductGrid(state, favoriteList),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            // _buildFilterButton(icon: Icons.tune, text: 'Filters'),
            const SizedBox(width: 16),
            DropdownButton(
              hint: Text(
                  'Giá ${_currentSort == null ? '' : _currentSort == 'priceAsc' ? 'tăng dần' : 'giảm dần'}'),
              items: const [
                DropdownMenuItem(
                    value: 'priceAsc', child: Text('Giá tăng dần')),
                DropdownMenuItem(
                  value: 'priceDesc',
                  child: Text('Giá giảm dần'),
                )
              ],
              onChanged: (value) {
                setState(() {
                  _currentSort = value;
                });
                ref.read(productProvider.notifier).fetchProduct(sort: value);
              },
              borderRadius: BorderRadius.circular(10),
            ),
            const Spacer(),
            // IconButton(
            //   icon: const Icon(Icons.grid_view),
            //   onPressed: () {},
            // ),
          ],
        ),
        if (showSortPrice) _buildDropdown()
      ],
    );
  }

  Widget _buildFilterButton(
      {required IconData icon, required String text, VoidCallback? onPress}) {
    return OutlinedButton.icon(
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        side: BorderSide(color: Colors.grey[300]!),
      ),
      onPressed: onPress ?? () {},
      icon: Icon(icon, size: 20),
      label: Text(text),
    );
  }

  Widget _buildProductGrid(ProductState state, List<String?> favoriteList) {
    return RawScrollbar(
      trackVisibility: true,
      thumbVisibility: true,
      thumbColor: Colors.grey,
      controller: _scrollController,
      padding: const EdgeInsets.only(top: 7, left: 2),
      crossAxisMargin: 0,
      radius: const Radius.circular(10),
      thickness: 3,
      child: Container(
        margin: const EdgeInsets.only(left: 4.0, right: 8, bottom: 8),
        padding: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          // border: Border.all(
          //   color: Colors.grey,
          //   width: 1,
          // ),
        ),
        child: RefreshIndicator(
            onRefresh: _refresh,
            child: GridView.builder(
                controller: _scrollController,
                physics: const BouncingScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: ScreenSizeChecker.isTabletLandscape(context) ? 5 : 3,
                  childAspectRatio: 0.6,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 6,
                ),
                itemCount: state.filtered.length,
                itemBuilder: (context, index) {
                  return ProductCard(
                      id: state.filtered[index].id ?? '',
                      imageUrl:
                          state.filtered[index].defaultVariant?.images?[0] ??
                              '',
                      rating: state.filtered[index].ratings?.average ?? 0,
                      reviewCount: state.filtered[index].ratings?.count ?? 0,
                      brand: state.filtered[index].brand ?? '',
                      title: state.filtered[index].name,
                      originalPrice:
                          state.filtered[index].defaultVariant?.price ?? 0,
                      isFavorite: favoriteList.contains(state.filtered[index].id),
                      isNew: true);
                })),
      ),
    );
  }

  Widget _buildDropdown() {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Column(
        children: [
          ElevatedButton(onPressed: null, child: Text('Cao nhất')),
          ElevatedButton(onPressed: null, child: Text('Thấp nhất'))
        ],
      ),
    );
  }

  Future<void> _refresh() async {
    return ref.read(productProvider.notifier).refresh();
  }
}
