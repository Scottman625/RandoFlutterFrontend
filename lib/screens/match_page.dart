import 'package:flutter/material.dart';
import '../widgets/main_appbar.dart';

class MatchScreen extends StatefulWidget {
  final String userId;

  const MatchScreen({
    super.key,
    // required this.chatroomList,
    required this.userId,
  });

  @override
  State<MatchScreen> createState() => _MatchScreenState();
}

class _MatchScreenState extends State<MatchScreen> {
  double topPosition = -100; // 初始化在屏幕外部
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // 延遲200毫秒開始動畫
    Future.delayed(Duration(milliseconds: 200), () {
      if (mounted) {
        setState(() {
          topPosition = MediaQuery.of(context).size.height * 0.2 - 50;
        });

        // 再次延遲3秒使文字滑出屏幕
        Future.delayed(Duration(seconds: 3), () {
          if (mounted) {
            setState(() {
              topPosition = -100;
            });
          }
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          SizedBox(
            height: 300,
            child: Stack(
              children: [
                AnimatedPositioned(
                  duration: Duration(seconds: 1),
                  top: topPosition,
                  left: 0,
                  right: 0,
                  child: const Center(
                    child: Text(
                      "Matched!",
                      style: TextStyle(
                        fontSize: 50,
                        fontWeight: FontWeight.bold,
                        color: Colors.greenAccent,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            height: 50, // you can adjust the height as needed
            child: TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(
                '繼續探索',
                style: TextStyle(color: Colors.black, fontSize: 24),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
