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
import 'package:shop_com/utils/screen_size_checker.dart';
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
    final width = MediaQuery.sizeOf(context).width;
    return Padding(
      padding: const EdgeInsets.only(left: 5, right: 5, top: 10, bottom: 15),
      child: TextField(
        style: TextStyle(color: ColorValueKey.textColor),
        controller: _searchController,
        readOnly: true,
        decoration: InputDecoration(
            hintText: 'Ưu đãi free ship',
            hintStyle: TextStyle(
                color: Colors.grey[600],
                fontWeight: FontWeight.w600,
                fontSize: 22),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(6.0),
              borderSide: const BorderSide(color: Colors.transparent),
            ),
            prefixIcon: Icon(
              Icons.search,
              color: ColorValueKey.textColor,
            ),
            suffixIcon: GestureDetector(
              onTap: () => context.push('/search'),
              child: Container(
                width: width * (ScreenSizeChecker.isTabletLandscape(context) ? 0.08 : 0.15),
                margin: const EdgeInsets.all(4),
                // padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(6),
                  color: Colors.blueAccent,
                ),
                child: const Text(
                  'Tìm kiếm',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
        ),
        onTap: () {
          context.push('/search');
        },
      ),
    );
  }
}
