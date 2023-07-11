// import 'package:flutter/material.dart';
// import 'package:rando/models/chatMessage.dart';
// import '../token/user_token.dart';
// import '../models/user.dart';
// import 'chatroom.dart';
// import 'package:http/http.dart' as http;
// import 'dart:convert';
// import 'package:web_socket_channel/io.dart';
// import 'dart:async';

// class ChatPageScreen extends StatefulWidget {
//   const ChatPageScreen({super.key});

//   @override
//   State<ChatPageScreen> createState() => _ChatPageScreenState();
// }

// class _ChatPageScreenState extends State<ChatPageScreen> {
//   List<dynamic> unreadNumList = [];
//   late IOWebSocketChannel _channel;
//   StreamController _streamController = StreamController.broadcast();
//   Key _futureBuilderKey = UniqueKey();

//   @override
//   void initState() {
//     super.initState();

//     _channel = IOWebSocketChannel.connect(
//         'ws://127.0.0.1:8000/ws/chatroom_unread_nums/');

//     _channel.stream.listen((message) {
//       Map message_map = jsonDecode(message);

//       var messageType = message_map['type'];
//       var unread_message_list = message_map['unread_num_list'];

//       _futureBuilderKey = UniqueKey();
//       _streamController.sink.add(unread_message_list);
//     });
//   }

//   Future<List<User>> fetchMatches() async {
//     final token = await getToken();
//     String auth_token = 'token ${token}';
//     final response = await http.get(
//       Uri.parse('http://127.0.0.1:8000/api/matched_not_chatted/'),
//       headers: {
//         'Authorization': auth_token,
//       },
//     );

//     if (response.statusCode == 200) {
//       // If the server returns a 200 OK response,
//       // then parse the JSON.
//       String body = utf8.decode(response.bodyBytes);
//       Iterable list = json.decode(body);
//       // print(list);
//       return list.map((match) => User.fromJson(match)).toList();
//     } else {
//       // If the server
//       //response is not a 200 OK,
//       // then throw an exception.
//       // print('test');
//       throw <User>[];
//     }
//   }

//   Future<List<ChatRoom>> fetchChatRooms() async {
//     final token = await getToken();
//     String auth_token = 'token ${token}';
//     final response = await http.get(
//       Uri.parse('http://127.0.0.1:8000/api/chatroom/'),
//       headers: {
//         'Authorization': auth_token,
//       },
//     );

//     if (response.statusCode == 200) {
//       // If the server returns a 200 OK response,
//       // then parse the JSON.
//       String body = utf8.decode(response.bodyBytes);
//       Iterable list = json.decode(body);
//       // print(list);
//       // print(list.map((match) => ChatRoom.fromJson(match)).toList());
//       return list.map((match) => ChatRoom.fromJson(match)).toList();
//     } else {
//       // If the server response is not a 200 OK,
//       // then throw an exception.
//       // print('yes');
//       throw <ChatRoom>[];
//     }
//   }

//   void navigateToChatroom(String other_side_user_phone) async {
//     final token = await getToken();
//     String auth_token = 'token ${token}';

//     // print(auth_token);

//     final getChatRoomtokenResponse = await http
//         .post(Uri.parse('http://127.0.0.1:8000/api/chatroom/'), headers: {
//       'Authorization': auth_token,
//     }, body: {
//       'other_side_user_phone': other_side_user_phone,
//     });
//     String body = utf8.decode(getChatRoomtokenResponse.bodyBytes);
//     Map<String, dynamic> chatroomMap = json.decode(body);
//     ChatRoom chatroom = ChatRoom.fromJson(chatroomMap);

//     // ChatRoom chatroom =
//     //     chatroomMap.map((match) => User.fromJson(match)).first();

//     Navigator.of(context).push(MaterialPageRoute(
//       builder: (ctx) => ChatRoomScreen(
//         chatroomId: chatroom.id,
//         otherSideImageUrl: chatroom.other_side_image_url,
//         currentUserId: chatroom.current_user_id,
//       ),
//     ));
//   }

