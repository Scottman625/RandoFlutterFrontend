import 'package:flutter/material.dart';
import 'package:rando/models/chatMessage.dart';
import '../shared_preferences/shared_preferences.dart';
import '../models/user.dart';
import 'chatroom.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/websocket_provider.dart';
import 'package:cached_network_image/cached_network_image.dart';

Future<List<ChatRoom>> fetchChatRooms() async {
  final token = await getToken();
  String auth_token = 'token ${token}';
  final response = await http.get(
    Uri.parse('http://127.0.0.1:8000/api/chatroom/'),
    headers: {
      'Authorization': auth_token,
    },
  );
  print('test');
  if (response.statusCode == 200) {
    // If the server returns a 200 OK response,
    // then parse the JSON.
    String body = utf8.decode(response.bodyBytes);
    // print(body);
    Iterable list = json.decode(body);
    print('list: ${list}');
    return list.map((match) => ChatRoom.fromJson(match)).toList();
  } else {
    // If the server response is not a 200 OK,
    // then throw an exception.
    throw <ChatRoom>[];
  }
}

Future<List<User>> fetchMatches() async {
  final token = await getToken();
  String auth_token = 'token ${token}';
  final response = await http.get(
    Uri.parse('http://127.0.0.1:8000/api/matched_not_chatted/'),
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
    return list.map((match) => User.fromJson(match)).toList();
  } else {
    // If the server
    //response is not a 200 OK,
    // then throw an exception.
    // print('test');
    throw <User>[];
  }
}

class ChatPageScreen extends ConsumerStatefulWidget {
  const ChatPageScreen({
    super.key,
    required this.userId,
    // required this.chatroomList,
  });

  final String userId;
  // final String chatroomList;

  @override
  ConsumerState<ChatPageScreen> createState() => _ChatPageScreenState();
}

class _ChatPageScreenState extends ConsumerState<ChatPageScreen> {
  List<ChatRoom> chatRoomList = [];
  String map = "";

  @override
  void initState() {
    super.initState();
    loadChatRooms(); // This function fetches data and then sets the state.
  }

  void loadChatRooms() async {
    var list = await fetchChatRooms();
    setState(() {
      chatRoomList = list;
      map = jsonEncode({
        "type": "chatrooms",
        "chatrooms": list,
        "messages": [],
      });
    });
  }

  void navigateToChatroom(String other_side_user_phone) async {
    final token = await getToken();
    String authToken = 'token ${token}';

    // print(auth_token);

    final getChatRoomtokenResponse = await http
        .post(Uri.parse('http://127.0.0.1:8000/api/chatroom/'), headers: {
      'Authorization': authToken,
    }, body: {
      'other_side_user_phone': other_side_user_phone,
    });
    String body = utf8.decode(getChatRoomtokenResponse.bodyBytes);
    Map<String, dynamic> chatroomMap = json.decode(body);
    ChatRoom chatroom = ChatRoom.fromJson(chatroomMap);

    // ChatRoom chatroom =
    //     chatroomMap.map((match) => User.fromJson(match)).first();

    Navigator.of(context).push(MaterialPageRoute(
      builder: (ctx) => ChatRoomScreen(
        // chatroomList: jsonEncode(widget.chatroomList),
        chatroomId: chatroom.id,
        otherSideImageUrl: chatroom.other_side_image_url,
        currentUserId: widget.userId,
      ),
    ));
  }

