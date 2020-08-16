import 'package:flutter/widgets.dart';

class VBox extends StatelessWidget {
  final double height;
  const VBox(this.height);
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
    );
  }
}