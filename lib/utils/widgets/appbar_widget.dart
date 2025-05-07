import 'package:flutter/material.dart';

class AppBarWidget extends StatelessWidget {
  final String? title;

  const AppBarWidget({super.key, this.title});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(title ?? ''),
    );
    // return Container(
    //   padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
    //   decoration: const BoxDecoration(
    //     color: Colors.white,
    //     boxShadow: [
    //       BoxShadow(color: Colors.black12, offset: Offset(0, 2), blurRadius: 6)
    //     ]
    //   ),
    //   child: Row(
    //     children: [
    //       IconButton(
    //         onPressed: () => Navigator.pop(context),
    //         icon: const Icon(Icons.arrow_back_ios_new_rounded),
    //       ),
    //       const SizedBox(width: 4),
    //       Text(
    //         title ?? '',
    //         style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
    //       )
    //     ],
    //   ),
    // );
  }
}
