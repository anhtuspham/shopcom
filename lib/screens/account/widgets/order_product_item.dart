import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shop_com/providers/currency_provider.dart';
import 'package:shop_com/utils/util.dart';

import '../../../utils/widgets/custom_header_info.dart';

class OrderProductItem extends ConsumerStatefulWidget {
  final String? imageUrl;
  final String? brand;
  final String? name;
  final String? color;
  final String? unit;
  final String? ram;
  final double? price;
  final bool? isFavorite;
  final int index;

  const OrderProductItem(
      {super.key,
      this.imageUrl,
      this.brand,
      this.name,
      this.color,
      this.price,
      this.unit,
      this.ram,
      required this.index,
      this.isFavorite = false});

  @override
  ConsumerState<OrderProductItem> createState() => _OrderProductItemState();
}

class _OrderProductItemState extends ConsumerState<OrderProductItem> {
  ValueNotifier<int> countProduct = ValueNotifier(0);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          border: Border.all(color: Colors.grey),
          borderRadius: BorderRadius.circular(10)),
      padding: const EdgeInsets.all(8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 140,
            // decoration: BoxDecoration(
            //   color: Colors.grey[200],
            //   borderRadius: BorderRadius.circular(12),
            // ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                widget.imageUrl ?? '',
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return const Icon(Icons.error);
                },
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return const Center(child: CircularProgressIndicator());
                },
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.name ?? '',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Color: ${widget.color}',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Ram: ${widget.ram}',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 20,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SizedBox(
                        width: 50,
                        child: CustomHeaderInfo(
                          title: 'Unit',
                          value: widget.unit ?? '',
                          headerWidth: 30,
                          fontSize: 14,
                          valueFontWeight: FontWeight.w700,
                        )),
                    Text(
                        formatMoney(
                            widget.price ?? 0, ref.watch(currencyProvider)),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        )),
                  ],
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
