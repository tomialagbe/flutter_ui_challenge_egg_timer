import 'dart:math';
import 'dart:ui';

import 'package:flutter/widgets.dart';

class RandomColor {

  static final Random _random = new Random();

  static Color next() {
    return new Color(0xFF000000 + _random.nextInt(0x00FFFFFF));
  }

}

class RandomColorBlock extends StatefulWidget {

  final double width;
  final double height;
  final Widget child;

  RandomColorBlock({this.width, this.height, this.child});

  @override
  _RandomColorBlockState createState() => new _RandomColorBlockState();
}

class _RandomColorBlockState extends State<RandomColorBlock> {

  Color randomColor;

  @override
  void initState() {
    super.initState();

    randomColor = RandomColor.next();
  }

  @override
  Widget build(BuildContext context) {
    return new Container(
      width: widget.width,
      height: widget.height,
      color: randomColor,
      child: widget.child,
    );
  }
}
