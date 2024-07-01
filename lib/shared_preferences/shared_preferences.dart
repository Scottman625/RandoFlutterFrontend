import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import '../models/user.dart';
import '../models/chatRoom.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';

void saveToken(String token) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.setString('token', token);
}

Future<String> getToken() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String token = prefs.getString('token') ?? '';
  if (token == '') {
    debugPrint('token is empty');
  }
  // print(token);
  return token;
}

void removeToken(userId) async {
  // print('logout');
  SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.remove('token');
}

Future<List<User>> fetchMatches() async {
  final token = await getToken();
  String auth_token = 'Bearer ${token}';
  final response = await http.get(
    Uri.parse('https://randojavabackend.zeabur.app/api/matched_not_chatted'),
    headers: {
      'Authorization': auth_token,
    },
  );

  if (response.statusCode == 200) {
    // If the server returns a 200 OK response,
    // then parse the JSON.
    String body = utf8.decode(response.bodyBytes);
    Iterable list = json.decode(body);
    // print(list);
    return list.map((match) => User.fromJson(match)).toList();
  } else {
    // If the server
    //response is not a 200 OK,
    // then throw an exception.
    // print('test');
    throw <User>[];
  }
}

void fetchChatRoomsList() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  final token = await getToken();

  String auth_token = 'Bearer ${token}';
  final response = await http.get(
    Uri.parse('https://randojavabackend.zeabur.app/api/chatroom'),
    headers: {
      'Authorization': auth_token,
    },
  );

  if (response.statusCode == 200) {
    // If the server returns a 200 OK response,
    // then parse the JSON.
    String body = utf8.decode(response.bodyBytes);
    Iterable list = json.decode(body);

    List<ChatRoom> chatroom_list =
        list.map((match) => ChatRoom.fromJson(match)).toList();

    await prefs.setString('chatroom_list', jsonEncode(chatroom_list));
  } else {
    // If the server response is not a 200 OK,
    // then throw an exception.
    throw <ChatRoom>[];
  }
}
