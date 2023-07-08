import 'package:flutter/material.dart';
import 'package:rando/models/chatMessage.dart';
import '../token/user_token.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart' as intl;
import 'dart:async';
import 'dart:math';
import 'package:web_socket_channel/io.dart';

class ChatRoomScreen extends ConsumerStatefulWidget {
  final int chatroomId;
  final String otherSideImageUrl;
  final int currentUserId;

  const ChatRoomScreen(
      {Key? key,
      required this.chatroomId,
      required this.otherSideImageUrl,
      required this.currentUserId})
      : super(key: key);
  // const ChatRoomScreen({super.key, required this.chatroomId});

  @override
  ConsumerState<ChatRoomScreen> createState() => _ChatRoomScreenState();
}

extension HexColor on Color {
  /// String is in the format "aabbcc" or "ffaabbcc" with an optional leading "#".
  static Color fromHex(String hexString) {
    final buffer = StringBuffer();
    if (hexString.length == 6 || hexString.length == 7) buffer.write('ff');
    buffer.write(hexString.replaceFirst('#', ''));
    return Color(int.parse(buffer.toString(), radix: 16));
  }

  /// Prefixes a hash sign if [leadingHashSign] is set to `true` (default is `true`).
  String toHex({bool leadingHashSign = true}) => '${leadingHashSign ? '#' : ''}'
      '${alpha.toRadixString(16).padLeft(2, '0')}'
      '${red.toRadixString(16).padLeft(2, '0')}'
      '${green.toRadixString(16).padLeft(2, '0')}'
      '${blue.toRadixString(16).padLeft(2, '0')}';
}

class _ChatRoomScreenState extends ConsumerState<ChatRoomScreen> {
  // final List<String> messages = [];
  final TextEditingController textEditingController = TextEditingController();
  final Color color = HexColor.fromHex('#DDE5F0');

  final ScrollController _scrollController = ScrollController();

// This is what you're looking for!

  Future<ChatRoom> fetchOtherSideUserData(int chatroomId) async {
    final token = await getToken();
    String authToken = 'token ${token}';
    // print(authToken);
    String url = 'http://127.0.0.1:8000/api/chatroom/${chatroomId.toString()}/';
    final response = await http.get(
      Uri.parse(url),
      headers: {
        'Authorization': authToken,
      },
    );

    if (response.statusCode == 200) {
      // If the server returns a 200 OK response,
      // then parse the JSON.

      String body = utf8.decode(response.bodyBytes);
      Map<String, dynamic> chatroomMap = json.decode(body);
      ChatRoom chatroom = ChatRoom.fromJson(chatroomMap);
      // Iterable list = json.decode(body);
      // print(chatroomMap);
      return chatroom;
    } else {
      // If the server response is not a 200 OK,
      // then throw an exception.
      throw <ChatMessage>[];
    }
  }

  void _sendMessage(int chatroomId, String content) async {
    final token = await getToken();
    String auth_token = 'token ${token}';

    // print(auth_token);

    final response = await http.post(
        Uri.parse(
            'http://127.0.0.1:8000/api/messages?chatroom_id=${chatroomId.toString()}'),
        headers: {
          'Authorization': auth_token,
        },
        body: {
          'content': content,
        });
    if (response.statusCode == 200) {
      String body = utf8.decode(response.bodyBytes);
      // print(json.decode(body));
    }
  }

  final _controller = StreamController<List<ChatMessage>>();
  IOWebSocketChannel? _channel;

  @override
  void initState() {
    super.initState();
    _loadInitialMessages();
    _initWebSocket();
  }

