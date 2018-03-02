import 'package:flutter/material.dart';
import 'package:egg_timer/egg_timer.dart';

void main() {
  runApp(new MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'Egg Timer',
      theme: new ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: new EggTimer(),
    );
  }
}
