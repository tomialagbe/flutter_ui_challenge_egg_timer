import 'package:flutter/material.dart';
import 'package:fluttery/framing.dart';

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
        fontFamily: 'BebasNeue',
      ),
      home: new Scaffold(
        body: new Center(
          child: new Column(
            children: [
              new RandomColorBlock(
                width: double.INFINITY,
                height: 150.0,
              ),
              new RandomColorBlock(
                width: double.INFINITY,
                child: new Padding(
                  padding: const EdgeInsets.all(30.0),
                  child: new AspectRatio(
                    aspectRatio: 1.0,
                    child: new RandomColorBlock(
                      width: double.INFINITY,
                    ),
                  ),
                ),
              ),
              new Expanded(child: new Container()),
              new RandomColorBlock(
                width: double.INFINITY,
                height: 50.0,
              ),
              new RandomColorBlock(
                width: double.INFINITY,
                height: 50.0,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