  @override
  Widget build(BuildContext context) {
    // print('userId: ${widget.userId}');
    return Expanded(
        child: SingleChildScrollView(
      child: SizedBox(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height * 0.88,
          child: Column(
            children: [
              Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    const Padding(
                      padding: EdgeInsets.only(left: 8.0),
                      child: Text(
                        '新的配對',
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                    ),
                    SizedBox(
                      height: 85,
                      width: MediaQuery.of(context).size.width * 0.95,
                      child: SingleChildScrollView(
                        // scrollDirection: Axis.horizontal,
                        child: SizedBox(
                          height: 85,
                          child: FutureBuilder<List<User>>(
                              future: fetchMatches(),
                              builder: (BuildContext context,
                                  AsyncSnapshot<List<User>> asyncSnapshot) {
                                if (asyncSnapshot.hasData &&
                                    asyncSnapshot.data != null) {
                                  return ListView.builder(
                                      itemCount: asyncSnapshot.data!.length + 1,
                                      scrollDirection: Axis.horizontal,
                                      itemBuilder: (context, index) {
                                        if (index == 0) {
                                          return SizedBox(
                                            height: 85,
                                            width: 65,
                                            child: Column(children: [
                                              Padding(
                                                padding:
                                                    const EdgeInsets.all(8.0),
                                                child: Stack(
                                                    alignment: Alignment.center,
                                                    children: [
                                                      Container(
                                                        width: 50,
                                                        height: 50,
                                                        decoration:
                                                            const BoxDecoration(
                                                          shape:
                                                              BoxShape.circle,
                                                          color: Colors
                                                              .purpleAccent,
                                                        ),
                                                      ),
                                                      Container(
                                                        width: 47,
                                                        height: 47,
                                                        decoration:
                                                            const BoxDecoration(
                                                          shape:
                                                              BoxShape.circle,
                                                          color: Colors.white,
                                                        ),
                                                      ),
                                                      Container(
                                                        width: 44,
                                                        height: 44,
                                                        decoration:
                                                            const BoxDecoration(
                                                          shape:
                                                              BoxShape.circle,
                                                          color: Colors
                                                              .purpleAccent,
                                                        ),
                                                        child: const Icon(
                                                          Icons.electric_bolt,
                                                          color: Colors.white,
                                                          size: 30,
                                                        ),
                                                      )
                                                    ]),
                                              ),
                                              const Text('更多配對',
                                                  style: TextStyle(
                                                      fontSize: 12,
                                                      color:
                                                          Colors.purpleAccent,
                                                      fontWeight:
                                                          FontWeight.bold))
                                            ]),
                                          );
                                        } else {
                                          return InkWell(
                                            onTap: () {
                                              navigateToChatroom(asyncSnapshot
                                                  .data![index - 1].phone);
                                            },
                                            child: SizedBox(
                                              height: 85,
                                              width: 65,
                                              child: Column(children: [
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.all(8.0),
                                                  child: SizedBox(
                                                    child: Align(
                                                      alignment:
                                                          const Alignment(
                                                              0.9, 0),
                                                      child: Center(
                                                        child: ClipOval(
                                                          child:
                                                              CachedNetworkImage(
                                                            imageUrl: asyncSnapshot
                                                                .data![
                                                                    index - 1]
                                                                .other_side_image_url,
                                                            height: 50,
                                                            width: 50,
                                                            fit: BoxFit.cover,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                Center(
                                                  child: Text(
                                                      asyncSnapshot
                                                          .data![index - 1]
                                                          .name,
                                                      textAlign:
                                                          TextAlign.center,
                                                      style: const TextStyle(
                                                          fontSize: 12,
                                                          color: Colors.black,
                                                          fontWeight:
                                                              FontWeight.bold)),
                                                ),
                                              ]),
                                            ),
                                          );
                                        }
                                      });
                                } else if (asyncSnapshot.hasError) {
                                  return Text("${asyncSnapshot.error}");
                                }
                                return const Column();
                              }),
                        ),
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.only(top: 8.0, left: 10),
                      child: Text(
                        '聊天',
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ]),
              streamBuilder()
            ],
          )),
    ));
  }

  Widget streamBuilder() {
    final webSocketServiceNotifier = ref.read(webSocketServiceNotifierProvider);

    webSocketServiceNotifier.addData(map);
    webSocketServiceNotifier.chatRoomsStream.listen((event) {
      // print(event); //
    });
    final chatRoomsStream = webSocketServiceNotifier.chatRoomsStream;
    return StreamBuilder<List<ChatRoom>>(
      stream: chatRoomsStream,
      // initialData: chatRoomList,
      builder: (BuildContext context, AsyncSnapshot<List<ChatRoom>> snapshot) {
        // print(snapshot.data);
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Column();
        }
        if (snapshot.hasData) {
          return chatListContent(snapshot);
        }
        return const Text('目前還沒有建立訊息！');
      },
    );
  }

  Widget chatListContent(streamSnapshot) {
    return Expanded(
      child: SizedBox(
          height: 570,
          child: Padding(
            padding: const EdgeInsets.only(bottom: 55.0),
            child: listViewBuilder(streamSnapshot),
          )),
    );
  }

  Widget listViewBuilder(streamSnapshot) {
    return ListView.builder(
        itemCount: (streamSnapshot.data?.length ?? 1) < 4
            ? 5
            : streamSnapshot.data!.length + 1,
        itemBuilder: (BuildContext context, int index) {
          if (index == 0) {
            return Container();
          } else if (index > streamSnapshot.data!.length && index < 5) {
            return SizedBox(height: MediaQuery.of(context).size.height * 0.1);
          } else {
            // print(streamSnapshot.data);
            final chatRoom = streamSnapshot.data?[index - 1];
            // print(chatRoom);
            // final newChatroomList =
            //     jsonEncode(streamSnapshot.data.map((e) => e.toJson()).toList());

            return SizedBox(
              height: MediaQuery.of(context).size.height * 0.1,
              width: MediaQuery.of(context).size.width,
              child: Column(
                children: [
                  Expanded(
                    child: InkWell(
                        onTap: () async {
                          Navigator.of(context).push(MaterialPageRoute(
                            builder: (ctx) => ChatRoomScreen(
                              // chatroomList: newChatroomList,
                              chatroomId: chatRoom.id,
                              otherSideImageUrl: chatRoom.other_side_image_url,
                              currentUserId:
                                  chatRoom.current_user_id.toString(),
                            ),
                          ));
                        },
                        child: SizedBox(
                            height: 60,
                            width: MediaQuery.of(context).size.width,
                            child: SizedBox(
                              height: 60,
                              width: MediaQuery.of(context).size.width,
                              child: ListTile(
                                leading: SizedBox(
                                  width:
                                      MediaQuery.of(context).size.width * 0.15,
                                  child: Stack(
                                      children: chatRoom!.unread_nums > 0
                                          ? <Widget>[
                                              ClipOval(
                                                child: CachedNetworkImage(
                                                  imageUrl: chatRoom!
                                                      .other_side_image_url,
                                                  height: 55,
                                                  width: 55,
                                                  fit: BoxFit.cover,
                                                ),
                                              ),
                                              Align(
                                                  alignment: const Alignment(
                                                      0.95, -1.05),
                                                  child: Container(
                                                    width: 20,
                                                    height: 20,
                                                    decoration:
                                                        const BoxDecoration(
                                                            shape:
                                                                BoxShape.circle,
                                                            color:
                                                                Colors.white),
                                                  )),
                                              Align(
                                                  alignment:
                                                      const Alignment(0.9, -1),
                                                  child: Container(
                                                    width: 17,
                                                    height: 17,
                                                    decoration:
                                                        const BoxDecoration(
                                                            shape:
                                                                BoxShape.circle,
                                                            color: Colors.red),
                                                  )),
                                              Align(
                                                  alignment:
                                                      const Alignment(0.75, -1),
                                                  child: Text(
                                                    chatRoom.unread_nums
                                                        .toString(),
                                                    style: const TextStyle(
                                                        color: Colors.white,
                                                        fontWeight:
                                                            FontWeight.bold),
                                                  )),
                                            ]
                                          : <Widget>[
                                              ClipOval(
                                                child: CachedNetworkImage(
                                                  imageUrl: chatRoom!
                                                      .other_side_image_url,
                                                  height: 55,
                                                  width: 55,
                                                  fit: BoxFit.cover,
                                                ),
                                              ),
                                            ]),
                                ),
                                title: Text(
                                  chatRoom.other_side_name,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 20),
                                ),
                                subtitle: Padding(
                                  padding: const EdgeInsets.only(top: 8.0),
                                  child: Text(
                                    chatRoom.last_message,
                                    style: const TextStyle(fontSize: 20),
                                  ),
                                ),
                              ),
                            ))),
                  ),
                  const Padding(
                    padding: EdgeInsets.only(left: 70, bottom: 5),
                    child: Divider(color: Colors.black),
                  ),
                ],
              ),
            );
          }
        });
  }

  @override
  void dispose() {
    super.dispose();
  }
}
