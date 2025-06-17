// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:provider/provider.dart';
//
// import '../../../providers/product_provider.dart';
// import '../../../utils/color_value_key.dart';
//
// class SearchProduct extends ConsumerStatefulWidget {
//   // final ProductProvider productProvider;
//   const SearchProduct({super.key});
//
//   @override
//   ConsumerState<SearchProduct> createState() => _SearchProductState();
// }
//
// class _SearchProductState extends ConsumerState<SearchProduct> {
//   final TextEditingController _searchController = TextEditingController();
//   @override
//   void dispose() {
//     super.dispose();
//     _searchController.dispose();
//   }
//   @override
//   Widget build(BuildContext context) {
//     // final productProvider = ProductProvider();
//     final notifier = ref.watch(productProvider.notifier);
//     return Padding(
//       padding: const EdgeInsets.only(left: 8.0, right: 8, bottom: 8, top: 8),
//       child: TextField(
//         style: TextStyle(color: ColorValueKey.textColor),
//         controller: _searchController,
//         decoration: InputDecoration(
//           hintText: 'Search',
//           hintStyle: TextStyle(color: Colors.grey[300]),
//           contentPadding: const EdgeInsets.all(8),
//           border: OutlineInputBorder(
//             borderRadius: BorderRadius.circular(15.0),
//             borderSide: const BorderSide(),
//           ),
//           prefixIcon: Icon(
//             Icons.search,
//             color: ColorValueKey.textColor,
//           ),
//           suffixIcon: IconButton(
//             icon: const Icon(
//               Icons.close,
//             ),
//             color: ColorValueKey.textColor,
//             onPressed: () {
//               _searchController.clear();
//               notifier.search('');
//             },
//           ),
//         ),
//         onChanged: (value) {
//           notifier.search(value);
//         },
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../home/screen/search_screen.dart';
import '../../../utils/color_value_key.dart';

class SearchProduct extends ConsumerStatefulWidget {
  const SearchProduct({super.key});

  @override
  ConsumerState<SearchProduct> createState() => _SearchProductState();
}

class _SearchProductState extends ConsumerState<SearchProduct> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 14),
      child: Row(
        children: [
          Expanded(
            flex: 9,
            child: TextField(
              style: TextStyle(color: ColorValueKey.textColor),
              controller: _searchController,
              readOnly: true,
              decoration: InputDecoration(
                hintText: 'Tìm kiếm',
                hintStyle: TextStyle(color: Colors.grey[600], fontWeight: FontWeight.w600, fontSize: 22),
                contentPadding: const EdgeInsets.all(12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                  borderSide: const BorderSide(color: Colors.transparent),
                ),
                prefixIcon: Icon(
                  Icons.search,
                  color: ColorValueKey.textColor,
                ),
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const SearchScreen()),
                );
              },
            ),
          ),
          Expanded(flex: 1, child: IconButton(icon: const Icon(Icons.shopping_bag, size: 35,), onPressed: () => context.go('/cart'),))
        ],
      ),
    );
  }
}