//   @override
//   Widget build(BuildContext context) {
//     // print('test02');
//     return Expanded(
//         child: SingleChildScrollView(
//       child: SizedBox(
//           width: MediaQuery.of(context).size.width,
//           height: MediaQuery.of(context).size.height * 0.88,
//           child: FutureBuilder<List<ChatRoom>>(
//               future: fetchChatRooms(),
//               key: _futureBuilderKey,
//               initialData: [],
//               builder: (BuildContext context,
//                   AsyncSnapshot<List<ChatRoom>> futureSnapshot) {
//                 return Column(
//                   children: [
//                     Container(
//                       child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: <Widget>[
//                             const Padding(
//                               padding: EdgeInsets.only(left: 8.0),
//                               child: Text(
//                                 '新的配對',
//                                 style: TextStyle(
//                                     fontSize: 20, fontWeight: FontWeight.bold),
//                               ),
//                             ),
//                             Container(
//                               height: 85,
//                               width: MediaQuery.of(context).size.width * 0.95,
//                               child: SingleChildScrollView(
//                                 // scrollDirection: Axis.horizontal,
//                                 child: SizedBox(
//                                   height: 85,
//                                   child: FutureBuilder<List<User>>(
//                                       future: fetchMatches(),
//                                       builder: (BuildContext context,
//                                           AsyncSnapshot<List<User>>
//                                               asyncSnapshot) {
//                                         if (asyncSnapshot.hasData &&
//                                             asyncSnapshot.data != null) {
//                                           return ListView.builder(
//                                               itemCount:
//                                                   asyncSnapshot.data!.length +
//                                                       1,
//                                               scrollDirection: Axis.horizontal,
//                                               itemBuilder: (context, index) {
//                                                 if (index == 0) {
//                                                   return Container(
//                                                     height: 85,
//                                                     width: 65,
//                                                     child: Column(children: [
//                                                       Padding(
//                                                         padding:
//                                                             const EdgeInsets
//                                                                 .all(8.0),
//                                                         child: Container(
//                                                           child: Stack(
//                                                               alignment:
//                                                                   Alignment
//                                                                       .center,
//                                                               children: [
//                                                                 Container(
//                                                                   width: 50,
//                                                                   height: 50,
//                                                                   decoration:
//                                                                       const BoxDecoration(
//                                                                     shape: BoxShape
//                                                                         .circle,
//                                                                     color: Colors
//                                                                         .purpleAccent,
//                                                                   ),
//                                                                 ),
//                                                                 Container(
//                                                                   width: 47,
//                                                                   height: 47,
//                                                                   decoration:
//                                                                       const BoxDecoration(
//                                                                     shape: BoxShape
//                                                                         .circle,
//                                                                     color: Colors
//                                                                         .white,
//                                                                   ),
//                                                                 ),
//                                                                 Container(
//                                                                   width: 44,
//                                                                   height: 44,
//                                                                   decoration:
//                                                                       const BoxDecoration(
//                                                                     shape: BoxShape
//                                                                         .circle,
//                                                                     color: Colors
//                                                                         .purpleAccent,
//                                                                   ),
//                                                                   child:
//                                                                       const Icon(
//                                                                     Icons
//                                                                         .electric_bolt,
//                                                                     color: Colors
//                                                                         .white,
//                                                                     size: 30,
//                                                                   ),
//                                                                 )
//                                                               ]),
//                                                         ),
//                                                       ),
//                                                       const Text('更多配對',
//                                                           style: TextStyle(
//                                                               fontSize: 12,
//                                                               color: Colors
//                                                                   .purpleAccent,
//                                                               fontWeight:
//                                                                   FontWeight
//                                                                       .bold))
//                                                     ]),
//                                                   );
//                                                 } else {
//                                                   return InkWell(
//                                                     onTap: () {
//                                                       navigateToChatroom(
//                                                           asyncSnapshot
//                                                               .data![index - 1]
//                                                               .phone);
//                                                     },
//                                                     child: SizedBox(
//                                                       height: 85,
//                                                       width: 65,
//                                                       child: Column(children: [
//                                                         Padding(
//                                                           padding:
//                                                               const EdgeInsets
//                                                                   .all(8.0),
//                                                           child: SizedBox(
//                                                             child: Align(
//                                                               alignment:
//                                                                   const Alignment(
//                                                                       0.9, 0),
//                                                               child: Center(
//                                                                 child: ClipOval(
//                                                                   child: Image
//                                                                       .asset(
//                                                                     asyncSnapshot
//                                                                         .data![
//                                                                             index -
//                                                                                 1]
//                                                                         .image,
//                                                                     height: 50,
//                                                                     width: 50,
//                                                                     fit: BoxFit
//                                                                         .cover,
//                                                                   ),
//                                                                 ),
//                                                               ),
//                                                             ),
//                                                           ),
//                                                         ),
//                                                         Center(
//                                                           child: Text(
//                                                               asyncSnapshot
//                                                                   .data![
//                                                                       index - 1]
//                                                                   .name,
//                                                               textAlign:
//                                                                   TextAlign
//                                                                       .center,
//                                                               style: const TextStyle(
//                                                                   fontSize: 12,
//                                                                   color: Colors
//                                                                       .black,
//                                                                   fontWeight:
//                                                                       FontWeight
//                                                                           .bold)),
//                                                         ),
//                                                       ]),
//                                                     ),
//                                                   );
//                                                 }
//                                               });
//                                         } else if (asyncSnapshot.hasError) {
//                                           return Text("${asyncSnapshot.error}");
//                                         }
//                                         return CircularProgressIndicator();
//                                       }),
//                                 ),
//                               ),
//                             ),
//                             const Padding(
//                               padding: EdgeInsets.only(top: 8.0, left: 10),
//                               child: Text(
//                                 '聊天',
//                                 style: TextStyle(
//                                     fontSize: 20, fontWeight: FontWeight.bold),
//                               ),
//                             ),
//                           ]),
//                     ),
//                     Expanded(
//                       child: Container(
//                         height: 570,
//                         child: StreamBuilder(
//                           initialData: [],
//                           stream: _streamController.stream,
//                           builder: (BuildContext context,
//                               AsyncSnapshot<dynamic> streamSnapshot) {
//                             if (streamSnapshot.hasError) {
//                               return Text('Error: ${streamSnapshot.error}');
//                             }
//                             return ListView.builder(
//                                 itemCount:
//                                     (futureSnapshot.data?.length ?? 1) < 4
//                                         ? 5
//                                         : futureSnapshot.data!.length + 1,
//                                 // (futureSnapshot.data?.length ?? 1) < 5
//                                 //     ? 5
//                                 //     : futureSnapshot.data!.length + 1,
//                                 itemBuilder: (BuildContext context, int index) {
//                                   // print('index ${index}');
//                                   // print(futureSnapshot.data?.length);
//                                   if (index == 0) {
//                                     return Container();
//                                   } else if (index >
//                                           futureSnapshot.data!.length &&
//                                       index < 5) {
//                                     return SizedBox(
//                                         height:
//                                             MediaQuery.of(context).size.height *
//                                                 0.1);
//                                   } else {
//                                     print(streamSnapshot.data);
//                                     final chatRoom =
//                                         futureSnapshot.data?[index - 1];
//                                     final unread_index = streamSnapshot.data
//                                         .indexWhere((element) =>
//                                             element["chatroom"] ==
//                                             chatRoom?.id);
//                                     // print('chatRoom: ${chatRoom!.id}');
//                                     // print(unread_index);
//                                     if (unread_index != -1) {
//                                       final unreadNums = streamSnapshot
//                                           .data[unread_index]['unread_nums'];
//                                       // 根据这两个数据源生成你的 UI

