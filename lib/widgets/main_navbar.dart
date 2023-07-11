import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/page_provider.dart';
import '../shared_preferences/shared_preferences.dart';

class MainNavbar extends ConsumerStatefulWidget {
  const MainNavbar({super.key});

  @override
  ConsumerState<MainNavbar> createState() => _MainNavbarState();
}

class _MainNavbarState extends ConsumerState<MainNavbar> {
  @override
  Widget build(BuildContext context) {
    final selectedPageIndex = ref.watch(selectPageProvider);
    return Container(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height * 0.12,
      child: Align(
        alignment: Alignment(1, -0.5),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GestureDetector(
              onTap: () {
                ref.read(selectPageProvider.notifier).togglePage(0);
              },
              child: SizedBox(
                child: Image.asset(
                  selectedPageIndex == 0
                      ? 'assets/images/logo.png'
                      : 'assets/images/logo_unTap.png',
                  width: 30,
                  height: 30,
                ),
              ),
            ),
            GestureDetector(
              onTap: () {
                ref.read(selectPageProvider.notifier).togglePage(1);
                getToken();
              },
              child: SizedBox(
                child: Image.asset(
                  selectedPageIndex == 1
                      ? 'assets/images/conversation_onTap.png'
                      : 'assets/images/conversation_unTap.png',
                  width: 30,
                  height: 30,
                ),
              ),
            ),
            GestureDetector(
              onTap: () {
                ref.read(selectPageProvider.notifier).togglePage(2);
              },
              child: SizedBox(
                child: Image.asset(
                  selectedPageIndex == 2
                      ? 'assets/images/person_man_onTap.png'
                      : 'assets/images/person_man_unTap.png',
                  width: 30,
                  height: 30,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
