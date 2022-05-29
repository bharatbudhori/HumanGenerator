import 'package:flutter/material.dart';
import 'package:human_generator/home.dart';
//import 'package:human_generator/splashscreen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Human Generator',
      debugShowCheckedModeBanner: false,
      home: Home(),
    );
  }
}
