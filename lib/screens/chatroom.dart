import 'package:flutter/material.dart';
import 'package:rando/models/chatMessage.dart';
import '../token/user_token.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

class ChatRoomScreen extends ConsumerStatefulWidget {
  final int chatroomId;
  final String otherSideImageUrl;
  const ChatRoomScreen(
      {Key? key, required this.chatroomId, required this.otherSideImageUrl})
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
  final List<String> messages = [];
  final TextEditingController textEditingController = TextEditingController();
  final Color color = HexColor.fromHex('#DDE5F0');

  Future<List<ChatMessage>> fetchMessages(int chatroomId) async {
    final token = await getToken();
    String auth_token = 'token ${token}';
    String url =
        'http://127.0.0.1:8000/api/messages?chatroom_id=${chatroomId.toString()}';
    final response = await http.get(
      Uri.parse(url),
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
      return list.map((message) => ChatMessage.fromJson(message)).toList();
    } else {
      // If the server response is not a 200 OK,
      // then throw an exception.
      throw <ChatMessage>[];
    }
  }

  Future<ChatRoom> fetchOtherSideUserData(int chatroomId) async {
    final token = await getToken();
    String authToken = 'token ${token}';
    print(authToken);
    String url =
        'http://127.0.0.1:8000/api/get_chatroom?chatroom_id=${chatroomId.toString()}';
    final response = await http.get(
      Uri.parse(url),
      headers: {
        'Authorization': authToken,
      },
    );

    // print()

    if (response.statusCode == 200) {
      // If the server returns a 200 OK response,
      // then parse the JSON.

      String body = utf8.decode(response.bodyBytes);
      Map<String, dynamic> chatroomMap = json.decode(body);
      ChatRoom chatroom = ChatRoom.fromJson(chatroomMap);
      // Iterable list = json.decode(body);
      // print(chatroom);
      return chatroom;
    } else {
      // If the server response is not a 200 OK,
      // then throw an exception.
      throw <ChatMessage>[];
    }
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
              child: SingleChildScrollView(
                child: Container(
                  height: MediaQuery.of(context).size.height * 0.7,
                  width: MediaQuery.of(context).size.width,
                  color: Colors.white,
                  child: Column(
                    children: [
                      Expanded(
                        child: FutureBuilder(
                            future: fetchMessages(widget.chatroomId),
                            builder: (BuildContext context,
                                AsyncSnapshot<List<ChatMessage>> snapshot) {
                              if (snapshot.hasData) {
                                return ListView.builder(
                                    itemCount: snapshot.data!.length + 1,
                                    itemBuilder: (context, index) {
                                      if (index == 0) {
                                        return ListTile(
                                          title: FutureBuilder(
                                            future: fetchOtherSideUserData(
                                                widget.chatroomId),
                                            builder: (BuildContext context,
                                                AsyncSnapshot<ChatRoom>
                                                    snapshot) {
                                              if (snapshot.data != null) {
                                                return Row(
                                                  children: [
                                                    Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                        right: 8.0,
                                                      ),
                                                      child: Column(
                                                        children: [
                                                          SizedBox(
                                                            height: MediaQuery.of(
                                                                        context)
                                                                    .size
                                                                    .height *
                                                                0.3,
                                                          ),
                                                          ClipOval(
                                                            child: Image.asset(
                                                              snapshot
                                                                  .data!
                                                                  .other_side_user
                                                                  .image,
                                                              height: 35,
                                                              width: 35,
                                                              fit: BoxFit.cover,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                    Container(
                                                      height:
                                                          MediaQuery.of(context)
                                                                  .size
                                                                  .height *
                                                              0.35,
                                                      width:
                                                          MediaQuery.of(context)
                                                                  .size
                                                                  .width *
                                                              0.55,
                                                      decoration: BoxDecoration(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(20),
                                                          color: color),
                                                      child: Column(
                                                        children: [
                                                          ClipRRect(
                                                            borderRadius: const BorderRadius
                                                                    .only(
                                                                topLeft: Radius
                                                                    .circular(
                                                                        20),
                                                                topRight: Radius
                                                                    .circular(
                                                                        20)),
                                                            child: SizedBox(
                                                              height: MediaQuery.of(
                                                                          context)
                                                                      .size
                                                                      .height *
                                                                  0.23,
                                                              child:
                                                                  Image.asset(
                                                                widget
                                                                    .otherSideImageUrl,
                                                                width: MediaQuery.of(
                                                                        context)
                                                                    .size
                                                                    .width,
                                                                height: MediaQuery.of(
                                                                        context)
                                                                    .size
                                                                    .height,
                                                                fit: BoxFit
                                                                    .cover,
                                                              ),
                                                            ),
                                                          ),
                                                          Text(
                                                            snapshot
                                                                    .data!
                                                                    .other_side_user
                                                                    .name +
                                                                ' ' +
                                                                snapshot
                                                                    .data!
                                                                    .other_side_user
                                                                    .age
                                                                    .toString(),
                                                            style: TextStyle(
                                                                fontSize: 20),
                                                          )
                                                        ],
                                                      ),
                                                    ),
                                                  ],
                                                ); // 数据加载中，显示一个加载指示器
                                              } else if (snapshot.hasError) {
                                                return Text(
                                                    'Error: ${snapshot.error}'); // 发生错误，显示错误信息
                                              }
                                              return const CircularProgressIndicator();
                                            },
                                          ),
                                        );
                                      }
                                      return Padding(
                                        padding: snapshot.data![index - 1]
                                                .showMessageTime
                                            ? const EdgeInsets.only(top: 18.0)
                                            : const EdgeInsets.only(top: 4.0),
                                        child: Container(
                                          height: snapshot.data![index - 1]
                                                  .showMessageTime
                                              ? MediaQuery.of(context)
                                                      .size
                                                      .height *
                                                  0.085
                                              : 50,
                                          child: snapshot.data![index - 1]
                                                  .showMessageTime
                                              ? ListTile(
                                                  title: Row(
                                                    children: [
                                                      SizedBox(
                                                        child: Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .only(
                                                            right: 16.0,
                                                          ),
                                                          child: ClipOval(
                                                            child: Image.asset(
                                                              // widget.otherSideImageUrl,
                                                              snapshot
                                                                  .data![
                                                                      index - 1]
                                                                  .other_side_image_url,
                                                              height: 35,
                                                              width: 35,
                                                              fit: BoxFit.cover,
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                      Expanded(
                                                          child: Column(
                                                        children: [
                                                          Align(
                                                            alignment:
                                                                const Alignment(
                                                                    -0.5, 0),
                                                            child: Padding(
                                                              padding:
                                                                  const EdgeInsets
                                                                      .only(
                                                                bottom: 8,
                                                              ),
                                                              child: Text(
                                                                  DateFormat(
                                                                          'yyyy-MM-dd HH:mm')
                                                                      .format(snapshot
                                                                          .data![index -
                                                                              1]
                                                                          .sentTime),
                                                                  style: const TextStyle(
                                                                      fontSize:
                                                                          14,
                                                                      color: Colors
                                                                          .black54)),
                                                            ),
                                                          ),
                                                          Row(
                                                            children: [
                                                              Container(
                                                                padding:
                                                                    const EdgeInsets
                                                                        .all(8),
                                                                constraints:
                                                                    BoxConstraints(
                                                                  minWidth: MediaQuery.of(
                                                                              context)
                                                                          .size
                                                                          .width *
                                                                      0.25,
                                                                  maxWidth: MediaQuery.of(
                                                                              context)
                                                                          .size
                                                                          .width *
                                                                      0.75,
                                                                ),
                                                                decoration:
                                                                    BoxDecoration(
                                                                  color: color,
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              10),
                                                                ),
                                                                child: Text(
                                                                  snapshot
                                                                      .data![
                                                                          index -
                                                                              1]
                                                                      .message,
                                                                  style: const TextStyle(
                                                                      color: Colors
                                                                          .black,
                                                                      fontSize:
                                                                          18),
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        ],
                                                      ))
                                                    ],
                                                  ),
                                                )
                                              : ListTile(
                                                  title: Row(
                                                    children: [
                                                      SizedBox(
                                                        child: Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                      .only(
                                                                  right: 16),
                                                          child: ClipOval(
                                                            child: Image.asset(
                                                              // widget.otherSideImageUrl,
                                                              snapshot
                                                                  .data![
                                                                      index - 1]
                                                                  .other_side_image_url,
                                                              height: 35,
                                                              width: 35,
                                                              fit: BoxFit.cover,
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                      Container(
                                                        padding:
                                                            const EdgeInsets
                                                                .all(8),
                                                        constraints:
                                                            BoxConstraints(
                                                          minWidth: MediaQuery.of(
                                                                      context)
                                                                  .size
                                                                  .width *
                                                              0.25,
                                                          maxWidth: MediaQuery.of(
                                                                      context)
                                                                  .size
                                                                  .width *
                                                              0.75,
                                                        ),
                                                        decoration:
                                                            BoxDecoration(
                                                          color: color,
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(10),
                                                        ),
                                                        child: Text(
                                                          snapshot
                                                              .data![index - 1]
                                                              .message,
                                                          style:
                                                              const TextStyle(
                                                                  color: Colors
                                                                      .black,
                                                                  fontSize: 18),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                        ),
                                      );
                                    });
                              } else if (snapshot.hasError) {
                                return Text("${snapshot.error}");
                              }
                              return const CircularProgressIndicator();
                            }),
                      ),
                    ],
                  ),
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
                        messages.add(textEditingController.text);
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
}
