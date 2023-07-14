import 'package:flutter/material.dart';
import 'main_page.dart';

class ProfileSwapScreen extends StatefulWidget {
  // final String chatroomList;
  final String userId;
  const ProfileSwapScreen({
    super.key,
    // required this.chatroomList,
    required this.userId,
  });

  @override
  State<ProfileSwapScreen> createState() => _ProfileSwapScreen();
}

class _ProfileSwapScreen extends State<ProfileSwapScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        body: SizedBox(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            child: MainPage(
              // chatroomList: widget.chatroomList,
              userId: widget.userId,
            )));
  }
}
