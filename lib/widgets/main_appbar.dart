import 'package:flutter/material.dart';
import 'package:rando/providers/websocket_provider.dart';
import '../screens/index.dart';
import '../shared_preferences/shared_preferences.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/loginstate_provider.dart';
import '../providers/page_provider.dart';
import '../providers/websocket_provider.dart';
import '../global.dart';

Future<bool> checkIfLoggedIn() async {
  bool isLoggedIn;
  if (getToken() == '') {
    isLoggedIn = false;
  } else {
    isLoggedIn = true;
  }
  return isLoggedIn;
}

class MainAppBar extends ConsumerWidget implements PreferredSizeWidget {
  final Color color;
  final String userId;

  MainAppBar(this.color, this.userId);

  @override
  Size get preferredSize => const Size.fromHeight(55);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final checkLoggedInState = ref.watch(authStateProvider);
    print('current_user: ${userId}');

    return Container(
      color: color,
      width: MediaQuery.of(context).size.width,
      height: 100,
      child: Row(
        children: [
          checkLoggedInState
              ? SizedBox(
                  width: MediaQuery.of(context).size.width * 0.15,
                )
              : SizedBox(
                  width: MediaQuery.of(context).size.width * 0.15,
                  child: Align(
                    alignment: const Alignment(0, 1.25),
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    ),
                  )),
          SizedBox(
            width: MediaQuery.of(context).size.width * 0.3,
            child: Align(
              alignment: const Alignment(0.8, 0.9),
              child: Image.asset(
                'assets/images/logo.png',
                width: 33,
                height: 33,
              ),
            ),
          ),
          SizedBox(
            width: MediaQuery.of(context).size.width * 0.35,
            child: const Align(
              alignment: Alignment(-1, 0.95),
              child: Text(
                'Rando',
                style: TextStyle(
                  fontFamily: 'Comfortaa',
                  fontWeight: FontWeight.bold,
                  fontSize: 28,
                ),
              ),
            ),
          ),
          SizedBox(
              child: Align(
            alignment: const Alignment(0, 1.25),
            child: IconButton(
              icon: Icon(Icons.logout),
              onPressed: () {
                removeToken(userId);
                ref.read(authStateProvider.notifier).logout();
                ref.read(selectPageProvider.notifier).togglePage(0);

                final webSocketServiceNotifier =
                    ref.read(webSocketServiceNotifierProvider);

                webSocketServiceNotifier.close();
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (ctx) => IndexPage())); // 当点击箭头图标时，返回上一页面
              },
            ),
          ))
        ],
      ),
    );
  }
}
