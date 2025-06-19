import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shop_com/providers/cart_provider.dart';
import 'package:shop_com/providers/currency_provider.dart';
import 'package:shop_com/utils/util.dart';

import '../../providers/favorite_provider.dart';

class CouponCard extends ConsumerStatefulWidget {
  final String? code;
  final String? discountType;
  final int? discountValue;
  final int? minOrderValue;
  final int? maxDiscountAmount;
  final DateTime? expirationDate;
  final bool? isActive;

  const CouponCard(
      {super.key,
      this.code,
      this.discountValue,
      this.discountType,
      this.minOrderValue,
      this.maxDiscountAmount,
      this.expirationDate,
      this.isActive});

  @override
  ConsumerState<CouponCard> createState() => _CouponCardState();
}

class _CouponCardState extends ConsumerState<CouponCard> {
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
          SizedBox(
            width: 120,
            height: 140,
            child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.asset('assets/images/coupon.jpg')),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            widget.code ?? '',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(height: 8),
                      ],
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    // Text(
                    //   'Color ${widget.color}',
                    //   style: TextStyle(color: Colors.grey[600], fontSize: 12),
                    // ),
                    widget.discountType == 'percentage'
                        ? Text('Giảm ${widget.discountValue}%', style: const TextStyle(color: Colors.green, fontWeight: FontWeight.w700, fontSize: 16),)
                        : Text(
                            'Giảm giá ${formatMoney(widget.discountValue?.toDouble() ?? 0, ref.watch(currencyProvider))}'),
                    const SizedBox(height: 4),
                    Text(
                      'Ngày hết hạn: ${getStringFromDateTime(widget.expirationDate ?? DateTime.now(), 'HH:mm dd/MM/yyyy')}',
                      style: const TextStyle(fontSize: 16),
                    ),
                    Text(
                      'Đơn hàng tối thiểu: ${formatMoney(widget.minOrderValue?.toDouble() ?? 0, ref.watch(currencyProvider))}',
                      style: const TextStyle(fontSize: 16),
                    ),
                    Text(
                      'Trạng thái: ${widget.isActive == true ? 'Hoạt động' : 'Không hoạt động'}',
                      style: const TextStyle(fontSize: 16),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
