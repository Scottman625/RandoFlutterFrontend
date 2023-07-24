import 'package:rando/models/chatMessage.dart';
import '../shared_preferences/shared_preferences.dart';
import '../HexColor.dart';
import '../providers/websocket_provider.dart';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'main_page.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart' as intl;
import 'dart:async';
import 'dart:math';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:http_parser/http_parser.dart';

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

class _ChatRoomScreenState extends ConsumerState<ChatRoomScreen>
    with WidgetsBindingObserver {
  // final List<String> messages = [];
  final TextEditingController textEditingController = TextEditingController();
  final Color color = HexColor.fromHex('#DDE5F0');

  // late String authToken;

  final ScrollController _scrollController = ScrollController();

  var otherSideUserChannel;

  WebSocketServiceNotifier? webSocketServiceNotifier;

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

  Future<ChatRoom> fetchOtherSideUserData(int chatroomId) async {
    String token = await getToken();
    final authToken = 'token ${token}';

    String url =
        'http://127.0.0.1:8000/api/chatroom/${chatroomId.toString()}/?is_chat=no';
    // 'http://127.0.0.1:8000/api/chatroom/${chatroomId.toString()}';

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
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
    }
    String token = await getToken();
    final authToken = 'token ${token}';
    if (content != '') {
      try {
        final response = await http.post(
            Uri.parse(
                'http://127.0.0.1:8000/api/messages?chatroom_id=${chatroomId.toString()}'),
            headers: {
              'Authorization': authToken,
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
        'Authorization': authToken,
      });

      request.files.add(
        await http.MultipartFile.fromPath(
          'image', // key to reference the file in the request
          _imageFile!.path,
          contentType: MediaType(
              'image', 'jpeg'), // specify the content type of the file
        ),
      );
      _removeImage();
      var response = await request.send();

      if (response.statusCode == 200) {
        print("Uploaded!");
      }
    }
  }

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      // String token = await getToken();
      // authToken = 'token ${token}';

      final webSocketServiceNotifier =
          ref.read(webSocketServiceNotifierProvider);

      _loadInitialMessages(webSocketServiceNotifier);
    });
  }

  @override
  void dispose() async {
    super.dispose();
    String token = await getToken();
    final authToken = 'token ${token}';

    WidgetsBinding.instance.removeObserver(this);
    String url =
        'http://127.0.0.1:8000/api/refresh_chatMessages?chatroom_id=${widget.chatroomId}';
    final response = await http.post(
      Uri.parse(url),
      headers: {
        'Authorization': authToken,
      },
    );
    if (response.statusCode == 200) {
      // print(response.body);
      print('ok');
    } else {
      print('data not refresh');
    }
  }

  Future<void> _loadInitialMessages(webSocketServiceNotifier) async {
    String token = await getToken();
    final authToken = 'token ${token}';
    // print(authToken);
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
    _mapString = jsonEncode({
      "type": "chatrooms",
      "chatrooms": [],
      "messages": messageList,
    });
    webSocketServiceNotifier.addData(_mapString);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.jumpTo(
          _scrollController.position.maxScrollExtent,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    print('userId: ${widget.currentUserId}');
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
                                    builder: (ctx) => MainPageScreen(
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
                          child: CachedNetworkImage(
                            imageUrl: widget.otherSideImageUrl,
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
    final webSocketServiceNotifier = ref.read(webSocketServiceNotifierProvider);

    final chatMessagesStream = webSocketServiceNotifier.chatMessageStream;

    return StreamBuilder<List<ChatMessage>>(
        // initialData: _messagesList,
        stream: chatMessagesStream,
        builder: (context, AsyncSnapshot<List<ChatMessage>> snapshot) {
          if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          }

          // 使用 snapshot.hasData 來檢查是否有可用的資料。
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (_scrollController.hasClients) {
              _scrollController.jumpTo(
                _scrollController.position.maxScrollExtent,
              );
            }
          });

          final messages = snapshot.data ?? [];
          // print('messages: ${messages}');
          if (messages.length <= 7) {
            return SingleChildScrollView(child: ListViewBuilder(messages));
          } else {
            return ListViewBuilder(messages);
          }
        });
  }

  Widget ListViewBuilder(List<ChatMessage> initialData) {
    return ListView.builder(
        controller: _scrollController,
        shrinkWrap: initialData.length <= 7 ? true : false,
        itemCount: initialData.length + 1,
        itemBuilder: (context, index) {
          if (index == 0) {
            return ListTile(
              title: FutureBuilder(
                future: fetchOtherSideUserData(widget.chatroomId),
                builder: (BuildContext context,
                    AsyncSnapshot<ChatRoom> asyncSnapshot) {
                  if (asyncSnapshot.hasError) {
                    return Text('Errorssss: ${asyncSnapshot.error}');
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
                              child: CachedNetworkImage(
                                imageUrl:
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
                                child: CachedNetworkImage(
                                  imageUrl: widget.otherSideImageUrl,
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
          }
          print('${initialData[index - 1].user_id},${widget.currentUserId}');
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
                                        child: CachedNetworkImage(
                                          imageUrl: widget.otherSideImageUrl,
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
                                      child: initialData[index - 1].content !=
                                              ''
                                          ? Text(
                                              initialData[index - 1].content!,
                                              style: const TextStyle(
                                                  color: Colors.black,
                                                  fontSize: 18),
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
                                      child: CachedNetworkImage(
                                        imageUrl: widget.otherSideImageUrl,
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
        });
  }
}
