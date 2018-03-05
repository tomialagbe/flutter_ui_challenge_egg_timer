import 'package:egg_timer/countdown_timer.dart';
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

  static const MAX_TIME = const Duration(minutes: 15);

  CountdownTimer timer;

  @override
  void initState() {
    timer = new CountdownTimer(
      onTimerUpdate: _onTimerUpdate,
      onTimerAlarm: _onAlarm,
    );
  }

  _onTimerUpdate(newTime) {
    setState(() {});
  }

  _onAlarm() {
    setState(() {});
  }

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
              minuteCount: MAX_TIME.inMinutes,
              canSelectTime: timer.state == CountdownTimerState.ready,
              timerTime: timer.time,
              onDialPositionSelected: (selectedDialPosition) {
                setState(() {
                  final selectedTime = (selectedDialPosition * MAX_TIME.inSeconds).round();
                  timer.selectTime(selectedTime);
                  timer.resume();
                });
              },
            ),

            //------- Expanded Area For Extra Space -------
            new Expanded(child: new Container()),

            //------- Controls -----
            new EggTimerControls(
              displayMode: () {
                switch (timer.state) {
                  case CountdownTimerState.ready:
                    return ControlsDisplayMode.hidden;
                  case CountdownTimerState.running:
                    return ControlsDisplayMode.pauseVisible;
                  case CountdownTimerState.paused:
                    return ControlsDisplayMode.allVisible;
                }
              }(),
              onPause: () {
                timer.pause();
              },
              onResume: () {
                timer.resume();
              },
              onRestart: () {
                timer.restart();
              },
              onReset: () {
                timer.reset();
              }
            ),
          ],
        ),
      ),
    );
  }
}
