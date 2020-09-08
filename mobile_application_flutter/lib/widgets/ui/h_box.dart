import 'package:flutter/widgets.dart';

class HBox extends StatelessWidget {
  final double width;
  const HBox(this.width);
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
    );
  }
}
