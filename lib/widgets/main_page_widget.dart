import 'package:flutter/material.dart';
import 'package:rando/screens/main_page.dart';
import 'package:rando/screens/profile_page.dart';
import 'package:rando/widgets/main_appbar.dart';
import 'package:rando/widgets/main_navbar.dart';
import '../screens/swap_page.dart';
import '../shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';

import 'package:flutter_card_swiper/flutter_card_swiper.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../screens/chat_list.dart';
import '../providers/page_provider.dart';
import '../screens/match_page.dart';
import '../models/user.dart';

class MainPageWidget extends ConsumerStatefulWidget {
  // final String chatroomList;
  final String userId;

  const MainPageWidget({
    super.key,
    // required this.chatroomList,
    required this.userId,
  });

  @override
  ConsumerState<MainPageWidget> createState() => _MainPageWidgetState();
}

// class _MainPageWidgetState extends ConsumerState<MainPageWidget> {
//   @override
//   Widget build(BuildContext context) {
//     final selectedPageIndex = ref.watch(selectPageProvider);

//     return Column(
//       children: [
//         MainAppBar(Colors.white, widget.userId),
//         SizedBox(
//           height: MediaQuery.of(context).size.height * 0.8,
//           child: IndexedStack(
//             index: selectedPageIndex,
//             children: [
//               SwapPageScreen(userId: widget.userId),
//               ChatPageScreen(userId: widget.userId),
//               ProfilePageScreen(userId: widget.userId),
//             ],
//           ),
//         ),
//         const MainNavbar(),
//       ],
//     );
//   }
// }

class _MainPageWidgetState extends ConsumerState<MainPageWidget> {
  Widget MainPageWidget(int page) {
    // Assign a unique Key based on the page index
    final key = ValueKey<int>(page);

    if (page == 0) {
      return Column(
        key: key,
        children: [
          MainAppBar(Colors.white, widget.userId),
          SwapPageScreen(userId: widget.userId),
          const MainNavbar()
        ],
      );
    } else if (page == 1) {
      return Column(
        key: key,
        children: [
          MainAppBar(Colors.white, widget.userId),
          ChatPageScreen(userId: widget.userId),
          const MainNavbar()
        ],
      );
    } else if (page == 2) {
      return Column(
        key: key,
        children: [
          MainAppBar(Colors.white, widget.userId),
          Expanded(child: ProfilePageScreen(userId: widget.userId)),
          const MainNavbar()
        ],
      );
    } else {
      return MainPageScreen(key: key, userId: widget.userId);
    }
  }

  @override
  Widget build(BuildContext context) {
    final selectedPageIndex = ref.watch(selectPageProvider);
    return MainPageWidget(selectedPageIndex);
  }
}
