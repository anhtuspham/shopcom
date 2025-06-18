import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:expandable_text/expandable_text.dart';
import 'package:shop_com/providers/review_provider.dart';
import 'package:shop_com/utils/util.dart';
import 'package:shop_com/utils/widgets/appbar_widget.dart';
import 'package:shop_com/utils/widgets/button_widget.dart';
import 'package:shop_com/utils/widgets/custom_reviews_widget.dart';
import 'package:shop_com/utils/widgets/error_widget.dart';
import 'package:shop_com/utils/widgets/loading_widget.dart';

import '../../../data/model/product.dart';
import '../../../utils/widgets/rating_start_widget.dart';

class ReviewScreen extends ConsumerStatefulWidget {
  final Product product;
  const ReviewScreen({super.key, required this.product});

  @override
  ConsumerState<ReviewScreen> createState() => _ReviewScreenState();
}

class _ReviewScreenState extends ConsumerState<ReviewScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.invalidate(reviewProvider(widget.product.id ?? "")));
  }

  @override
  Widget build(BuildContext context) {
    final reviewAsync = ref.watch(reviewProvider(widget.product.id ?? ""));

    return Scaffold(
      appBar: const AppBarWidget(
        title: 'Đánh giá sản phẩm',
      ),
      floatingActionButton: _buildFloatingButton(),
      body: SafeArea(
          child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          children: [
            _buildRating(),
            const SizedBox(
              height: 10,
            ),
            Expanded(
                child: reviewAsync.when(
              data: (reviews) {
                if (reviews.isEmpty) {
                  return const Center(child: Text('Chưa có đánh giá'));
                }
                return CustomerReviews(
                  reviews: reviews,
                );
              },
              error: (error, stackTrace) => const ErrorsWidget(),
              loading: () => const LoadingWidget(),
            )),
          ],
        ),
      )),
    );
  }

  Widget _buildFloatingButton() {
    double ratingValue = 0;
    final commentController = TextEditingController();

    return FloatingActionButton.extended(
        onPressed: () {
          showModalBottomSheet(
            context: context,
            builder: (BuildContext context) {
              return Padding(
                padding: EdgeInsets.only(
                    left: 16,
                    right: 16,
                    top: 16,
                    bottom: MediaQuery.of(context).viewInsets.bottom + 20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    const Text('Bạn cảm thấy sản phẩm như thế nào'),
                    RatingBar(
                      initialRating: 0,
                      itemCount: 5,
                      ratingWidget: RatingWidget(
                          full: Icon(Icons.star, color: Colors.orange[300]),
                          half: const Icon(Icons.star_half),
                          empty: const Icon(Icons.star_border)),
                      onRatingUpdate: (value) {
                        ratingValue = value;
                      },
                    ),
                    TextFormField(
                      controller: commentController,
                      maxLines: 6,
                      decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          label: Text('Đánh giá của bạn')),
                    ),
                    const Spacer(),
                    SizedBox(
                      width: double.infinity,
                      child: CommonButtonWidget(
                        callBack: () async {
                          final notifier = ref
                              .read(reviewProvider(widget.product.id ?? "").notifier);
                          await notifier.addProductReview(
                              productId: widget.product.id ?? "",
                              rating: ratingValue,
                              comment: commentController.text);
                          final reviewState =
                              ref.read(reviewProvider(widget.product.id ?? ""));
                          if (reviewState.hasError) {
                            if (!context.mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                content: Text(reviewState.error.toString())));
                            return;
                          }
                          if (context.mounted) Navigator.pop(context);
                        },
                        label: 'GỬI ĐÁNH GIÁ',
                        style: const TextStyle(color: Colors.white),
                        buttonStyle: const ButtonStyle(
                            backgroundColor:
                                WidgetStatePropertyAll(Colors.black)),
                      ),
                    )
                  ],
                ),
              );
            },
          );
        },
        label: const Text(
          'Để lại bình luận',
          style: TextStyle(color: Colors.white),
        ),
        icon: const Icon(Icons.edit, color: Colors.white),
        backgroundColor: const Color(0xff000000),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)));
  }

  Widget _buildRating() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text('${widget.product.ratings?.average} trên 5.0'),
        RatingStartWidget(
          rating: widget.product.ratings?.average ?? 0,
          reviewCount: widget.product.ratings?.count,
          iconFontSize: 20,
        ),
      ],
    );
  }
}
