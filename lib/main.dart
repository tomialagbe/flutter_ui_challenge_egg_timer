import 'package:egg_timer/egg_timer_button.dart';
import 'package:egg_timer/egg_timer_controls.dart';
import 'package:egg_timer/egg_timer_time_display.dart';
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
              new EggTimerTimeDisplay(

              ),

              //--------- Dial --------
              new Padding(
                padding: const EdgeInsets.only(left: 45.0, right: 45.0),
                child: new AspectRatio(
                  aspectRatio: 1.0,
                  child: new RandomColorBlock(
                    width: double.INFINITY,
                  ),
                ),
              ),

              //------- Expanded Area For Extra Space -------
              new Expanded(child: new Container()),

              //------- Controls -----
              new EggTimerControls(

              ),
            ],
          ),
        ),
      ),
    );
  }
}
