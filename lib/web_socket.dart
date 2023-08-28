import 'package:web_socket_channel/io.dart';
import 'dart:async';
import './models/chatMessage.dart';
import 'package:rxdart/rxdart.dart';
import 'dart:convert';

class WebSocketService {
  BehaviorSubject<dynamic>? _subject;
  IOWebSocketChannel? _channel;

  WebSocketService(String url) {
    _subject = BehaviorSubject<dynamic>();
    create(url);
  }

  void create(String url) {
    _channel = IOWebSocketChannel.connect(url);
    _channel!.stream.listen(
      (event) {
        // print('Received event: $event'); // Add this line
        _subject!.add(event);
      },
      onError: (err) {
        print('Received error: $err'); // And this one
        _subject!.addError(err);
      },
      onDone: _subject!.close,
      cancelOnError: true,
    );
  }

  Stream<List<ChatRoom>> get chatRoomsStream {
    return _subject!.stream.transform(
      StreamTransformer.fromHandlers(
        handleData: (jsonString, sink) {
          if (jsonString != null && jsonString.isNotEmpty) {
            try {
              var map = jsonDecode(jsonString);
              if (map['type'] == 'chatrooms' && map['chatrooms'] != null) {
                List<dynamic> list = map['chatrooms'];
                List<ChatRoom> chatRooms =
                    list.map((e) => ChatRoom.fromJson(e)).toList();
                sink.add(chatRooms);
              }
            } catch (e) {
              print('Failed to decode JSON: $e');
            }
          }
        },
      ),
    );
  }

  Stream<List<ChatMessage>> get chatMessageStream {
    return _subject!.stream.transform(
      StreamTransformer.fromHandlers(
        handleData: (jsonString, sink) {
          // print('jsonString: ${jsonString}');
          if (jsonString != null && jsonString.isNotEmpty) {
            try {
              var map = jsonDecode(jsonString);

              List<dynamic> list = map['messages'] ?? [];
              List<ChatMessage> messages =
                  list.map((e) => ChatMessage.fromJson(e)).toList();
              sink.add(messages);
            } catch (e) {
              print('Failed to decode JSON: $e');
              sink.addError(e);
            }
          } else {
            sink.add([]); // Add an empty list when jsonString is null or empty
          }
        },
      ),
    );
  }

  void addData(dynamic data) {
    _subject!.add(data);
    _channel?.sink.add(data);
  }

  bool isWebSocketConnected() {
    print(_subject);
    return _subject != null;
  }

  Stream<dynamic> get stream => _subject!.stream;

  void close() {
    _channel?.sink.close();
    _subject!.close();
  }
}
