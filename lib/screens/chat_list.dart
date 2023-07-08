import 'package:flutter/material.dart';
import 'package:rando/models/chatMessage.dart';
import '../token/user_token.dart';
import '../models/user.dart';
import 'chatroom.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ChatPageScreen extends StatefulWidget {
  const ChatPageScreen({super.key});

  @override
  State<ChatPageScreen> createState() => _ChatPageScreenState();
}

class _ChatPageScreenState extends State<ChatPageScreen> {
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
      print('test');
      throw <User>[];
    }
  }

  Future<List<ChatRoom>> fetchChatRooms() async {
    final token = await getToken();
    String auth_token = 'token ${token}';
    final response = await http.get(
      Uri.parse('http://127.0.0.1:8000/api/chatroom/'),
      headers: {
        'Authorization': auth_token,
      },
    );

    if (response.statusCode == 200) {
      // If the server returns a 200 OK response,
      // then parse the JSON.
      String body = utf8.decode(response.bodyBytes);
      Iterable list = json.decode(body);
      list.map((e) => print(e));
      // print(list.map((match) => ChatRoom.fromJson(match)).toList());
      return list.map((match) => ChatRoom.fromJson(match)).toList();
    } else {
      // If the server response is not a 200 OK,
      // then throw an exception.
      print('yes');
      throw <ChatRoom>[];
    }
  }

  void navigateToChatroom(String other_side_user_phone) async {
    final token = await getToken();
    String auth_token = 'token ${token}';

    print(auth_token);

    final getChatRoomtokenResponse = await http
        .post(Uri.parse('http://127.0.0.1:8000/api/chatroom/'), headers: {
      'Authorization': auth_token,
    }, body: {
      'other_side_user_phone': other_side_user_phone,
    });
    String body = utf8.decode(getChatRoomtokenResponse.bodyBytes);
    Map<String, dynamic> chatroomMap = json.decode(body);
    ChatRoom chatroom = ChatRoom.fromJson(chatroomMap);
    print(chatroom.id);

    // ChatRoom chatroom =
    //     chatroomMap.map((match) => User.fromJson(match)).first();

    Navigator.of(context).push(MaterialPageRoute(
      builder: (ctx) => ChatRoomScreen(
        chatroomId: chatroom.id,
        otherSideImageUrl: chatroom.other_side_image_url,
        currentUserId: chatroom.current_user_id,
      ),
    ));
  }

  @override
  Widget build(BuildContext context) {
    // print('test02');
    return Expanded(
        child: SingleChildScrollView(
      child: SizedBox(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height * 0.88,
        child: FutureBuilder<List<ChatRoom>>(
            future: fetchChatRooms(),
            builder:
                (BuildContext context, AsyncSnapshot<List<ChatRoom>> snapshot) {
              if (snapshot.hasData && snapshot.data != null) {
                return ListView.builder(
                    padding: EdgeInsets.only(bottom: 100),
                    itemCount: snapshot.data!.length < 4
                        ? 5
                        : snapshot.data!.length + 1,
                    itemBuilder: (context, i) {
                      if (i == 0) {
                        return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Padding(
                                padding: const EdgeInsets.only(left: 8.0),
                                child: const Text(
                                  '新的配對',
                                  style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                              Container(
                                height: 85,
                                width: MediaQuery.of(context).size.width * 0.95,
                                child: SingleChildScrollView(
                                  // scrollDirection: Axis.horizontal,
                                  child: SizedBox(
                                    height: 85,
                                    child: FutureBuilder<List<User>>(
                                        future: fetchMatches(),
                                        builder: (BuildContext context,
                                            AsyncSnapshot<List<User>>
                                                asyncSnapshot) {
                                          if (asyncSnapshot.hasData &&
                                              asyncSnapshot.data != null) {
                                            return ListView.builder(
                                                itemCount:
                                                    asyncSnapshot.data!.length +
                                                        1,
                                                scrollDirection:
                                                    Axis.horizontal,
                                                itemBuilder: (context, index) {
                                                  if (index == 0) {
                                                    return Container(
                                                      height: 85,
                                                      width: 65,
                                                      child: Column(children: [
                                                        Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .all(8.0),
                                                          child: Container(
                                                            child: Stack(
                                                                alignment:
                                                                    Alignment
                                                                        .center,
                                                                children: [
                                                                  Container(
                                                                    width: 50,
                                                                    height: 50,
                                                                    decoration:
                                                                        const BoxDecoration(
                                                                      shape: BoxShape
                                                                          .circle,
                                                                      color: Colors
                                                                          .purpleAccent,
                                                                    ),
                                                                  ),
                                                                  Container(
                                                                    width: 47,
                                                                    height: 47,
                                                                    decoration:
                                                                        const BoxDecoration(
                                                                      shape: BoxShape
                                                                          .circle,
                                                                      color: Colors
                                                                          .white,
                                                                    ),
                                                                  ),
                                                                  Container(
                                                                    width: 44,
                                                                    height: 44,
                                                                    decoration:
                                                                        const BoxDecoration(
                                                                      shape: BoxShape
                                                                          .circle,
                                                                      color: Colors
                                                                          .purpleAccent,
                                                                    ),
                                                                    child:
                                                                        const Icon(
                                                                      Icons
                                                                          .electric_bolt,
                                                                      color: Colors
                                                                          .white,
                                                                      size: 30,
                                                                    ),
                                                                  )
                                                                ]),
                                                          ),
                                                        ),
                                                        const Text('更多配對',
                                                            style: TextStyle(
                                                                fontSize: 12,
                                                                color: Colors
                                                                    .purpleAccent,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold))
                                                      ]),
                                                    );
                                                  } else {
                                                    return InkWell(
                                                      onTap: () {
                                                        navigateToChatroom(
                                                            asyncSnapshot
                                                                .data![
                                                                    index - 1]
                                                                .phone);
                                                      },
                                                      child: SizedBox(
                                                        height: 85,
                                                        width: 65,
                                                        child:
                                                            Column(children: [
                                                          Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                    .all(8.0),
                                                            child: SizedBox(
                                                              child: Align(
                                                                alignment:
                                                                    const Alignment(
                                                                        0.9, 0),
                                                                child: Center(
                                                                  child:
                                                                      ClipOval(
                                                                    child: Image
                                                                        .asset(
                                                                      asyncSnapshot
                                                                          .data![index -
                                                                              1]
                                                                          .image,
                                                                      height:
                                                                          50,
                                                                      width: 50,
                                                                      fit: BoxFit
                                                                          .cover,
                                                                    ),
                                                                  ),
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                          Center(
                                                            child: Text(
                                                                asyncSnapshot
                                                                    .data![
                                                                        index -
                                                                            1]
                                                                    .name,
                                                                textAlign:
                                                                    TextAlign
                                                                        .center,
                                                                style: const TextStyle(
                                                                    fontSize:
                                                                        12,
                                                                    color: Colors
                                                                        .black,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold)),
                                                          ),
                                                        ]),
                                                      ),
                                                    );
                                                  }
                                                });
                                          } else if (asyncSnapshot.hasError) {
                                            return Text(
                                                "${asyncSnapshot.error}");
                                          }
                                          return CircularProgressIndicator();
                                        }),
                                  ),
                                ),
                              ),
                              const Padding(
                                padding: EdgeInsets.only(top: 8.0, left: 10),
                                child: Text(
                                  '聊天',
                                  style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                            ]);
                      } else if (i > snapshot.data!.length && i < 5) {
                        return SizedBox(
                            height: MediaQuery.of(context).size.height * 0.12);
                      } else {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 4.0),
                          child: Column(
                            children: [
                              InkWell(
                                onTap: () {
                                  Navigator.of(context).push(MaterialPageRoute(
                                    builder: (ctx) => ChatRoomScreen(
                                      chatroomId: snapshot.data![i - 1].id,
                                      otherSideImageUrl: snapshot
                                          .data![i - 1].other_side_image_url,
                                      currentUserId:
                                          snapshot.data![i - 1].current_user_id,
                                    ),
                                  ));
                                },
                                child: ListTile(
                                  leading: ClipOval(
                                    child: Image.asset(
                                      snapshot
                                          .data![i - 1].other_side_image_url,
                                      height: 55,
                                      width: 55,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                  title: Text(
                                    snapshot.data![i - 1].other_side_name,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16),
                                  ),
                                  subtitle: Text(
                                    snapshot.data![i - 1].last_message,
                                  ),
                                ),
                              ),
                              const Padding(
                                padding: EdgeInsets.only(left: 70),
                                child: Divider(color: Colors.black),
                              ),
                            ],
                          ),
                        );
                      }
                    });
              } else if (snapshot.hasError) {
                return Text("${snapshot.error}");
              }
              return const CircularProgressIndicator();
            }),
      ),
    ));
  }
}
