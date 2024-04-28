import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'main_page.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../providers/loginstate_provider.dart';
import '../shared_preferences/shared_preferences.dart';
import 'dart:async';
import '../web_socket.dart';

class Register extends ConsumerStatefulWidget {
  const Register({super.key});

  @override
  ConsumerState<Register> createState() => _RegisterState();
}

class _RegisterState extends ConsumerState<Register> {
  final _formKey = GlobalKey<FormState>();

  var _phoneNumber = '';
  var _userName = '';
  var _password = '';

  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  @override
  Widget build(BuildContext context) {
    // void _turn_back_page() {
    //   Navigator.of(context)
    //       .push(MaterialPageRoute(builder: (ctx) => IndexPage()));
    // }

    void register() async {
      if (_formKey.currentState!.validate()) {
        _formKey.currentState!.save();

        final url =
            Uri.parse('https://randojavabackend.zeabur.app/api/user/register/');
        var response = await http.post(url,
            // headers: {
            //   'Content-Type': 'application/json',
            // },
            body: {
              'phone': _phoneNumber,
              'username': _userName,
              'password': _password,
            });
        print(jsonDecode(response.body));
        final token = jsonDecode(response.body)['data']['token'];
        print('token : ${token}');
        if (token != null) {
          saveToken(token);
          String auth_token = 'Bearer $token';
          print(auth_token);
          final response = await http.get(
              Uri.parse(
                  'https://randojavabackend.zeabur.app/api/user/get_user_id/'),
              headers: {
                'Authorization': auth_token,
              });
          print(response.statusCode);
          String UserId = jsonDecode(response.body)['data']['userId'];

          ref.read(authStateProvider.notifier).login();
          // final _channel = WebSocketService()
          //     .create('ws://randojavabackend.zeabur.app/chatRoomMessages/${UserId}/');
          const chatroomList = '';
          Navigator.of(context).push(MaterialPageRoute(
              builder: (ctx) => MainPageScreen(
                    // chatroomList: chatroomList,
                    userId: UserId.toString(),
                  )));
        } else {
          String responseMessage = jsonDecode(response.body)['message'];
          if (responseMessage
              .contains('This phone number is already been used.')) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Center(
                  child: Text(
                    '此電話號碼已有其他用戶使用!',
                    style: TextStyle(fontSize: 20),
                  ),
                ),
                backgroundColor: Colors.red,
              ),
            );
          } else if (responseMessage.contains('register failed')) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Center(
                  child: Text(
                    '註冊失敗，請稍候重試一次!',
                    style: TextStyle(fontSize: 20),
                  ),
                ),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      }
    }

    return Scaffold(
      body: Column(
        children: [
          SizedBox(
            height: 120,
          ),
          const Row(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  '手機號碼註冊',
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
                    padding:
                        const EdgeInsets.only(top: 25.0, left: 25, right: 25),
                    child: TextFormField(
                      maxLength: 10,
                      decoration: const InputDecoration(
                          enabledBorder: OutlineInputBorder(
                              borderSide:
                                  BorderSide(color: Colors.black, width: 2.0)),
                          filled: true,
                          fillColor: Colors.white,
                          hintText: '請輸入您的電話號碼'),
                      validator: (value) {
                        if (value == null ||
                            value.isEmpty ||
                            value.trim().length <= 1 ||
                            value.trim().length > 50) {
                          return 'Must be between 1 and 50 characters.';
                        }
                        return null;
                      },
                      onSaved: (value) {
                        _phoneNumber = value!;
                      },
                    ),
                  ),
                  Padding(
                    padding:
                        const EdgeInsets.only(top: 25.0, left: 25, right: 25),
                    child: TextFormField(
                      maxLength: 20,
                      decoration: const InputDecoration(
                          enabledBorder: OutlineInputBorder(
                              borderSide:
                                  BorderSide(color: Colors.black, width: 2.0)),
                          filled: true,
                          fillColor: Colors.white,
                          hintText: '請輸入您的暱稱'),
                      validator: (value) {
                        if (value == null ||
                            value.isEmpty ||
                            value.trim().length <= 1 ||
                            value.trim().length > 50) {
                          return 'Must be between 1 and 50 characters.';
                        }
                        return null;
                      },
                      onSaved: (value) {
                        _userName = value!;
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 25, right: 25),
                    child: TextFormField(
                      maxLength: 30,
                      controller: passwordController,
                      decoration: const InputDecoration(
                          enabledBorder: OutlineInputBorder(
                              borderSide:
                                  BorderSide(color: Colors.black, width: 2.0)),
                          filled: true,
                          fillColor: Colors.white,
                          hintText: '請輸入您的密碼'),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Must be a valid, positive number';
                        }
                        return null;
                      },
                      onSaved: (value) {
                        _password = value!;
                      },
                      onFieldSubmitted: (value) {
                        register();
                      },
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(left: 25, right: 25, bottom: 20),
                    child: TextFormField(
                      maxLength: 30,
                      controller: confirmPasswordController,
                      decoration: const InputDecoration(
                          enabledBorder: OutlineInputBorder(
                              borderSide:
                                  BorderSide(color: Colors.black, width: 2.0)),
                          filled: true,
                          fillColor: Colors.white,
                          hintText: '請再次輸入您的密碼'),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Must be a valid, positive number';
                        } else if (passwordController.text !=
                            confirmPasswordController.text) {
                          return '您輸入的兩次密碼不一致!';
                        }
                        return null;
                      },
                      onFieldSubmitted: (value) {
                        register();
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
                      onPressed: register,
                      style: ButtonStyle(
                        backgroundColor:
                            MaterialStateProperty.all<Color>(Colors.black),
                      ),
                      child: const Center(
                        child: Text(
                          '確認註冊',
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
    );
  }
}