  Future<void> _loadInitialMessages() async {
    final token = await getToken();
    String authToken = 'token ${token}';
    String url =
        'http://127.0.0.1:8000/api/messages?chatroom_id=${widget.chatroomId}';
    final response = await http.get(
      Uri.parse(url),
      headers: {
        'Authorization': authToken,
      },
    );
    String body = utf8.decode(response.bodyBytes);
    final List<dynamic> messageList = jsonDecode(body);

    final messages =
        messageList.map((item) => ChatMessage.fromJson(item)).toList();

    _controller.add(messages);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      print(_scrollController.hasClients);
      if (_scrollController.hasClients) {
        _scrollController.jumpTo(
          _scrollController.position.maxScrollExtent,
        );
      }
    });
  }

  void _initWebSocket() {
    _channel = IOWebSocketChannel.connect(
        'ws://127.0.0.1:8000/ws/chat/${widget.chatroomId}/');
    _channel!.stream.listen((event) {
      final decodedJson = jsonDecode(event);
      final messages = decodedJson['messages'] as List;
      final chatMessages = messages
          .map((messageJson) => ChatMessage.fromJson(messageJson))
          .toList();
      _controller.add(chatMessages);

      WidgetsBinding.instance.addPostFrameCallback((_) {
        print('hahahaha');
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Colors.white,
        child: Column(
          children: <Widget>[
            Container(
              color: Colors.white,
              width: MediaQuery.of(context).size.width,
              height: 125,
              child: Row(
                children: [
                  SizedBox(
                      width: MediaQuery.of(context).size.width * 0.15,
                      child: Align(
                        alignment: const Alignment(0, 0.7),
                        child: IconButton(
                          icon: const Icon(Icons.arrow_back),
                          onPressed: () {
                            Navigator.pop(context); // 当点击箭头图标时，返回上一页面
                          },
                        ),
                      )),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: SizedBox(
                      child: Align(
                        alignment: const Alignment(0, 1),
                        child: ClipOval(
                          child: Image.asset(
                            widget.otherSideImageUrl,
                            height: 50,
                            width: 50,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.35,
                  ),
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.15,
                    child: const Align(
                      alignment: Alignment(0, 0.6),
                      child: Icon(
                        Icons.call,
                        color: Colors.lightBlueAccent,
                        size: 35,
                      ),
                    ),
                  ),
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.15,
                    child: const Align(
                      alignment: Alignment(0, 0.6),
                      child: Icon(
                        Icons.info_outline,
                        // color: Colors.white,
                        size: 35,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Container(
                height: MediaQuery.of(context).size.height * 0.7,
                width: MediaQuery.of(context).size.width,
                color: Colors.white,
                child: Column(
                  children: [
                    Expanded(child: fetchMessageData()),
                  ],
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                  color: color, borderRadius: BorderRadius.circular(50)),
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: TextField(
                      controller: textEditingController,
                      decoration: const InputDecoration(
                        hintText: "輸入訊息",
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.send),
                    onPressed: () {
                      setState(() {
                        _sendMessage(
                            widget.chatroomId, textEditingController.text);
                        textEditingController.clear();
                      });
                    },
                  ),
                ],
              ),
            ),
            Row(
              children: [
                GestureDetector(
                  child: SizedBox(
                    width: MediaQuery.of(context).size.width * 0.3,
                    height: MediaQuery.of(context).size.height * 0.08,
                    child: const Icon(
                      Icons.mic,
                      size: 35,
                    ),
                  ),
                ),
                GestureDetector(
                  child: SizedBox(
                    width: MediaQuery.of(context).size.width * 0.3,
                    height: MediaQuery.of(context).size.height * 0.08,
                    child: const Icon(
                      Icons.gif_box_rounded,
                      size: 35,
                    ),
                  ),
                ),
                GestureDetector(
                  child: SizedBox(
                    width: MediaQuery.of(context).size.width * 0.3,
                    height: MediaQuery.of(context).size.height * 0.08,
                    child: const Icon(
                      Icons.collections,
                      size: 35,
                    ),
                  ),
                )
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget fetchMessageData() {
    return StreamBuilder<List<ChatMessage>>(
      initialData: [],
      stream: _controller.stream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator(); // 顯示加載指示器
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}'); // 顯示錯誤信息
        } else {
          final messages = snapshot.data;
          return ListViewBuilder(messages!);
        }
      },
    );
  }

  Widget ListViewBuilder(List<ChatMessage> initialData) {
    return ListView.builder(
        controller: _scrollController,
        itemCount: initialData.length + 1,
        itemBuilder: (context, index) {
          if (index == 0) {
            return ListTile(
              title: FutureBuilder(
                future: fetchOtherSideUserData(widget.chatroomId),
                builder: (BuildContext context,
                    AsyncSnapshot<ChatRoom> asyncSnapshot) {
                  if (asyncSnapshot.connectionState ==
                      ConnectionState.waiting) {
                    return CircularProgressIndicator(); // 當 Future 還在執行時，顯示加載指示器
                  } else if (asyncSnapshot.hasError) {
                    return Text('Error: ${asyncSnapshot.error}');
                  } else {
                    if (asyncSnapshot.data != null) {
                      return Row(
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(
                              right: 8.0,
                            ),
                            child: Column(
                              children: [
                                SizedBox(
                                  height:
                                      MediaQuery.of(context).size.height * 0.3,
                                ),
                                ClipOval(
                                  child: Image.asset(
                                    asyncSnapshot.data!.other_side_user.image,
                                    height: 35,
                                    width: 35,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            height: MediaQuery.of(context).size.height * 0.35,
                            width: MediaQuery.of(context).size.width * 0.55,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20),
                                color: color),
                            child: Column(
                              children: [
                                ClipRRect(
                                  borderRadius: const BorderRadius.only(
                                      topLeft: Radius.circular(20),
                                      topRight: Radius.circular(20)),
                                  child: SizedBox(
                                    height: MediaQuery.of(context).size.height *
                                        0.23,
                                    child: Image.asset(
                                      widget.otherSideImageUrl,
                                      width: MediaQuery.of(context).size.width,
                                      height:
                                          MediaQuery.of(context).size.height,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  width:
                                      MediaQuery.of(context).size.width * 0.4,
                                  child: Padding(
                                    padding: const EdgeInsets.only(top: 4.0),
                                    child: Text(
                                      '${asyncSnapshot.data!.other_side_user.name} ${asyncSnapshot.data!.other_side_user.age}',
                                      style: const TextStyle(fontSize: 20),
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  width:
                                      MediaQuery.of(context).size.width * 0.5,
                                  child: Text(
                                    '3km, 台南 ${asyncSnapshot.data!.other_side_user.career}',
                                    style:
                                        const TextStyle(color: Colors.black45),
                                  ),
                                ),
                                SizedBox(
                                  width:
                                      MediaQuery.of(context).size.width * 0.5,
                                  child: Text(
                                    asyncSnapshot.data!.other_side_user.about_me
                                        .substring(
                                            0,
                                            min(
                                                24,
                                                asyncSnapshot
                                                    .data!
                                                    .other_side_user
                                                    .about_me
                                                    .length)),
                                    style: const TextStyle(fontSize: 16),
                                    // textAlign:
                                    //     TextAlign
                                    //         .left,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      );
                    } else {
                      return Text('Error: ${asyncSnapshot.error}');
                    }
                  }
                },
              ),
            );
          }
          return Padding(
            padding: initialData[index - 1].showMessageTime
                ? const EdgeInsets.only(
                    top: 8.0,
                  )
                : const EdgeInsets.only(
                    top: 4.0,
                  ),
            child: Container(
              child: initialData[index - 1].showMessageTime
                  ? ListTile(
                      title: Align(
                        alignment: Alignment.bottomCenter,
                        child: Text(
                            intl.DateFormat('yyyy-MM-dd HH:mm')
                                .format(initialData[index - 1].sendTime),
                            style: const TextStyle(
                                fontSize: 14, color: Colors.black54)),
                      ),
                      subtitle: Padding(
                        padding: const EdgeInsets.only(top: 10),
                        child: Row(
                          mainAxisAlignment: initialData[index - 1].user_id ==
                                  widget.currentUserId
                              ? MainAxisAlignment.end
                              : MainAxisAlignment.start,
                          children: [
                            initialData[index - 1].user_id ==
                                    widget.currentUserId
                                ? SizedBox(height: 40, width: 40)
                                : SizedBox(
                                    child: Padding(
                                      padding: const EdgeInsets.only(
                                        right: 16.0,
                                      ),
                                      child: ClipOval(
                                        child: Image.asset(
                                          widget.otherSideImageUrl,
                                          height: 35,
                                          width: 35,
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    ),
                                  ),
                            Container(
                                child: Column(
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(8),
                                      constraints: BoxConstraints(
                                        minWidth:
                                            MediaQuery.of(context).size.width *
                                                0.25,
                                        maxWidth:
                                            MediaQuery.of(context).size.width *
                                                0.75,
                                      ),
                                      decoration: BoxDecoration(
                                        color: color,
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Text(
                                        initialData[index - 1].message,
                                        style: const TextStyle(
                                            color: Colors.black, fontSize: 18),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ))
                          ],
                        ),
                      ),
                    )
                  : ListTile(
                      title: Row(
                        mainAxisAlignment: initialData[index - 1].user_id ==
                                widget.currentUserId
                            ? MainAxisAlignment.end
                            : MainAxisAlignment.start,
                        children: [
                          initialData[index - 1].user_id == widget.currentUserId
                              ? SizedBox(height: 40, width: 40)
                              : SizedBox(
                                  child: Padding(
                                    padding: const EdgeInsets.only(right: 16),
                                    child: ClipOval(
                                      child: Image.asset(
                                        widget.otherSideImageUrl,
                                        height: 35,
                                        width: 35,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                ),
                          Container(
                            padding: const EdgeInsets.all(8),
                            constraints: BoxConstraints(
                              minWidth:
                                  MediaQuery.of(context).size.width * 0.25,
                              maxWidth:
                                  MediaQuery.of(context).size.width * 0.75,
                            ),
                            decoration: BoxDecoration(
                              color: color,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              initialData[index - 1].message,
                              style: const TextStyle(
                                  color: Colors.black, fontSize: 18),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ],
                      ),
                    ),
            ),
          );
        });
  }

  @override
  void dispose() {
    _controller.close();
    _channel?.sink.close();
    super.dispose();
  }
}
