import 'package:flutter/material.dart';
import '../screens/profile_swap.dart';
import '../widgets/main_appbar.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../shared_preferences/shared_preferences.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/loginstate_provider.dart';

class PhoneLogIn extends ConsumerStatefulWidget {
  const PhoneLogIn({super.key});

  @override
  ConsumerState<PhoneLogIn> createState() => _PhoneLogInState();
}

class _PhoneLogInState extends ConsumerState<PhoneLogIn> {
  final _formKey = GlobalKey<FormState>();

  var _phoneNumber = '';

  var _password = '';

  Future<void> logIn() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      try {
        final url = Uri.parse('http://127.0.0.1:8000/api/user/login/');
        var response = await http.post(url,
            // headers: {
            //   'Content-Type': 'application/json',
            // },
            body: {
              'username': _phoneNumber,
              'password': _password,
            });
        // print(response.body);
        final token = jsonDecode(response.body)['token'];
        if (token != null) {
          saveToken(token);
          ref.read(authStateProvider.notifier).login();
          fetchChatRoomsData();
          var chatroom_list = await getChatRoomList();
          Navigator.of(context).push(MaterialPageRoute(
              builder: (ctx) => ProfileSwapScreen(
                    chatroomList: chatroom_list,
                  )));
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Center(
                child: Text(
                  '電話號碼或密碼不正確!',
                  style: TextStyle(fontSize: 20),
                ),
              ),
              backgroundColor: Colors.red,
            ),
          );
        }
      } catch (e) {
        print('Caught exception: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            MainAppBar(Colors.lightBlueAccent),
            Row(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    '手機號碼登入',
                    style: TextStyle(fontSize: 35),
                  ),
                )
              ],
            ),
            Form(
                key: _formKey,
                child: Column(
                  children: [
                    Padding(
                      padding: EdgeInsets.only(top: 25.0, left: 25, right: 25),
                      child: TextFormField(
                        maxLength: 10,
                        decoration: InputDecoration(
                            enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                    color: Colors.black, width: 2.0)),
                            filled: true,
                            fillColor: Colors.white,
                            hintText: '請輸入您的電話號碼'),
                        validator: (value) {
                          if (value == null ||
                              value.isEmpty ||
                              value.trim().length <= 1 ||
                              value.trim().length > 50) {
                            return '必須是有效的10位數號碼';
                          }
                          return null;
                        },
                        onSaved: (value) {
                          _phoneNumber = value!;
                        },
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(left: 25, right: 25),
                      child: TextFormField(
                        maxLength: 30,
                        decoration: InputDecoration(
                            enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                    color: Colors.black, width: 2.0)),
                            filled: true,
                            fillColor: Colors.white,
                            hintText: '請輸入您的密碼'),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return '此欄位不能為空';
                          }
                          return null;
                        },
                        onSaved: (value) {
                          _password = value!;
                        },
                        onFieldSubmitted: (value) {
                          logIn();
                        },
                      ),
                    ),
                    Container(
                      height: 50,
                      width: MediaQuery.of(context).size.width * 0.75,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8), // 這裡設定了圓角的半徑
                        color: Colors.black, // 這裡設定了矩形的顏色
                      ),
                      child: ElevatedButton(
                        onPressed: () {
                          logIn();
                        },
                        style: ButtonStyle(
                          backgroundColor:
                              MaterialStateProperty.all<Color>(Colors.black),
                        ),
                        child: const Center(
                          child: Text(
                            '登入',
                            style: TextStyle(
                              fontSize: 16,
                              fontFamily: 'Roboto',
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ))
          ],
        ),
      ),
    );
  }
}
