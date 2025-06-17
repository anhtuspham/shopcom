import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class RatingStartWidget extends StatelessWidget {
  final double? iconFontSize;
  final double rating;
  final int? reviewCount;
  final double? paddingLeft;

  const RatingStartWidget({super.key, required this.rating, this.reviewCount, this.iconFontSize, this.paddingLeft});

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      for (int i = 0; i < 5; i++)
        Icon(
          i + 1 <= rating
              ? Icons.star
              : i < rating
                  ? Icons.star_half
                  : Icons.star_border,
          size: iconFontSize ?? 14,
          color: Colors.amber[400],
        ),
      if (reviewCount != null) ...[
        const SizedBox(width: 5),
        Text(
          '($reviewCount)',
          style: const TextStyle(color: Colors.grey, fontSize: 10),
        )
      ]
    ]);
  }
}
