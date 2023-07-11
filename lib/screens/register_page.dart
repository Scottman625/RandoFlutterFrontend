import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../widgets/main_appbar.dart';
import '../screens/profile_swap.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../providers/loginstate_provider.dart';
import '../shared_preferences/shared_preferences.dart';

class Register extends ConsumerStatefulWidget {
  const Register({super.key});

  @override
  ConsumerState<Register> createState() => _RegisterState();
}

class _RegisterState extends ConsumerState<Register> {
  final _formKey = GlobalKey<FormState>();

  var _phoneNumber = '';

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

        final url = Uri.parse('http://127.0.0.1:8000/api/user/create/');
        var response = await http.post(url,
            // headers: {
            //   'Content-Type': 'application/json',
            // },
            body: {
              'phone': _phoneNumber,
              'password': _password,
            });
        print(jsonDecode(response.body)['phone']);
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
      }
    }

    return Scaffold(
      body: Column(
        children: [
          MainAppBar(Colors.lightBlueAccent),
          Row(
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
                    padding: EdgeInsets.only(top: 25.0, left: 25, right: 25),
                    child: TextFormField(
                      maxLength: 10,
                      decoration: InputDecoration(
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
                    padding: EdgeInsets.only(left: 25, right: 25),
                    child: TextFormField(
                      maxLength: 30,
                      controller: passwordController,
                      decoration: InputDecoration(
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
                      decoration: InputDecoration(
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
