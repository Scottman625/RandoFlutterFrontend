import 'package:web_socket_channel/io.dart';
import 'dart:async';
import './models/chatMessage.dart';
import 'package:rxdart/rxdart.dart';
import 'dart:convert';
import 'dart:io';
import 'package:stomp_dart_client/stomp.dart';
import 'package:stomp_dart_client/stomp_config.dart';
import 'package:stomp_dart_client/stomp_frame.dart';

class WebSocketService {
  // BehaviorSubject<dynamic>? _subject;
  IOWebSocketChannel? _channel;
  // String url = '';
  late StompClient stompClient;
  BehaviorSubject<dynamic> _subject = BehaviorSubject<dynamic>();

  WebSocketService(String url) {
    String userId = url.split("ws://127.0.0.1:8000/ws/chatRoomMessages/")[1];
    stompClient = StompClient(
      config: StompConfig(
        url: url,
        onConnect: (StompFrame frame) {
          stompClient.subscribe(
            destination: '/topic/chatRoomMessages_$userId',
            callback: (frame) {
              Map<String, dynamic>? result = json.decode(frame.body!);
              print(result);
              _subject.add(jsonEncode(result));
            },
          );

          Timer.periodic(const Duration(seconds: 10), (_) {
            stompClient.send(
              destination: '/app/chatRoomMessages_$userId',
              body: json.encode({'a': 123}),
            );
          });
        },
        onWebSocketError: (dynamic error) {
          _subject.addError(error);
        },
        onStompError: (StompFrame frame) {
          _subject.addError(frame);
        },
        onUnhandledFrame: (StompFrame frame) {
          _subject.add(frame);
        },
      ),
    );

    stompClient.activate();
  }

  BehaviorSubject<dynamic> get subject => _subject;
  Stream<dynamic> get messageStream => _subject.stream;

  void close() {
    stompClient.deactivate();
    _subject.close();
  }

  Stream<List<ChatRoom>> get chatRoomsStream {
    return _subject.stream.transform(
      StreamTransformer.fromHandlers(
        handleData: (jsonString, sink) {
          if (jsonString != null && jsonString.isNotEmpty) {
            try {
              var map = jsonDecode(jsonString);
              if (map['chatrooms'] != null) {
                List<dynamic> list = map['chatrooms'];

                List<ChatRoom> chatRooms =
                    list.map((e) => ChatRoom.fromJson(e)).toList();

                sink.add(chatRooms);
              }
            } catch (e) {}
          }
        },
      ),
    );
  }

  Stream<List<ChatMessage>> get chatMessageStream {
    // _subject.stream.listen((data) {
    //   final filePath =
    //       '/Users/fangshengjie/Desktop/filename.txt'; // 请替换为实际的文件路径

    //   writeStringToFile('$data', filePath);
    // });
    return _subject.stream.transform(
      StreamTransformer.fromHandlers(
        handleData: (jsonString, sink) {
          // print('jsonString: ${jsonString}');
          if (jsonString != null && jsonString.isNotEmpty) {
            try {
              var map = jsonDecode(jsonString);
              List<dynamic> list = map['messages'] ?? [];

              List<ChatMessage> messages =
                  list.map((e) => ChatMessage.fromJson(e)).toList();
              // print('messages: $messages');
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
}

void printInParts(String text, int partLength) {
  for (int i = 0; i < text.length; i += partLength) {
    print(text.substring(
        i, i + partLength <= text.length ? i + partLength : text.length));
  }
}

void writeStringToFile(String content, String filePath) async {
  final file = File(filePath);

  try {
    // 将字符串写入文件
    await file.writeAsString(content);

    print('字符串已成功写入文件: $filePath');
  } catch (e) {
    print('写入文件时出错: $e');
  }
}
