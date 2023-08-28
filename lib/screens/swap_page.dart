import 'package:flutter/material.dart';
import 'package:rando/screens/main_page.dart';
import 'package:rando/screens/profile_page.dart';
import 'package:rando/widgets/main_appbar.dart';
import 'package:rando/widgets/main_navbar.dart';
import '../widgets/profile_card.dart';
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

class SwapPageScreen extends StatefulWidget {
  final String userId;
  const SwapPageScreen({
    super.key,
    required this.userId,
  });

  @override
  State<SwapPageScreen> createState() => _SwapPageScreenState();
}

class _SwapPageScreenState extends State<SwapPageScreen>
    with SingleTickerProviderStateMixin {
  late final CardSwiperController controller;
  List<User> profiles = [];
  late CardSwiper customCardSwiper; // Use the custom CardSwiper
  Future<List<User>>? usersFuture;

  Future<List<User>> fetchUsers() async {
    final token = await getToken();
    String auth_token = 'token ${token}';
    final response = await http.get(
      Uri.parse('http://127.0.0.1:8000/api/user_picked'),
      headers: {
        'Authorization': auth_token,
      },
    );

    if (response.statusCode == 200) {
      // If the server returns a 200 OK response,
      // then parse the JSON.
      String body = utf8.decode(response.bodyBytes);
      Iterable list = json.decode(body);
      profiles = list.map((user) => User.fromJson(user)).toList();
      return profiles;
    } else {
      // If the server
      //response is not a 200 OK,
      // then throw an exception.
      // print('test');
      throw <User>[];
    }
  }

  void handleUpdateCardCount() {
    setState(() async {
      profiles = await fetchUsers(); // 或任何你需要的逻辑来更新profiles列表
    });
  }

  @override
  void initState() {
    super.initState();
    usersFuture = fetchUsers();
    controller = CardSwiperController(this);
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
        child: FutureBuilder<List<User>>(
      future: usersFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator();
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Text('No users available.');
        } else {
          profiles = snapshot.data!;
          if (profiles.length == 0) {
            return Text('No profiles available.');
          } else if (profiles.length == 1) {
            // 这里你可以选择如何显示单张卡片
            print('cardscount = 1');
            return CardSwiper(
              controller: controller,
              cardsCount: 1,
              updateCardCountCallback: handleUpdateCardCount,
              onSwipe: (previousIndex, currentIndex, direction) => _onSwipe(
                  previousIndex,
                  currentIndex,
                  direction,
                  profiles[currentIndex!].id.toString()),
              onUndo: _onUndo,
              cardBuilder: (
                context,
                index,
                horizontalThresholdPercentage,
                verticalThresholdPercentage,
              ) =>
                  ProfileCard(profiles[0], controller),
            );
          } else {
            return CardSwiper(
              controller: controller,
              cardsCount: profiles.length,
              updateCardCountCallback: handleUpdateCardCount,
              onSwipe: (previousIndex, currentIndex, direction) => _onSwipe(
                  previousIndex,
                  currentIndex,
                  direction,
                  profiles[currentIndex! - 1].id.toString()),
              onUndo: _onUndo,
              cardBuilder: (
                context,
                index,
                horizontalThresholdPercentage,
                verticalThresholdPercentage,
              ) =>
                  ProfileCard(profiles[index], controller),
            );
          }
        }
      },
    ));
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  Future<bool> _onSwipe(
    int previousIndex,
    int? currentIndex,
    CardSwiperDirection direction,
    String profileId,
  ) async {
    debugPrint(
      // 'The card $previousIndex was swiped to the ${direction.name}. Now the card $currentIndex is on top',
      'profileId: ${profileId}',
    );
    if (currentIndex != null && currentIndex < profiles.length) {
      if (direction.name != 'left') {
        print('123');
        try {
          final token = await getToken();
          String auth_token = 'token ${token}';
          final response = await http.post(
              Uri.parse('http://127.0.0.1:8000/api/user_picked'),
              headers: {
                'Authorization': auth_token,
              },
              body: {
                'liked_user_id': profileId,
                'is_like': 'True',
              });
          if (response.statusCode == 200) {
            print('456');
            String body = utf8.decode(response.bodyBytes);
            String result = json.decode(body)['result'];
            setState(() {
              // Update profiles by removing the swiped profile
              // profiles.removeAt(currentIndex);
            });
            if (result == 'is matched') {
              Navigator.of(context).push(MaterialPageRoute(
                  builder: (ctx) => MatchScreen(
                        userId: widget.userId,
                      )));
            }
          }
        } catch (e) {
          print('Caught exception: $e');
        }
      } else if (direction.name == 'left') {
        try {
          final token = await getToken();
          String auth_token = 'token ${token}';
          final response = await http.post(
              Uri.parse('http://127.0.0.1:8000/api/user_picked'),
              headers: {
                'Authorization': auth_token,
              },
              body: {
                'liked_user_id': profileId,
                'is_like': 'False',
              });
          if (response.statusCode == 200) {
            String body = utf8.decode(response.bodyBytes);
            String result = json.decode(body)['result'];
            setState(() {
              // Update profiles by removing the swiped profile
              // profiles.removeAt(currentIndex);
            });
            if (result == 'is matched') {
              Navigator.of(context).push(MaterialPageRoute(
                  builder: (ctx) => MatchScreen(
                        userId: widget.userId,
                      )));
            }
          }
        } catch (e) {
          print('Caught exception: $e');
        }
      }
    }

    return true;
  }

  bool _onUndo(
    int? previousIndex,
    int currentIndex,
    CardSwiperDirection direction,
  ) {
    debugPrint(
      'The card $currentIndex was undod from the ${direction.name}',
    );

    return true;
  }
}
