import 'package:flutter/material.dart';
import '../widgets/main_page_widget.dart';

class MainPageScreen extends StatefulWidget {
  // final String chatroomList;
  final String userId;
  const MainPageScreen({
    super.key,
    // required this.chatroomList,
    required this.userId,
  });

  @override
  State<MainPageScreen> createState() => _MainPageScreen();
}

class _MainPageScreen extends State<MainPageScreen> {
  @override
  Widget build(BuildContext context) {
    print('current_user: ${widget.userId}');
    return Scaffold(
        backgroundColor: Colors.white,
        body: SizedBox(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            child: MainPageWidget(
              // chatroomList: widget.chatroomList,
              userId: widget.userId,
            )));
  }
}
