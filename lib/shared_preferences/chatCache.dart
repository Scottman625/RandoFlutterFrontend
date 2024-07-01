import 'dart:convert';
import '../models/chatRoom.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class ChatCache {
  Future<void> saveChatRooms(List<ChatRoom> chatRooms) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> chatRoomsJson =
        chatRooms.map((chatRoom) => jsonEncode(chatRoom.toJson())).toList();
    await prefs.setStringList('chatroom_list', chatRoomsJson);
  }

  Future<List<ChatRoom>> loadChatRooms() async {
    final prefs = await SharedPreferences.getInstance();
    List<String>? chatRoomsJson = prefs.getStringList('chatroom_list');
    if (chatRoomsJson != null) {
      return chatRoomsJson
          .map((chatRoomJson) => ChatRoom.fromJson(jsonDecode(chatRoomJson)))
          .toList();
    }
    return [];
  }
}
