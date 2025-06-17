import 'package:flutter/material.dart';

class DiscountBadge extends StatelessWidget {
  final String discount;
  final double size;

  const DiscountBadge({
    super.key,
    required this.discount,
    this.size = 80.0,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _DiscountBadgePainter(),
      child: Container(
        width: size,
        height: size * 0.5,
        alignment: Alignment.center,
        padding: const EdgeInsets.only(left: 4),
        child: Text(
          '-$discount%',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 15,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

class _DiscountBadgePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..shader = const LinearGradient(
        colors: [
          Color(0xFFFF5722),
          Color(0xFFF06292),
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    final path = Path()
      ..moveTo(0, size.height * 0.5) // Điểm bắt đầu mũi tên
      ..lineTo(size.width * 0.3, 0) // Đỉnh mũi tên
      ..lineTo(size.width, 0) // Cạnh trên phải
      ..quadraticBezierTo(
        size.width,
        size.height * 0.5,
        size.width,
        size.height, // Cạnh phải bo tròn
      )
      ..lineTo(size.width * 0.3, size.height) // Cạnh dưới phải
      ..lineTo(0, size.height * 0.5) // Cạnh dưới trái
      ..close(); // Đóng đường dẫn

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}