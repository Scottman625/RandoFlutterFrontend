import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/chatMessage.dart';
import '../screens/chat_list.dart';
import 'package:web_socket_channel/io.dart';

class ChatRoomNotifier extends StateNotifier<List<ChatRoom>> {
  IOWebSocketChannel? _channel;

  ChatRoomNotifier() : super([]) {
    _initializeWebSocket();
  }

  void _initializeWebSocket() {
    _channel = IOWebSocketChannel.connect(
        'ws://127.0.0.1:8000/ws/chatroom_unread_nums/');

    _channel!.stream.listen((message) async {
      final newChatRooms = await fetchChatRooms();
      state = newChatRooms; // 更新聊天室列表
    });
  }

  @override
  void dispose() {
    _channel?.sink.close();
    super.dispose();
  }
}

final chatRoomProvider =
    StateNotifierProvider<ChatRoomNotifier, List<ChatRoom>>(
        (ref) => ChatRoomNotifier());
