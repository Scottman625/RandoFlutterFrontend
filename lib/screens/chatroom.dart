import 'package:flutter/material.dart';
import 'package:rando/models/chatMessage.dart';
import 'package:rando/screens/chat_list.dart';
import '../shared_preferences/shared_preferences.dart';
import '../screens/profile_swap.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart' as intl;
import 'dart:async';
import 'dart:math';
import 'package:web_socket_channel/io.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:http_parser/http_parser.dart';
import '../providers/websocket_provider.dart';
import '../web_socket.dart';

class ChatRoomScreen extends ConsumerStatefulWidget {
  final int chatroomId;
  final String otherSideImageUrl;
  final String currentUserId;
  // final String chatroomList;

  const ChatRoomScreen({
    Key? key,
    required this.chatroomId,
    required this.otherSideImageUrl,
    required this.currentUserId,
    // required this.chatroomList,
  }) : super(key: key);
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

class _ChatRoomScreenState extends ConsumerState<ChatRoomScreen>
    with WidgetsBindingObserver {
  // final List<String> messages = [];
  final TextEditingController textEditingController = TextEditingController();
  final Color color = HexColor.fromHex('#DDE5F0');

  final ScrollController _scrollController = ScrollController();
  // final _controller = StreamController<List<ChatMessage>>();
  // IOWebSocketChannel? _channel;
  var otherSideUserChannel;

  WebSocketServiceNotifier? webSocketServiceNotifier;

  late StateNotifierProvider<WebSocketServiceNotifier, WebSocketService>
      websocketProvider;

  late WebSocketService webSocketService;

  final _formKey = GlobalKey<FormState>();

  File? _imageFile;

  bool _selectImage = false;

  String _mapString = "";

  Future<void> createDir() async {
    Directory docDir = await getApplicationDocumentsDirectory();
    Directory targetDir = Directory("${docDir.path}/SubmissionLogs/");

    if (!await targetDir.exists()) {
      await targetDir.create();
    }
  }

  Future<void> pickImage() async {
    ImagePicker _picker = ImagePicker();
    final XFile? photo = await _picker.pickImage(source: ImageSource.gallery);

    if (photo != null) {
      setState(() {
        _imageFile = File(photo.path);
        _selectImage = true;
      });
    }
  }

  void _removeImage() {
    setState(() {
      _imageFile = null;
      _selectImage = false;
    });
  }
// This is what you're looking for!

  Future<ChatRoom> fetchOtherSideUserData(int chatroomId) async {
    final token = await getToken();
    String authToken = 'token ${token}';
    // print(authToken);
    String url =
        'http://127.0.0.1:8000/api/chatroom/${chatroomId.toString()}/?is_chat=no';
    final response = await http.get(
      Uri.parse(url),
      headers: {
        'Authorization': authToken,
      },
    );

    if (response.statusCode == 200) {
      String body = utf8.decode(response.bodyBytes);
      Map<String, dynamic> chatroomMap = json.decode(body);
      ChatRoom chatroom = ChatRoom.fromJson(chatroomMap);

      return chatroom;
    } else {
      throw <ChatMessage>[];
    }
  }

  void _sendMessage(int chatroomId, String content) async {
    final token = await getToken();
    String auth_token = 'token ${token}';
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
    }

    if (content != '') {
      try {
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
      } catch (e) {
        // print('Caught exception: $e');
      }
    } else if (_imageFile != null) {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse(
            'http://127.0.0.1:8000/api/messages?chatroom_id=${chatroomId.toString()}'),
      );

      request.headers.addAll({
        'Authorization': auth_token,
      });

      request.files.add(
        await http.MultipartFile.fromPath(
          'image', // key to reference the file in the request
          _imageFile!.path,
          contentType: MediaType(
              'image', 'jpeg'), // specify the content type of the file
        ),
      );

      var response = await request.send();

      if (response.statusCode == 200) {
        setState(() {
          _selectImage = false;
          _imageFile = null;
          print('selectImage: ${_selectImage}');
        });

        print("Uploaded!");
      }
    }
  }

  @override
  void initState() {
    super.initState();
    websocketProvider = webSocketServiceProvider(
        'ws://127.0.0.1:8000/ws/chatRoomMessages/${widget.currentUserId}/');
    webSocketService = ref.read(websocketProvider);
    WidgetsBinding.instance.addObserver(this);
    _loadInitialMessages();

    // _initWebSocket();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    final webSocketServiceNotifier = ref.read(websocketProvider.notifier);

    switch (state) {
      case AppLifecycleState.resumed:
        // app在前台，用戶可見並可以與之互動
        // 檢查WebSocket連線是否已經存在，如果不存在，則建立新的連線
        if (!webSocketServiceNotifier.isWebSocketConnected()) {
          ref.watch(websocketProvider);
        }
        break;
      case AppLifecycleState.inactive:
      case AppLifecycleState.paused:
      case AppLifecycleState.detached:
        // app在後台或螢幕關閉
        // 關閉現有的WebSocket連線
        if (webSocketServiceNotifier.isWebSocketConnected()) {
          webSocketServiceNotifier.disconnectWebSocket();
        }

        break;
    }
  }

  @override
  void dispose() {
    super.dispose();
    webSocketServiceNotifier?.disconnectWebSocket();
    print('bbb');
    WidgetsBinding.instance.removeObserver(this);
  }

  Future<void> _loadInitialMessages() async {
    // print('chatroomId: ${widget.chatroomId}');
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
    // final List<ChatMessage> messages = messageList
    //     .map((item) => ChatMessage.fromJson(item as Map<String, dynamic>))
    //     .toList();
    // final List<ChatMessage> messages =
    //     messageList.map((item) => ChatMessage.fromJson(item)).toList();
    if (messageList != []) {
      _mapString = jsonEncode({
        "type": "chatrooms",
        "chatrooms": [],
        "messages": messageList,
      });

      webSocketService.addData(_mapString);
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.jumpTo(
          _scrollController.position.maxScrollExtent,
        );
      }
    });
  }

  // void _initWebSocket() async {
  //   webSocketService.stream.listen((event) {
  //     final decodedJson = jsonDecode(event);
  //     final messages = decodedJson['messages'] as List;
  //     // print('messages: ${messages}');
  //     final chatMessages = messages
  //         .map((messageJson) => ChatMessage.fromJson(messageJson))
  //         .toList();
  //     _controller.add(chatMessages);

  //     WidgetsBinding.instance.addPostFrameCallback((_) {
  //       if (_scrollController.hasClients) {
  //         _scrollController.animateTo(
  //           _scrollController.position.maxScrollExtent,
  //           duration: const Duration(milliseconds: 300),
  //           curve: Curves.easeOut,
  //         );
  //       }
  //     });
  //   });
  // }

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
                            webSocketServiceNotifier?.disconnectWebSocket();
                            Navigator.of(context)
                                .pushReplacement(MaterialPageRoute(
                                    builder: (ctx) => ProfileSwapScreen(
                                          // chatroomList: widget.chatroomList,
                                          userId: widget.currentUserId,
                                        ))); // 当点击箭头图标时，返回上一页面
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
              child: Form(
                key: _formKey,
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: _selectImage == true
                          ? TextFormField(
                              controller: textEditingController,
                              decoration: InputDecoration(
                                prefixIcon: _imageFile != null
                                    ? Padding(
                                        padding: const EdgeInsets.all(16.0),
                                        child: Image.file(
                                          _imageFile!,
                                          height: 100,
                                          fit: BoxFit.cover,
                                        ),
                                      )
                                    : null, // if the image file is not null, display it
                              ),
                            )
                          : TextField(
                              controller: textEditingController,
                              decoration: const InputDecoration(
                                hintText: "輸入訊息",
                              ),
                            ),
                    ),
                    _imageFile != null
                        ? SizedBox(
                            height: 100,
                            width: MediaQuery.of(context).size.width * 0.4,
                            child: Align(
                              alignment: Alignment.bottomCenter,
                              child: TextButton(
                                style: TextButton.styleFrom(
                                  textStyle: const TextStyle(fontSize: 20),
                                ),
                                onPressed: _removeImage,
                                child: const Text(
                                  '取消',
                                  style: TextStyle(color: Colors.red),
                                ),
                              ),
                            ),
                          )
                        : Container(),
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
                FormField(
                  builder: (formFieldState) {
                    return GestureDetector(
                        onTap: pickImage,
                        child: SizedBox(
                          width: MediaQuery.of(context).size.width * 0.3,
                          height: MediaQuery.of(context).size.height * 0.08,
                          child: const Icon(
                            Icons.collections,
                            size: 35,
                          ),
                        ));
                  },
                )
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget fetchMessageData() {
    webSocketService.chatMessageStream.listen((event) {
      // print(event);
    });
    final chatMessagesStream = webSocketService.chatMessageStream;
    return StreamBuilder<List<ChatMessage>>(
        // initialData: [],
        stream: chatMessagesStream.asBroadcastStream(),
        builder: (context, AsyncSnapshot<List<ChatMessage>> snapshot) {
          // print(snapshot.data);
          if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          }

          // 使用 snapshot.hasData 來檢查是否有可用的資料。

          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (_scrollController.hasClients) {
              _scrollController.animateTo(
                _scrollController.position.maxScrollExtent,
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOut,
              );
            }
          });
          final messages = snapshot.data ?? [];
          if (messages.length <= 7) {
            return SingleChildScrollView(child: ListViewBuilder(messages));
          } else {
            return ListViewBuilder(messages);
          }
        });
  }

  Widget ListViewBuilder(List<ChatMessage> initialData) {
    // print('initialData: ${initialData}');
    return ListView.builder(
        controller: _scrollController,
        shrinkWrap: initialData.length <= 7 ? true : false,
        itemCount: initialData.isEmpty ? 1 : initialData.length + 1,
        itemBuilder: (context, index) {
          if (initialData.isEmpty) {
            return ListTile(
              title: FutureBuilder(
                future: fetchOtherSideUserData(widget.chatroomId),
                builder: (BuildContext context,
                    AsyncSnapshot<ChatRoom> asyncSnapshot) {
                  if (asyncSnapshot.hasError) {
                    return Text('Error: ${asyncSnapshot.error}');
                  }

                  // 使用 asyncSnapshot.hasData 來檢查是否有可用的資料。
                  // 如果 asyncSnapshot.data 為 null 或者 asyncSnapshot.data 為空，
                  // 則顯示 CircularProgressIndicator。
                  if (asyncSnapshot.connectionState ==
                      ConnectionState.waiting) {
                    return CircularProgressIndicator();
                  }

                  // 如果有可用的資料，則顯示聊天訊息列表。
                  return Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(
                          right: 8.0,
                        ),
                        child: Column(
                          children: [
                            SizedBox(
                              height: MediaQuery.of(context).size.height * 0.3,
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
                                height:
                                    MediaQuery.of(context).size.height * 0.23,
                                child: Image.asset(
                                  widget.otherSideImageUrl,
                                  width: MediaQuery.of(context).size.width,
                                  height: MediaQuery.of(context).size.height,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            SizedBox(
                              width: MediaQuery.of(context).size.width * 0.4,
                              child: Padding(
                                padding: const EdgeInsets.only(top: 4.0),
                                child: Text(
                                  '${asyncSnapshot.data!.other_side_user.name} ${asyncSnapshot.data!.other_side_user.age}',
                                  style: const TextStyle(fontSize: 20),
                                ),
                              ),
                            ),
                            SizedBox(
                              width: MediaQuery.of(context).size.width * 0.5,
                              child: Text(
                                '3km, 台南 ${asyncSnapshot.data!.other_side_user.career}',
                                style: const TextStyle(color: Colors.black45),
                              ),
                            ),
                            SizedBox(
                              width: MediaQuery.of(context).size.width * 0.5,
                              child: Text(
                                asyncSnapshot.data!.other_side_user.about_me
                                    .substring(
                                        0,
                                        min(
                                            24,
                                            asyncSnapshot.data!.other_side_user
                                                .about_me.length)),
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
                },
              ),
            );
          } else {
            if (index == 0) {
              return ListTile(
                title: FutureBuilder(
                  future: fetchOtherSideUserData(widget.chatroomId),
                  builder: (BuildContext context,
                      AsyncSnapshot<ChatRoom> asyncSnapshot) {
                    if (asyncSnapshot.hasError) {
                      return Text('Error: ${asyncSnapshot.error}');
                    }

                    // 使用 asyncSnapshot.hasData 來檢查是否有可用的資料。
                    // 如果 asyncSnapshot.data 為 null 或者 asyncSnapshot.data 為空，
                    // 則顯示 CircularProgressIndicator。
                    if (asyncSnapshot.connectionState ==
                        ConnectionState.waiting) {
                      return CircularProgressIndicator();
                    }

                    // 如果有可用的資料，則顯示聊天訊息列表。
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
                                  height:
                                      MediaQuery.of(context).size.height * 0.23,
                                  child: Image.asset(
                                    widget.otherSideImageUrl,
                                    width: MediaQuery.of(context).size.width,
                                    height: MediaQuery.of(context).size.height,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                              SizedBox(
                                width: MediaQuery.of(context).size.width * 0.4,
                                child: Padding(
                                  padding: const EdgeInsets.only(top: 4.0),
                                  child: Text(
                                    '${asyncSnapshot.data!.other_side_user.name} ${asyncSnapshot.data!.other_side_user.age}',
                                    style: const TextStyle(fontSize: 20),
                                  ),
                                ),
                              ),
                              SizedBox(
                                width: MediaQuery.of(context).size.width * 0.5,
                                child: Text(
                                  '3km, 台南 ${asyncSnapshot.data!.other_side_user.career}',
                                  style: const TextStyle(color: Colors.black45),
                                ),
                              ),
                              SizedBox(
                                width: MediaQuery.of(context).size.width * 0.5,
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
                                  .format(initialData[index - 1].create_at),
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
                                          minWidth: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.25,
                                          maxWidth: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.75,
                                        ),
                                        decoration: BoxDecoration(
                                          color: color,
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                        child: initialData[index - 1].content !=
                                                ''
                                            ? Text(
                                                initialData[index - 1].content!,
                                                style: const TextStyle(
                                                    color: Colors.black,
                                                    fontSize: 18),
                                                textAlign: TextAlign.center,
                                              )
                                            : initialData[index - 1].image !=
                                                    null
                                                ?
                                                // ? Text('test')
                                                Image.network(
                                                    '${initialData[index - 1].image}')
                                                : Container(),
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
                            initialData[index - 1].user_id ==
                                    widget.currentUserId
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
                              child: initialData[index - 1].content != ''
                                  ? Text(
                                      initialData[index - 1].content!,
                                      style: const TextStyle(
                                          color: Colors.black, fontSize: 18),
                                      textAlign: TextAlign.center,
                                    )
                                  : initialData[index - 1].image != null
                                      ?
                                      // ? Text('test')
                                      Image.network(
                                          '${initialData[index - 1].image}')
                                      : Container(),
                            ),
                          ],
                        ),
                      ),
              ),
            );
          }
        });
  }
}
