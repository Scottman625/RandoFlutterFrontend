import '../models/user.dart';
import '../HexColor.dart';
import '../shared_preferences/shared_preferences.dart';
import './edit_profile.dart';

import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'dart:math';
import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';

class ProfilePageScreen extends StatefulWidget {
  final String userId;
  const ProfilePageScreen({super.key, required this.userId});

  @override
  State<ProfilePageScreen> createState() => _ProfilePageScreenState();
}

class _ProfilePageScreenState extends State<ProfilePageScreen> {
  late User user;

  Future<User> getUserData() async {
    String token = await getToken();
    String authToken = 'token ${token}';
    final response = await http.get(
      Uri.parse('http://127.0.0.1:8000/api/user/get_user/'),
      headers: {
        'Authorization': authToken,
      },
    );
    // if (response.statusCode == 200) {
    String body = utf8.decode(response.bodyBytes);
    print(body);
    User user = User.fromJson(json.decode(body));
    return user;
    // }
  }

  @override
  void initState() {
    super.initState();
    getUserData().then((value) {
      setState(() {
        user = value;
      });
    });
    // This function fetches data and then sets the state.
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: getUserData(), // Some async function that initializes `user`
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator();
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        } else if (snapshot.connectionState == ConnectionState.done) {
          final user = snapshot.data;
          print(snapshot.data);
          return SizedBox(
            child: Column(
              children: [
                Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                      child: SizedBox(
                          height: MediaQuery.of(context).size.height * 0.3,
                          width: MediaQuery.of(context).size.width * 0.4,
                          child: Stack(children: [
                            SizedBox(
                              height: MediaQuery.of(context).size.height * 160,
                              width: MediaQuery.of(context).size.width * 160,
                              child: CustomPaint(
                                painter: CircularProgressPainter(
                                    progress: 0.8,
                                    color: HexColor.fromHex('#4FC5EA')),
                              ),
                            ),
                            Center(
                              child: ClipOval(
                                child: CachedNetworkImage(
                                  imageUrl: user.image,
                                  width: 148,
                                  height: 148,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            Align(
                              alignment: Alignment(0.1, 0.6),
                              child: Container(
                                height: 30,
                                width: 110,
                                //
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(30),
                                  color: HexColor.fromHex('#4FC5EA'),
                                ),
                                child: const Center(
                                    child: Text(
                                  '85%已完成',
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold),
                                )),
                              ),
                            ),
                            Align(
                              alignment: const Alignment(0.7, 0.3),
                              child: ClipOval(
                                child: Container(
                                  color: Colors.white,
                                  height: 40,
                                  width: 40,
                                  child: IconButton(
                                      onPressed: () {
                                        Navigator.of(context)
                                            .push(MaterialPageRoute(
                                          builder: (ctx) => EditProfileScreen(
                                            // chatroomList: jsonEncode(widget.chatroomList),

                                            user: user,
                                          ),
                                        ));
                                      },
                                      icon: const Icon(Icons.edit)),
                                ),
                              ),
                            )
                          ])),
                    ),
                    Expanded(
                      child: Column(
                        children: [
                          Center(
                            child: Padding(
                                padding: const EdgeInsets.all(10),
                                child: SizedBox(
                                  height: 40,
                                  child: Text(
                                    '${user.name}, ${user.age}',
                                    style: const TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold),
                                  ),
                                )),
                          ),
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 10.0),
                            child: Container(
                              height: 60,
                              width: 170,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(30),
                                color: HexColor.fromHex('#3AEAF6'),
                              ),
                              child: Row(
                                children: [
                                  const Column(
                                    children: [
                                      SizedBox(
                                        width: 80,
                                        height: 30,
                                        child: Align(
                                          alignment: Alignment.bottomRight,
                                          child: Text(
                                            '收到喜歡',
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                color: Colors.white),
                                          ),
                                        ),
                                      ),
                                      Padding(
                                        padding: EdgeInsets.only(left: 24.0),
                                        child: Center(
                                            child: Icon(
                                          Icons.favorite,
                                          color: Colors.red,
                                        )),
                                      )
                                    ],
                                  ),
                                  Expanded(
                                    child: Center(
                                      child: Text(
                                        user.total_likes_count.toString(),
                                        style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 24,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Row(
                              children: [
                                ClipOval(
                                    child: Container(
                                  height: 30,
                                  width: 30,
                                  color: Colors.blueAccent,
                                  child: const Icon(
                                    Icons.check,
                                    color: Colors.white,
                                  ),
                                )),
                                const Text(
                                  '  真人認證',
                                  style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w900),
                                )
                              ],
                            ),
                          )
                        ],
                      ),
                    )
                  ],
                )
              ],
            ),
          );
        } else {
          // Handle other states if necessary
          return CircularProgressIndicator();
        }
      },
    );
  }
}

class CircularProgressPainter extends CustomPainter {
  final double progress;
  final Color color;

  CircularProgressPainter({required this.progress, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final Offset center = Offset(size.width / 2, size.height / 2);
    final double radius = min(size.width / 2, size.height / 2);
    final double strokeWidth = 4.0;

    final Paint paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = strokeWidth;

    // 畫背景
    paint.color = HexColor.fromHex('#E1E1E1', opacity: 7);
    canvas.drawCircle(center, radius, paint);

    // 畫進度
    paint.color = color;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      1 * pi / 2,
      progress * 2 * pi,
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
