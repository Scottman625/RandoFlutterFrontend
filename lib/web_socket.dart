import 'package:web_socket_channel/web_socket_channel.dart';

final WebSocketService webSocketService = WebSocketService();

class WebSocketService {
  WebSocketChannel? _channel;

  void connect(String url) {
    if (_channel == null || _channel!.closeCode != null) {
      _channel = WebSocketChannel.connect(Uri.parse(url));
    }
  }

  void disconnect() {
    if (_channel != null) {
      _channel!.sink.close();
      _channel = null;
    }
  }

  // TODO: 在這裡添加你的WebSocket訊息傳送方法，例如 send(String message)
}
