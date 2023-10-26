import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../web_socket.dart';
import '../providers/userId_provider.dart';

// class WebSocketServiceNotifier extends StateNotifier<WebSocketService> {
//   WebSocketServiceNotifier(String url) : super(WebSocketService(url));

//   void disconnectWebSocket() {
//     print('test disconnect');
//     state.close();
//     print('websocket is close');
//   }

//   bool isWebSocketConnected() {
//     return state.isWebSocketConnected();
//   }
// }

// final webSocketServiceNotifierProvider =
//     StateNotifierProvider<WebSocketServiceNotifier, WebSocketService>((ref) {
//   final userId = ref.watch(userIdProvider);
//   print('userID: $userId');
//   return WebSocketServiceNotifier(
//       'ws://127.0.0.1:8000/ws/chatRoomMessages/$userId');
// });

class WebSocketServiceNotifier extends StateNotifier<WebSocketService> {
  WebSocketServiceNotifier(String url) : super(WebSocketService(url));

  void subscribeToTopic(String topic) {
    state.stompClient.subscribe(
        destination: topic,
        callback: (frame) {
          // 处理收到的消息，并更新状态或做其他你需要的操作
          print(frame.body);
        });
  }

  void disconnectWebSocket() {
    print('test disconnect');
    state.close();
    print('websocket is close');
  }

  bool isWebSocketConnected() {
    return state.stompClient.connected;
  }
}

final webSocketServiceNotifierProvider =
    StateNotifierProvider<WebSocketServiceNotifier, WebSocketService>((ref) {
  final userId = ref.watch(userIdProvider);
  print('userID: $userId');
  return WebSocketServiceNotifier(
      'ws://127.0.0.1:8000/ws/chatRoomMessages/$userId');
});
