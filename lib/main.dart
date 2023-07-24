import 'package:flutter/material.dart';
import './screens/index.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'package:sqflite/sqflite.dart';

// final container = ProviderContainer();

void main() {
  CachedNetworkImage.logLevel = CacheManagerLogLevel.debug;
  sqfliteFfiInit(); // 初始化 sqflite_common_ffi
  databaseFactory = databaseFactoryFfi;

  runApp(const ProviderScope(
    child: MyApp(),
  ));
}

class MyApp extends StatelessWidget {
  const MyApp({
    super.key,
  });

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
