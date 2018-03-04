import 'package:egg_timer/framing.dart';
import 'package:flutter/material.dart';

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
              //--------- Time Display --------
              new Padding(
                padding: const EdgeInsets.only(top: 15.0),
                child: new Text(
                  '17:34',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.black,
                    fontFamily: 'BebasNeue',
                    fontSize: 150.0,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 10.0,
                  ),
                ),
              ),

              //--------- Dial --------
              new RandomColorBlock(
                width: double.INFINITY,
                child: new Padding(
                  padding: const EdgeInsets.only(left: 45.0, right: 45.0),
                  child: new AspectRatio(
                    aspectRatio: 1.0,
                    child: new RandomColorBlock(
                      width: double.INFINITY,
                    ),
                  ),
                ),
              ),

              //------- Expanded Area For Extra Space -------
              new Expanded(child: new Container()),

              //------- Controls -----
              new RandomColorBlock(
                width: double.INFINITY,
                height: 150.0,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
