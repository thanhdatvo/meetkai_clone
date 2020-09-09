import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_meet_kai_clone/predefined/enum_colors.dart';
import 'package:flutter_meet_kai_clone/widgets/ui/v_box.dart';
import 'package:recase/recase.dart';

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
        child: Container(
          height: 100,
          width: 300,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.all(Radius.circular(10)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Loading',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
              VBox(15),
              Divider(
                height: 1,
                color: EColors.black26.withOpacity(0.3),
              ),
              VBox(15),
              Text(
                _content.sentenceCase,
                style: TextStyle(fontStyle: FontStyle.italic, fontSize: 15),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
