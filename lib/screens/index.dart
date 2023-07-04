import 'package:flutter/material.dart';
import 'phone_login.dart';
import 'register_page.dart';
import '../token/user_token.dart';

class IndexPage extends StatefulWidget {
  const IndexPage({super.key});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  @override
  State<IndexPage> createState() => _IndexPage();
}

class _IndexPage extends State<IndexPage> {
  void _phoneLogin() {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (ctx) => PhoneLogIn(),
    ));
  }

  void _register() {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (ctx) => Register(),
    ));
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      // appBar: AppBar(
      //   // Here we take the value from the MyHomePage object that was created by
      //   // the App.build method, and use it to set our appbar title.
      //   title: Text(widget.title),
      // ),
      body: Container(
        child: Column(
            // Center is a layout widget. It takes a single child and positions it
            // in the middle of the parent.
            children: <Widget>[
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.45,
                child: SizedBox(
                    child: Align(
                  alignment: const Alignment(-1, 0.8),
                  child: Container(
                    height: 98,
                    width: MediaQuery.of(context).size.width,
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                          begin: Alignment(-0.3, -0.2),
                          end: Alignment(0.5, -1),
                          colors: [
                            Colors.grey,
                            Colors.lightBlueAccent,
                          ]),
                    ),
                    child: Row(
                      children: [
                        SizedBox(
                          width: MediaQuery.of(context).size.width * 0.4,
                          child: Align(
                            alignment: const Alignment(0.7, -0.1),
                            child: Image.asset(
                              'assets/images/logo.png',
                              width: 60,
                              height: 60,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        const SizedBox(
                          child: Align(
                            alignment: Alignment(0.4, 0),
                            child: Text(
                              'Rando',
                              style: TextStyle(
                                fontFamily: 'Comfortaa',
                                fontWeight: FontWeight.bold,
                                fontSize: 48,
                                shadows: [
                                  Shadow(
                                    blurRadius: 0.1, // shadow blur
                                    color: Colors.grey, // shadow color
                                    offset: Offset(0,
                                        5.0), // how much shadow will be shown
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                )),
              ),
              Column(
                children: [
                  Container(height: 70),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Container(
                      height: 35,
                      width: MediaQuery.of(context).size.width * 0.7,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8), // 這裡設定了圓角的半徑
                        border: Border.all(
                            color: Colors.black, width: 3), // 這裡設定了邊框的顏色和寬度
                        // color: Colors.white, // 這裡設定了矩形的顏色
                      ),
                      child: ElevatedButton(
                        onPressed: _phoneLogin,
                        style: ButtonStyle(
                          backgroundColor:
                              MaterialStateProperty.all<Color>(Colors.white),
                        ),
                        child: Center(
                          child: Text(
                            '手機號碼 登入',
                            style: TextStyle(
                                fontSize: 16,
                                fontFamily: 'Roboto',
                                fontWeight: FontWeight.bold,
                                color: Colors.black),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Container(
                      height: 35,
                      width: MediaQuery.of(context).size.width * 0.7,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8), // 這裡設定了圓角的半徑
                        border: Border.all(
                            color: Colors.black, width: 3), // 這裡設定了邊框的顏色和寬度
                        // color: Colors.white, // 這裡設定了矩形的顏色
                      ),
                      child: ElevatedButton(
                        onPressed: () {},
                        style: ButtonStyle(
                          backgroundColor:
                              MaterialStateProperty.all<Color>(Colors.white),
                        ),
                        child: Center(
                          child: Text(
                            'GOOGLE 登入',
                            style: TextStyle(
                                fontSize: 16,
                                fontFamily: 'Roboto',
                                fontWeight: FontWeight.bold,
                                color: Colors.black),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Container(
                      height: 35,
                      width: MediaQuery.of(context).size.width * 0.7,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8), // 這裡設定了圓角的半徑
                        border: Border.all(
                            color: Colors.black, width: 3), // 這裡設定了邊框的顏色和寬度
                        // color: Colors.white, // 這裡設定了矩形的顏色
                      ),
                      child: ElevatedButton(
                        onPressed: getToken,
                        style: ButtonStyle(
                          backgroundColor:
                              MaterialStateProperty.all<Color>(Colors.white),
                        ),
                        child: Center(
                          child: Text(
                            'APPLE 登入',
                            style: TextStyle(
                                fontSize: 16,
                                fontFamily: 'Roboto',
                                fontWeight: FontWeight.bold,
                                color: Colors.black),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 8, bottom: 40),
                    child: Container(
                      height: 35,
                      width: MediaQuery.of(context).size.width * 0.45,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8), // 這裡設定了圓角的半徑
                        color: Colors.black, // 這裡設定了矩形的顏色
                      ),
                      child: ElevatedButton(
                        onPressed: _register,
                        style: ButtonStyle(
                          backgroundColor:
                              MaterialStateProperty.all<Color>(Colors.black),
                        ),
                        child: Text(
                          'REGISTER',
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
                  SizedBox(
                      width: MediaQuery.of(context).size.width,
                      child: Row(
                        children: [
                          SizedBox(
                            width: MediaQuery.of(context).size.width * 0.25,
                            child: Align(
                              alignment: const Alignment(0.9, 0),
                              child: ClipOval(
                                child: Image.asset(
                                  'assets/images/teamlogo.png',
                                  height: 35,
                                  width: 35,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(
                            width: MediaQuery.of(context).size.width * 0.35,
                            child: Column(
                              children: [
                                Text(
                                  "Pawel Czerwinski",
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontFamily: 'Roboto',
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  ),
                                  textAlign: TextAlign.left,
                                ),
                                Text(
                                  "@pawel_czerwinski",
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontFamily: 'Roboto',
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  ),
                                ),
                              ],
                            ),
                          )
                        ],
                      )),
                ],
              )
            ]),
      ),
    );
  }
}
