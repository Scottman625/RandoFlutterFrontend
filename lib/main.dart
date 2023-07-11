import 'package:flutter/material.dart';
import './screens/index.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  runApp(ProviderScope(child: const MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Rando',
      theme: ThemeData(
          primarySwatch: Colors.grey, canvasColor: Colors.lightBlueAccent),
      home: const IndexPage(),
    );
  }
}
