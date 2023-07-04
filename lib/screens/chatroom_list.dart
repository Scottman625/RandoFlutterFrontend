import 'package:flutter/material.dart';
import 'package:rando/models/chatMessage.dart';
import '../token/user_token.dart';
import '../models/user.dart';
import '../dummy_Data.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ChatPageScreen extends StatefulWidget {
  const ChatPageScreen({super.key});

  @override
  State<ChatPageScreen> createState() => _ChatPageScreenState();
}

class _ChatPageScreenState extends State<ChatPageScreen> {
  var current_user = profiles.firstWhere((user) => user.name == 'Scott');
  List<ChatMessage> userMateChatList = messages
      .where((chatmessage) => userMates
          .where((userMate) =>
              userMate.maleUser ==
              profiles.firstWhere((user) => user.name == 'Scott'))
          .toList()
          .contains(chatmessage.userMate))
      .toList();
  Future<List<User>> fetchMatches() async {
    final response = await http.get(
      Uri.parse('http://127.0.0.1:8000/api/matched_not_chatted/'),
      headers: {
        'Authorization': 'token 595e8727dd3ed97c8165a2342aab62f6dc28b595',
      },
    );

    if (response.statusCode == 200) {
      // If the server returns a 200 OK response,
      // then parse the JSON.
      Iterable list = json.decode(response.body);
      return list.map((match) => User.fromJson(match)).toList();
    } else {
      // If the server response is not a 200 OK,
      // then throw an exception.
      throw <User>[];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
        child: SingleChildScrollView(
            child: SizedBox(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height * 0.88,
      child: ListView.builder(
          padding: EdgeInsets.only(bottom: 100),
          itemCount: userMateChatList.length + 1,
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
                            fontSize: 20, fontWeight: FontWeight.bold),
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
                                  AsyncSnapshot<List<User>> snapshot) {
                                if (snapshot.hasData) {
                                  return ListView.builder(
                                      itemCount: snapshot.data!.length + 1,
                                      scrollDirection: Axis.horizontal,
                                      itemBuilder: (context, index) {
                                        if (index == 0) {
                                          return Container(
                                            height: 85,
                                            width: 65,
                                            child: Column(children: [
                                              Padding(
                                                padding:
                                                    const EdgeInsets.all(8.0),
                                                child: Container(
                                                  child: Stack(
                                                      alignment:
                                                          Alignment.center,
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
                                                              BoxDecoration(
                                                            shape:
                                                                BoxShape.circle,
                                                            color: Colors.white,
                                                          ),
                                                        ),
                                                        Container(
                                                          width: 44,
                                                          height: 44,
                                                          decoration:
                                                              BoxDecoration(
                                                            shape:
                                                                BoxShape.circle,
                                                            color: Colors
                                                                .purpleAccent,
                                                          ),
                                                          child: Icon(
                                                            Icons.electric_bolt,
                                                            color: Colors.white,
                                                            size: 30,
                                                          ),
                                                        )
                                                      ]),
                                                ),
                                              ),
                                              Text('更多配對',
                                                  style: TextStyle(
                                                      fontSize: 12,
                                                      color:
                                                          Colors.purpleAccent,
                                                      fontWeight:
                                                          FontWeight.bold))
                                            ]),
                                          );
                                        } else {
                                          return SizedBox(
                                            height: 85,
                                            width: 65,
                                            child: Column(children: [
                                              Padding(
                                                padding:
                                                    const EdgeInsets.all(8.0),
                                                child: SizedBox(
                                                  child: Align(
                                                    alignment:
                                                        const Alignment(0.9, 0),
                                                    child: Center(
                                                      child: ClipOval(
                                                        child: Image.asset(
                                                          snapshot
                                                              .data![index - 1]
                                                              .image,
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
                                                    snapshot
                                                        .data![index - 1].name,
                                                    textAlign: TextAlign.center,
                                                    style: const TextStyle(
                                                        fontSize: 12,
                                                        color: Colors.black,
                                                        fontWeight:
                                                            FontWeight.bold)),
                                              ),
                                            ]),
                                          );
                                        }
                                      });
                                } else if (snapshot.hasError) {
                                  return Text("${snapshot.error}");
                                }
                                return CircularProgressIndicator();
                              }),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0, left: 10),
                      child: const Text(
                        '聊天',
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ]);
            } else {
              return Padding(
                padding: const EdgeInsets.only(bottom: 4.0),
                child: Column(
                  children: [
                    ListTile(
                      leading: ClipOval(
                        child: Image.asset(
                          current_user.gender == 'Male'
                              ? userMateChatList[i - 1]
                                  .userMate
                                  .femaleUser
                                  .image
                              : userMateChatList[i - 1].userMate.maleUser.image,
                          height: 55,
                          width: 55,
                          fit: BoxFit.cover,
                        ),
                      ),
                      title: Text(
                        current_user.gender == 'Male'
                            ? userMateChatList[i - 1].userMate.femaleUser.name
                            : userMateChatList[i - 1].userMate.maleUser.name,
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      subtitle: Text(userMateChatList[i - 1].message),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 70),
                      child: Divider(color: Colors.black),
                    ),
                  ],
                ),
              );
            }
          }),
    )));
  }
}
