import 'package:flutter/material.dart';
import 'package:flutter_meet_kai_clone/predefined/routes.dart';
import 'package:flutter_meet_kai_clone/screens/chat_screen/chat_screen.dart';

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
