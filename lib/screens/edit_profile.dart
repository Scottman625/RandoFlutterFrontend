import '../models/user.dart';
import '../HexColor.dart';
import '../shared_preferences/shared_preferences.dart';

import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'dart:convert';
import 'package:dotted_border/dotted_border.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';

class EditProfileScreen extends StatefulWidget {
  final User user;
  const EditProfileScreen({super.key, required this.user});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  List<UserImage> userImages = [];
  late ValueNotifier<List<UserImage>> userImagesNotifier =
      ValueNotifier<List<UserImage>>(userImages ?? []);

  final _formKey = GlobalKey<FormState>();

  var _about_me = '';

  var _interest = '';

  Future<dynamic> getUserData() async {
    final token = await getToken();
    String auth_token = 'token ${token}';
    final response = await http.get(
      Uri.parse('http://127.0.0.1:8000/api/user/me/'),
      headers: {
        'Authorization': auth_token,
      },
    );

    String body = utf8.decode(response.bodyBytes);
    // print('body: ${body}');

    return body;
  }

  void _pickImage() async {
    // ImagePicker _picker = ImagePicker();
    // final pickedFile =
    //     await _picker.pickImage(source: ImageSource.gallery);
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      final croppedFile = await ImageCropper().cropImage(
        sourcePath: pickedFile.path,
        aspectRatio: CropAspectRatio(ratioX: 3, ratioY: 4),
        compressQuality: 100,
        maxWidth: 700,
        maxHeight: 700,
        compressFormat: ImageCompressFormat.jpg,
        uiSettings: [
          AndroidUiSettings(
              toolbarTitle: 'Cropper',
              toolbarColor: Colors.deepOrange,
              toolbarWidgetColor: Colors.white,
              initAspectRatio: CropAspectRatioPreset.original,
              lockAspectRatio: false),
          IOSUiSettings(
            title: 'Cropper',
          ),
        ],
      );
      if (croppedFile != null) {
        var croppedImage = File(croppedFile.path); // Change CroppedFile to File

        final token = await getToken();
        String auth_token = 'token ${token}';
        final request = http.MultipartRequest(
          'POST',
          Uri.parse('http://127.0.0.1:8000/api/user/upload_user_images'),
        );

        request.headers.addAll({
          'Authorization': auth_token,
        });

        request.files.add(
          await http.MultipartFile.fromPath(
            'image',
            croppedImage.path,
          ),
        );

        final response = await request.send();
        if (response.statusCode == 200) {
          final respStr = await response.stream.bytesToString();
          List<dynamic> listmap = json.decode(respStr)['userImages'];
          userImages = listmap
              .map((userImage) => UserImage.fromJson(userImage))
              .toList();
          userImagesNotifier!.value = userImages;
          // setState(() {
          //   userImages = listmap
          //       .map((userImage) => UserImage.fromJson(userImage))
          //       .toList();
          // });
        }
      }
    }
  }

  Future<void> showModelButtomDeleteImage(userImageId) {
    return showModalBottomSheet<void>(
        context: context,
        backgroundColor: Colors.black12.withOpacity(0),
        barrierColor: Colors.black38,
        builder: (BuildContext context) {
          return Container(
            height: 250,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Center(
                    child: Container(
                      width: MediaQuery.of(context).size.width,
                      height: 110,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color: Colors.white,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          const Text(
                            '你確定要刪除此圖片嗎？',
                            style: TextStyle(fontSize: 16),
                          ),
                          const Text(
                            '刪除後將不可恢復',
                            style:
                                TextStyle(fontSize: 16, color: Colors.black45),
                          ),
                          TextButton(
                            child: const Text(
                              '刪除',
                              style: TextStyle(
                                  color: Colors.red,
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold),
                            ),
                            onPressed: () async {
                              final token = await getToken();
                              String auth_token = 'token ${token}';
                              final response = await http.delete(
                                Uri.parse(
                                    'http://127.0.0.1:8000/api/user/update_user_images/${userImageId}/'),
                                headers: {
                                  'Authorization': auth_token,
                                },
                              );

                              String body = utf8.decode(response.bodyBytes);
                              print(body);
                              List<dynamic> listmap =
                                  json.decode(body)['userImages'];
                              userImages = listmap
                                  .map((userImage) =>
                                      UserImage.fromJson(userImage))
                                  .toList();
                              userImagesNotifier!.value = userImages;
                              // setState(() {
                              //   userImages = listmap
                              //       .map((userImage) =>
                              //           UserImage.fromJson(userImage))
                              //       .toList();
                              // });
                              Navigator.pop(context);
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    width: MediaQuery.of(context).size.width * 0.95,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: Colors.white,
                    ),
                    height: 60,
                    child: TextButton(
                      child: const Text(
                        '取消',
                        style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.black),
                      ),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                ),
              ],
            ),
          );
        });
  }

  @override
  void initState() {
    super.initState();
    userImagesNotifier = ValueNotifier<List<UserImage>>(userImages ?? []);

    getUserData().then((value) {
      setState(() {
        User user = User.fromJson(json.decode(value));
        user = user;
        List<dynamic> listmap = json.decode(value)['userImages'];

        userImages =
            listmap.map((userImage) => UserImage.fromJson(userImage)).toList();
      });
    });
    // This function fetches data and then sets the state.
  }

  @override
  void dispose() {
    userImagesNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: HexColor.fromHex('#EFEBEB'),
      height: MediaQuery.of(context).size.height,
      width: MediaQuery.of(context).size.width,
      child: ListView(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 20.0),
            child: SizedBox(
              height: 50,
              width: MediaQuery.of(context).size.width,
              child: Row(
                children: [
                  Padding(
                    padding: EdgeInsets.only(left: 8.0),
                    child: Material(
                      color: HexColor.fromHex('#EFEBEB'),
                      child: IconButton(
                        icon: const Icon(Icons.arrow_back),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                      ),
                    ),
                  ),
                  const Expanded(
                    child: Align(
                      alignment: Alignment(-0.2, 0),
                      child: SizedBox(
                        child: Text(
                          '編輯個人資料',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 20,
                            decoration: TextDecoration.none,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(right: 8.0),
                    child: Material(
                      color: HexColor.fromHex('#EFEBEB'),
                      child: TextButton(
                        child: const Text(
                          '完成',
                          style: TextStyle(color: Colors.orange, fontSize: 18),
                        ),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Container(
                height: MediaQuery.of(context).size.height * 1.5,
                width: MediaQuery.of(context).size.width,
                color: HexColor.fromHex('#EFEBEB'),
                child: Column(
                  children: [
                    SizedBox(
                        height: MediaQuery.of(context).size.height * 0.4,
                        width: MediaQuery.of(context).size.width,
                        child: buildGridView1()),
                    Align(
                      alignment: Alignment(-0.7, 1),
                      child: SizedBox(
                        height: 50,
                        width: MediaQuery.of(context).size.width * 0.5,
                        child: Row(
                          children: [
                            Text(
                              widget.user.name,
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                                decoration: TextDecoration.none,
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.only(left: 10),
                              child: Container(
                                height: 20,
                                width: 60,
                                decoration: BoxDecoration(
                                    color: widget.user.gender == 'M'
                                        ? Colors.blueAccent
                                        : Colors.pinkAccent,
                                    borderRadius: BorderRadius.circular(30)),
                                child: Center(
                                  child: SizedBox(
                                    width: 50,
                                    child: Row(
                                      children: [
                                        Icon(
                                          widget.user.gender == 'M'
                                              ? Icons.male
                                              : Icons.female,
                                          size: 18,
                                          color: Colors.white,
                                        ),
                                        Text(
                                          widget.user.age.toString(),
                                          style: const TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                            decoration: TextDecoration.none,
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(30.0),
                      child: Row(
                        children: [
                          ClipOval(
                              child: Container(
                            height: 30,
                            width: 30,
                            color: Colors.blueAccent,
                            child: const Icon(
                              Icons.check,
                              color: Colors.white,
                            ),
                          )),
                          const Text(
                            '  個人照片認證',
                            style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w900,
                                decoration: TextDecoration.none,
                                color: Colors.black),
                          )
                        ],
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 12.0),
                      child: Align(
                        alignment: Alignment(-0.85, 1),
                        child: Text(
                          '關於我',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                            decoration: TextDecoration.none,
                          ),
                        ),
                      ),
                    ),
                    Container(
                      height: MediaQuery.of(context).size.height * 0.2,
                      width: MediaQuery.of(context).size.width,
                      color: Colors.white,
                      child: Padding(
                        padding: const EdgeInsets.only(
                            top: 4.0, left: 12, right: 10),
                        child: Material(
                          color: Colors.white,
                          child: TextFormField(
                            initialValue: widget.user.about_me,
                            decoration: const InputDecoration(
                              border: InputBorder.none,
                              fillColor: Colors.white,
                            ),
                            onSaved: (value) {
                              _about_me = value!;
                            },
                          ),
                        ),
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 12.0),
                      child: Align(
                        alignment: Alignment(-0.85, 1),
                        child: Text(
                          '興趣',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                            decoration: TextDecoration.none,
                          ),
                        ),
                      ),
                    ),
                    Container(
                      height: MediaQuery.of(context).size.height * 0.12,
                      width: MediaQuery.of(context).size.width,
                      color: Colors.white,
                      child: Padding(
                        padding: const EdgeInsets.only(
                            top: 4.0, left: 12, right: 10),
                        child: Material(
                          color: Colors.white,
                          child: TextFormField(
                            decoration: const InputDecoration(
                              border: InputBorder.none,
                              fillColor: Colors.white,
                            ),
                            onSaved: (value) {
                              _interest = value!;
                            },
                          ),
                        ),
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 12.0),
                      child: Align(
                        alignment: Alignment(-0.85, 1),
                        child: Text(
                          '基本資料',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                            decoration: TextDecoration.none,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildGridView1() {
    return ValueListenableBuilder<List<UserImage>>(
      valueListenable: userImagesNotifier,
      builder:
          (BuildContext context, List<UserImage> userImages, Widget? child) {
        return GridView(
          padding: EdgeInsets.symmetric(vertical: 12, horizontal: 8),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              //横轴元素个数
              crossAxisCount: 3,
              //纵轴间距
              mainAxisSpacing: 20.0,
              //横轴间距
              crossAxisSpacing: 15.0,
              //子组件宽高长度比例
              childAspectRatio: 0.8),

          ///GridView中使用的子Widegt
          children: buildListViewItemList(),
        );
      },
    );
  }

  List<Widget> buildListViewItemList() {
    List<Widget> list = [];

    ///模拟的8条数据
    for (int i = 0; i < 6; i++) {
      list.add(buildListViewItemWidget(i, userImages));
    }
    return list;
  }

  Widget buildListViewItemWidget(int index, List<UserImage> userImages) {
    return Container(
      ///内容剧中
      alignment: Alignment.center,

      key: index <= userImages.length - 1
          ? ValueKey(userImages[index].id)
          : ValueKey('@value_key_${index}'),
      child: index <= userImages.length - 1
          ? Container(
              height: MediaQuery.of(context).size.height * 0.3,
              width: MediaQuery.of(context).size.width * 0.3,
              decoration:
                  BoxDecoration(borderRadius: BorderRadius.circular(20)),
              child: Stack(children: [
                ClipRRect(
                  borderRadius: const BorderRadius.all(Radius.circular(20.0)),
                  child: CachedNetworkImage(
                    imageUrl: userImages[index].image,
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.height,
                    fit: BoxFit.cover,
                  ),
                ),
                Align(
                  alignment: const Alignment(1.15, 1.15),
                  child: SizedBox(
                    width: 40,
                    height: 40,
                    child: Stack(children: [
                      Center(
                        child: ClipOval(
                          child: Container(
                            height: 35,
                            width: 35,
                            color: Colors.blueGrey,
                          ),
                        ),
                      ),
                      Center(
                        child: ClipOval(
                          child: Container(
                            height: 33,
                            width: 33,
                            color: Colors.white,
                            child: GestureDetector(
                              onTap: () {
                                showModelButtomDeleteImage(
                                    userImages[index].id);
                              },
                              child: const Icon(
                                Icons.close,
                                color: Colors.blueGrey,
                                size: 27,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ]),
                  ),
                ),
              ]),
            )
          : DottedBorder(
              strokeWidth: 1,
              borderType: BorderType.RRect,
              radius: const Radius.circular(20),
              dashPattern: [12, 5],
              color: const Color.fromARGB(255, 173, 171, 171),

              // strokeCap: StrokeCap.round,
              child: Container(
                  // height: MediaQuery.of(context).size.height * 0.3,
                  // width: MediaQuery.of(context).size.width * 0.3,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: Color.fromARGB(255, 230, 227, 227),
                  ),
                  child: Stack(
                    children: [
                      Align(
                        alignment: const Alignment(1.15, 1.15),
                        child: ClipOval(
                          child: Container(
                            height: 35,
                            width: 35,
                            child: Material(
                                color: Colors.red,
                                child: GestureDetector(
                                  onTap: _pickImage,
                                  child: const Icon(
                                    Icons.add,
                                    color: Colors.white,
                                    size: 27,
                                  ),
                                )),
                          ),
                        ),
                      ),
                    ],
                  )),
            ),
    );
  }
}
