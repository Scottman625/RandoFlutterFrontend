import 'package:flutter/material.dart';
import 'main_page.dart';
import '../widgets/main_appbar.dart';
import '../widgets/main_navbar.dart';

class ProfileSwapScreen extends StatefulWidget {
  const ProfileSwapScreen({super.key});

  @override
  State<ProfileSwapScreen> createState() => _ProfileSwapScreen();
}

class _ProfileSwapScreen extends State<ProfileSwapScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        body: Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            child: MainPage()));
  }
}
