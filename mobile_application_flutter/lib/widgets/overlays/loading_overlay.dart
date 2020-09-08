import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_meet_kai_clone/widgets/ui/v_box.dart';

class LoadingOverlay extends StatefulWidget {
  const LoadingOverlay({Key key}) : super(key: key);
  @override
  LoadingOverlayState createState() => LoadingOverlayState();
}

class LoadingOverlayState extends State<LoadingOverlay> {
  String _content;
  @override
  void initState() {
    super.initState();
    _content = "Start fetching";
  }

  setContent(String content) {
    print(content);
    setState(() {
      _content = content;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black.withOpacity(0.05),
      child: Align(
        alignment: Alignment.center,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Loading',
              style: TextStyle(fontStyle: FontStyle.italic, fontSize: 15),
            ),
            VBox(5),
            Text(
              "\"$_content\"",
              style: TextStyle(fontStyle: FontStyle.italic, fontSize: 15),
            ),
          ],
        ),
      ),
    );
  }
}
