import 'package:flutter/widgets.dart';
import 'package:flutter_meet_kai_clone/predefined/enum_colors.dart';

class TouchableIcon extends StatefulWidget {
  final IconData iconData;
  final Function onPress;
  const TouchableIcon({Key key, this.iconData, this.onPress}) : super(key: key);
  @override
  _TouchableIconState createState() => _TouchableIconState();
}

class _TouchableIconState extends State<TouchableIcon> {
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
        widget.iconData,
        color: _iconColor,
        size: 30.0,
      ),
      onTapDown: _handleTapDown,
      onTapUp: _handleTapUp,
      onTap: widget.onPress,
    );
  }
}