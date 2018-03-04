import 'package:egg_timer/egg_timer_controls.dart';
import 'package:egg_timer/egg_timer_dial.dart';
import 'package:egg_timer/egg_timer_time_display.dart';
import 'package:egg_timer/ui_constants.dart';
import 'package:flutter/material.dart';

class EggTimer extends StatefulWidget {
  @override
  _EggTimerState createState() => new _EggTimerState();
}

class _EggTimerState extends State<EggTimer> {
  @override
  Widget build(BuildContext context) {
    return new Container(
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
            //--------- Time Display --------
            new EggTimerTimeDisplay(

            ),

            //--------- Dial --------
            new EggTimerDial(

            ),

            //------- Expanded Area For Extra Space -------
            new Expanded(child: new Container()),

            //------- Controls -----
            new EggTimerControls(

            ),
          ],
        ),
      ),
    );
  }
}
