import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_meet_kai_clone/predefined/enum_border_radius.dart';
import 'package:flutter_meet_kai_clone/predefined/enum_colors.dart';
import 'package:flutter_meet_kai_clone/widgets/touchable_icon.dart';
import 'package:flutter_meet_kai_clone/widgets/v_box.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen();
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            color: EColors.grey,
            padding: const EdgeInsets.symmetric(horizontal: 10.0),
            child: Column(
              children: <Widget>[
                const VBox(20.0),
                const _TopMenu(),
                const VBox(20.0),
                const _Chat()
              ],
            ),
          ),
          Positioned(
            bottom: 30.0,
            left: 0,
            right: 0,
            child: _ListenButton(),
          )
        ],
      ),
    );
  }
}

class _ListenButton extends StatefulWidget {
  @override
  __ListenButtonState createState() => __ListenButtonState();
}

class __ListenButtonState extends State<_ListenButton> {
  Color _iconColor;
  @override
  void initState() {
    super.initState();
    _iconColor = EColors.black26;
  }

  _handleTapDown(_) {
    setState(() {
      _iconColor = EColors.black54;
    });
  }

  _handleTapUp(_) {
    setState(() {
      _iconColor = EColors.black26;
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: Icon(
        Icons.keyboard_voice,
        color: _iconColor,
        size: 30.0,
      ),
      onTapDown: _handleTapDown,
      onTapUp: _handleTapUp,
      onTap: () {},
    );
  }
}

class _TopMenu extends StatefulWidget {
  const _TopMenu();
  @override
  __TopMenuState createState() => __TopMenuState();
}

class __TopMenuState extends State<_TopMenu> {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          TouchableIcon(
            iconData: Icons.person,
            onPress: () {},
          ),
          TouchableIcon(
            iconData: Icons.keyboard,
            onPress: () {},
          ),
        ],
      ),
    );
  }
}

class LeftMessage extends StatefulWidget {
  LeftMessage(this.message);
  final String message;
  @override
  _LeftMessageState createState() => _LeftMessageState();
}

class _LeftMessageState extends State<LeftMessage> {
  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
        decoration: BoxDecoration(
            color: EColors.white, borderRadius: EBorderRaius.regular),
        child: Text(
          widget.message,
          style: TextStyle(color: EColors.black),
        ),
      ),
    );
  }
}

class RightMessage extends StatefulWidget {
  RightMessage(this.message);
  final String message;
  @override
  _RightMessageState createState() => _RightMessageState();
}

class _RightMessageState extends State<RightMessage> {
  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
        decoration: BoxDecoration(
            color: EColors.blue, borderRadius: EBorderRaius.regular),
        child: Text(
          widget.message,
          style: TextStyle(color: EColors.white),
        ),
      ),
    );
  }
}

class _Chat extends StatefulWidget {
  const _Chat();
  @override
  __ChatState createState() => __ChatState();
}

class __ChatState extends State<_Chat> {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: [LeftMessage('Left message'), RightMessage('Right message')],
      ),
    );
  }
}
