import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/chatMessage.dart';

class ChatRoomStateNotifier extends StateNotifier<bool> {
  ChatRoomStateNotifier() : super(false);

  bool isSendMessage() {
    state = true;
    return state;
  }
}

final chatRoomNotifierProvider =
    StateNotifierProvider<ChatRoomStateNotifier, bool>((ref) {
  return ChatRoomStateNotifier();
});
