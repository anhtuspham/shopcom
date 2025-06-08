import 'package:flutter/material.dart';

class DashboardPageScreen extends StatelessWidget {
  const DashboardPageScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              const Text(
                'Street clothes',
                style: TextStyle(
                  fontSize: 34,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 24),

              // Sale Section
              _buildSection(
                title: 'Sale',
                subtitle: 'Super summer sale',
                tags: ['-20%', '-15%'],
                products: [
                  _ProductItem(
                    brand: 'Dorothy Perkins',
                    name: 'Evening Dress',
                    price: '15\$',
                    discountedPrice: '12\$',
                    rating: 5,
                    reviews: 10,
                  ),
                  _ProductItem(
                    brand: 'Sitily',
                    name: 'Sport Dress',
                    price: '22\$',
                    discountedPrice: '19\$',
                    rating: 5,
                    reviews: 10,
                  ),
                ],
              ),
              const SizedBox(height: 32),

              // New Section
              _buildSection(
                title: 'New',
                subtitle: 'Các sản phẩm mới nhất của chúng tôi!',
                tags: ['NEW', 'NEW'],
                products: [],
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNavigation(),
    );
  }

  Widget _buildSection({
    required String title,
    required String subtitle,
    required List<String> tags,
    required List<_ProductItem> products,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Header
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 12),
            // Tags
            Wrap(
              spacing: 8,
              children: tags.map((tag) => Chip(
                label: Text(tag),
                backgroundColor: title == 'Sale' ? Colors.red : Colors.grey[200],
                labelStyle: TextStyle(
                  color: title == 'Sale' ? Colors.white : Colors.black,
                ),
              )).toList(),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Product List
        products.isEmpty
            ? const SizedBox.shrink()
            : Column(
          children: [
            ...products.map((product) => _buildProductCard(product)),
            _buildViewAllButton(),
          ],
        ),
      ],
    );
  }

  Widget _buildProductCard(_ProductItem product) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 2,
            blurRadius: 8,
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Product Image
          Container(
            width: 100,
            height: 120,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          const SizedBox(width: 16),

          // Product Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Rating
                Row(
                  children: [
                    ...List.generate(
                      product.rating,
                          (index) => const Icon(Icons.star,
                          color: Colors.amber, size: 16),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '(${product.reviews})',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // Brand & Name
                Text(
                  product.brand,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
                Text(
                  product.name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),

                // Pricing
                Row(
                  children: [
                    Text(
                      product.discountedPrice,
                      style: const TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      product.price,
                      style: TextStyle(
                        decoration: TextDecoration.lineThrough,
                        color: Colors.grey[500],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildViewAllButton() {
    return TextButton(
      onPressed: () {},
      child: const Text(
        'View all',
        style: TextStyle(color: Colors.red),
      ),
    );
  }

  Widget _buildBottomNavigation() {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.shopping_bag),
          label: 'Shop',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.shopping_cart),
          label: 'Bag',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.favorite),
          label: 'Favorites',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person),
          label: 'Profile',
        ),
      ],
    );
  }
}

class _ProductItem {
  final String brand;
  final String name;
  final String price;
  final String discountedPrice;
  final int rating;
  final int reviews;

  _ProductItem({
    required this.brand,
    required this.name,
    required this.price,
    required this.discountedPrice,
    required this.rating,
    required this.reviews,
  });
}