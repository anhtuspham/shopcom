import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shop_com/providers/currency_provider.dart';
import 'package:shop_com/providers/favorite_provider.dart';
import 'package:shop_com/utils/util.dart';
import 'package:shop_com/utils/widgets/discount_badge.dart';
import 'package:shop_com/utils/widgets/rating_start_widget.dart';

class ProductCard extends ConsumerStatefulWidget {
  final String id;
  final String imageUrl;
  final String? discount;
  final double rating;
  final int reviewCount;
  final String brand;
  final String title;
  final double originalPrice;
  final double? discountedPrice;
  final bool isNew;
  final bool isFavorite;
  final bool showToggleFavorite;

  const ProductCard({
    super.key,
    required this.id,
    required this.imageUrl,
    this.discount,
    required this.rating,
    required this.reviewCount,
    required this.brand,
    required this.title,
    required this.originalPrice,
    this.discountedPrice,
    required this.isNew,
    required this.isFavorite,
    this.showToggleFavorite = true,
  });

  @override
  ConsumerState<ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends ConsumerState<ProductCard> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.sizeOf(context).height;
    final width = MediaQuery.sizeOf(context).width;

    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) => _controller.reverse(),
      onTapCancel: () => _controller.reverse(),
      onTap: () => context.push('/productDetail', extra: widget.id),
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Card(
          elevation: 4,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Product image and discount badge
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(12),
                      topRight: Radius.circular(12),
                    ),
                    child: Container(
                      // alignment: Alignment.center,
                      height: height * 0.25,
                      width: double.infinity,
                      child: Image.network(
                        widget.imageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: Colors.grey[200],
                            child: const Center(
                              child: Icon(Icons.image_not_supported, size: 40),
                            ),
                          );
                        },
                        loadingBuilder: (context, child, loadingProgress) {
                          return Stack(
                            children: [
                              child, // Ảnh chính
                              if (loadingProgress != null)
                                const Center(child: CircularProgressIndicator()),
                            ],
                          );
                        },
                      ),
                    ),
                  ),
                  if (widget.discount != null)
                    Positioned(
                      right: 0,
                      top: 0,
                      child: DiscountBadge(discount: widget.discount ?? '', size: 45,)
                    ),
                  if (widget.showToggleFavorite)
                    Positioned(
                      right: 8,
                      top: 8,
                      child: GestureDetector(
                        onTap: () async {
                          if (!widget.isFavorite) {
                            await ref.read(favoriteProvider.notifier).addProductToFavorite(productId: widget.id);
                          } else {
                            await ref.read(favoriteProvider.notifier).removeProductFromFavorite(productId: widget.id);
                          }
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Icon(
                            widget.isFavorite ? Icons.favorite : Icons.favorite_border,
                            size: 22,
                            color: widget.isFavorite ? Colors.red : Colors.grey,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              // Content section (brand, title, price)
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Rating
                      RatingStartWidget(rating: widget.rating, reviewCount: widget.reviewCount),
                      const SizedBox(height: 4),
                      // Brand
                      Text(
                        widget.brand,
                        style: TextStyle(fontSize: 16, color: Colors.grey[700], fontWeight: FontWeight.w400),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      // Title
                      Text(
                        widget.title,
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const Spacer(),
                      // Price
                      Row(
                        children: [
                          Text(
                            key: ValueKey('originalPrice_${widget.originalPrice}_${widget.id}'),
                            formatMoney(widget.originalPrice, ref.watch(currencyProvider)),
                            style: TextStyle(
                              fontSize: 18,
                              color: widget.discountedPrice != null ? Colors.grey : Colors.red,
                              fontWeight: FontWeight.w600,
                              decoration: widget.discountedPrice != null ? TextDecoration.lineThrough : TextDecoration.none,
                              decorationThickness: 2.0,
                              decorationColor: Colors.grey[600],
                            ),
                          ),
                          if (widget.discountedPrice != null) ...[
                            const SizedBox(width: 8),
                            Text(
                              formatMoney(widget.discountedPrice ?? 0, ref.watch(currencyProvider)),
                              style: const TextStyle(
                                fontSize: 18,
                                color: Colors.red,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}