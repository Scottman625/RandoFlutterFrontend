import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../web_socket.dart';

class WebSocketServiceNotifier extends StateNotifier<WebSocketService> {
  WebSocketServiceNotifier(String url) : super(WebSocketService(url));

  void disconnectWebSocket() {
    print('test disconnect');
    state.close();
    print('websocket is close');
  }

  bool isWebSocketConnected() {
    return state.isWebSocketConnected();
  }
}

final webSocketServiceProvider = StateNotifierProvider.family<
    WebSocketServiceNotifier, WebSocketService, String>((ref, url) {
  return WebSocketServiceNotifier(url);
});