//                                       return Container(
//                                         height:
//                                             MediaQuery.of(context).size.height *
//                                                 0.1,
//                                         width:
//                                             MediaQuery.of(context).size.width,
//                                         child: Column(
//                                           children: [
//                                             Expanded(
//                                                 child: InkWell(
//                                                     onTap: () {
//                                                       Navigator.of(context)
//                                                           .push(
//                                                               MaterialPageRoute(
//                                                         builder: (ctx) =>
//                                                             ChatRoomScreen(
//                                                           chatroomId:
//                                                               chatRoom!.id,
//                                                           otherSideImageUrl:
//                                                               chatRoom
//                                                                   .other_side_image_url,
//                                                           currentUserId: chatRoom
//                                                               .current_user_id,
//                                                         ),
//                                                       ));
//                                                     },
//                                                     child: Container(
//                                                       height:
//                                                           MediaQuery.of(context)
//                                                                   .size
//                                                                   .height *
//                                                               0.1,
//                                                       child: ListTile(
//                                                         leading: SizedBox(
//                                                           width: MediaQuery.of(
//                                                                       context)
//                                                                   .size
//                                                                   .width *
//                                                               0.15,
//                                                           child: Stack(
//                                                               children:
//                                                                   unreadNums > 0
//                                                                       ? <Widget>[
//                                                                           ClipOval(
//                                                                             child:
//                                                                                 Image.asset(
//                                                                               chatRoom!.other_side_image_url,
//                                                                               height: 55,
//                                                                               width: 55,
//                                                                               fit: BoxFit.cover,
//                                                                             ),
//                                                                           ),
//                                                                           Align(
//                                                                               alignment: Alignment(0.95, -1.05),
//                                                                               child: Container(
//                                                                                 width: 20,
//                                                                                 height: 20,
//                                                                                 decoration: const BoxDecoration(shape: BoxShape.circle, color: Colors.white),
//                                                                               )),
//                                                                           Align(
//                                                                               alignment: Alignment(0.9, -1),
//                                                                               child: Container(
//                                                                                 width: 17,
//                                                                                 height: 17,
//                                                                                 decoration: const BoxDecoration(shape: BoxShape.circle, color: Colors.red),
//                                                                               )),
//                                                                           Align(
//                                                                               alignment: Alignment(0.75, -1),
//                                                                               child: Text(
//                                                                                 unreadNums.toString(),
//                                                                                 style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
//                                                                               )),
//                                                                         ]
//                                                                       : <Widget>[
//                                                                           ClipOval(
//                                                                             child:
//                                                                                 Image.asset(
//                                                                               chatRoom!.other_side_image_url,
//                                                                               height: 55,
//                                                                               width: 55,
//                                                                               fit: BoxFit.cover,
//                                                                             ),
//                                                                           ),
//                                                                         ]),
//                                                         ),
//                                                         title: Text(
//                                                           chatRoom
//                                                               .other_side_name,
//                                                           style:
//                                                               const TextStyle(
//                                                                   fontWeight:
//                                                                       FontWeight
//                                                                           .bold,
//                                                                   fontSize: 20),
//                                                         ),
//                                                         subtitle: Padding(
//                                                           padding:
//                                                               const EdgeInsets
//                                                                       .only(
//                                                                   top: 8.0),
//                                                           child: Text(
//                                                             chatRoom
//                                                                 .last_message,
//                                                             style: TextStyle(
//                                                                 fontSize: 20),
//                                                           ),
//                                                         ),
//                                                       ),
//                                                     ))),
//                                             const Padding(
//                                               padding:
//                                                   EdgeInsets.only(left: 70),
//                                               child:
//                                                   Divider(color: Colors.black),
//                                             ),
//                                           ],
//                                         ),
//                                       );
//                                     } else {
//                                       return Container(
//                                         height:
//                                             MediaQuery.of(context).size.height *
//                                                 0.1,
//                                         width:
//                                             MediaQuery.of(context).size.width,
//                                         child: Column(
//                                           children: [
//                                             Expanded(
//                                               child: InkWell(
//                                                   onTap: () {
//                                                     Navigator.of(context)
//                                                         .push(MaterialPageRoute(
//                                                       builder: (ctx) =>
//                                                           ChatRoomScreen(
//                                                         chatroomId:
//                                                             futureSnapshot
//                                                                 .data![
//                                                                     index - 1]
//                                                                 .id,
//                                                         otherSideImageUrl:
//                                                             futureSnapshot
//                                                                 .data![
//                                                                     index - 1]
//                                                                 .other_side_image_url,
//                                                         currentUserId:
//                                                             futureSnapshot
//                                                                 .data![
//                                                                     index - 1]
//                                                                 .current_user_id,
//                                                       ),
//                                                     ));
//                                                   },
//                                                   child: SizedBox(
//                                                       height: 60,
//                                                       width:
//                                                           MediaQuery.of(context)
//                                                               .size
//                                                               .width,
//                                                       child: Container(
//                                                         height: 60,
//                                                         width: MediaQuery.of(
//                                                                 context)
//                                                             .size
//                                                             .width,
//                                                         child: ListTile(
//                                                           leading: SizedBox(
//                                                             width: MediaQuery.of(
//                                                                         context)
//                                                                     .size
//                                                                     .width *
//                                                                 0.15,
//                                                             child: Stack(
//                                                                 children: chatRoom!
//                                                                             .unread_nums >
//                                                                         0
//                                                                     ? <Widget>[
//                                                                         ClipOval(
//                                                                           child:
//                                                                               Image.asset(
//                                                                             chatRoom!.other_side_image_url,
//                                                                             height:
//                                                                                 55,
//                                                                             width:
//                                                                                 55,
//                                                                             fit:
//                                                                                 BoxFit.cover,
//                                                                           ),
//                                                                         ),
//                                                                         Align(
//                                                                             alignment: Alignment(0.95,
//                                                                                 -1.05),
//                                                                             child:
//                                                                                 Container(
//                                                                               width: 20,
//                                                                               height: 20,
//                                                                               decoration: const BoxDecoration(shape: BoxShape.circle, color: Colors.white),
//                                                                             )),
//                                                                         Align(
//                                                                             alignment: Alignment(0.9,
//                                                                                 -1),
//                                                                             child:
//                                                                                 Container(
//                                                                               width: 17,
//                                                                               height: 17,
//                                                                               decoration: const BoxDecoration(shape: BoxShape.circle, color: Colors.red),
//                                                                             )),
//                                                                         Align(
//                                                                             alignment: Alignment(0.75,
//                                                                                 -1),
//                                                                             child:
//                                                                                 Text(
//                                                                               chatRoom.unread_nums.toString(),
//                                                                               style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
//                                                                             )),
//                                                                       ]
//                                                                     : <Widget>[
//                                                                         ClipOval(
//                                                                           child:
//                                                                               Image.asset(
//                                                                             chatRoom!.other_side_image_url,
//                                                                             height:
//                                                                                 55,
//                                                                             width:
//                                                                                 55,
//                                                                             fit:
//                                                                                 BoxFit.cover,
//                                                                           ),
//                                                                         ),
//                                                                       ]),
//                                                           ),
//                                                           title: Text(
//                                                             chatRoom
//                                                                 .other_side_name,
//                                                             style: const TextStyle(
//                                                                 fontWeight:
//                                                                     FontWeight
//                                                                         .bold,
//                                                                 fontSize: 20),
//                                                           ),
//                                                           subtitle: Padding(
//                                                             padding:
//                                                                 const EdgeInsets
//                                                                         .only(
//                                                                     top: 8.0),
//                                                             child: Text(
//                                                               chatRoom
//                                                                   .last_message,
//                                                               style: TextStyle(
//                                                                   fontSize: 20),
//                                                             ),
//                                                           ),
//                                                         ),
//                                                       ))),
//                                             ),
//                                             const Padding(
//                                               padding: EdgeInsets.only(
//                                                   left: 70, bottom: 5),
//                                               child:
//                                                   Divider(color: Colors.black),
//                                             ),
//                                           ],
//                                         ),
//                                       );
//                                     }
//                                   }
//                                 });
//                           },
//                         ),
//                       ),
//                     )
//                   ],
//                 );
//               })),
//     ));
//   }

//   @override
//   void dispose() {
//     _streamController.close();
//     _channel.sink.close();
//     super.dispose();
//   }
// }
