import 'package:flutter/widgets.dart';
import 'package:flutter_meet_kai_clone/modals/data/message_position.dart';

class Message {
  final String content;
  final MessagePosition position;
  Message(this.content, {@required this.position});
}
