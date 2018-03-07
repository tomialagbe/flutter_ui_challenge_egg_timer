import 'package:egg_timer/egg_timer_button.dart';
import 'package:egg_timer/egg_timer_controls.dart';
import 'package:egg_timer/egg_timer_dial.dart';
import 'package:egg_timer/egg_timer_time_display.dart';
import 'package:flutter/material.dart';
import 'package:fluttery/framing.dart';

final Color GRADIENT_TOP = const Color(0xFFF5F5F5);
final Color GRADIENT_BOTTOM = const Color(0xFFE8E8E8);

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
        body: new Container(
          decoration: new BoxDecoration(
            gradient: new LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [GRADIENT_TOP, GRADIENT_BOTTOM],
            ),
          ),
          child: new Center(
            child: new Column(
              children: [
                new EggTimerTimeDisplay(

                ),

                new EggTimerDial(

                ),

                new Expanded(child: new Container()),

                new EggTimerControls(

                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
