import 'package:flutter/material.dart';
import 'package:flutter_meet_kai_clone/pages/chat.dart';
import 'package:flutter_meet_kai_clone/predefined/routes.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const ChatScreen(),
      routes: routes,
    );
  }
}
