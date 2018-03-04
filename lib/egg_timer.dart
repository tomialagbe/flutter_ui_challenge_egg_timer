import 'package:egg_timer/countdown_timer.dart';
import 'package:egg_timer/egg_timer_controls.dart';
import 'package:egg_timer/egg_timer_dial.dart';
import 'package:egg_timer/egg_timer_time_display.dart';
import 'package:flutter/material.dart';

class EggTimer extends StatefulWidget {

  final Duration maxTimerAmount;
  final int ticksPerMinute;

  EggTimer({
    this.maxTimerAmount = const Duration(minutes: 60),
    this.ticksPerMinute = 1,
  });

  @override
  _EggTimerState createState() => new _EggTimerState();
}

class _EggTimerState extends State<EggTimer> with TickerProviderStateMixin {

  CountdownTimer countdownTimer;

  @override
  void initState() {
    super.initState();

    countdownTimer = new CountdownTimer(
      onTimerUpdate: () => setState(() { }),
      maxTimeInSeconds: widget.maxTimerAmount.inSeconds,
    );
  }

  @override
  Widget build(BuildContext context) {
    return new Container(
      decoration: new BoxDecoration(
        gradient: new LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [const Color(0xFFF5F5F5), const Color(0xFFF0F0F0)],
        ),
      ),
      child: new Center(
        child: new Column(
          children: [
            //--------- SELECTION AND TIMER TEXT DISPLAY -------
            new EggTimerTimeDisplay(
              timeDisplayMode: countdownTimer.state != CountdownTimerState.ready
                ? TimeDisplayMode.running
                : TimeDisplayMode.notRunning,
              selectionTimeInSeconds: countdownTimer.currentCountdownStartTime,
              countdownTimeInSeconds: countdownTimer.time,
            ),

            //------------ DIAL --------------
            new EggTimerDial(
              ticksPerMinute: widget.ticksPerMinute,
              maxTimeInSeconds: countdownTimer.maxTimeInSeconds,
              timerState: countdownTimer.state,
              timeInSeconds: countdownTimer.time,
              onDialTurning: () {

              },
              onDialTurnToTime: (newTime) {
                countdownTimer.time = newTime;
              },
              onDialReleasedAtTime: (newTime) {
                // Round the time to the nearest minute (this is a design feature of the clock).
                countdownTimer.time = newTime;

                // Start the clock.
                countdownTimer.resume();
              },
            ),

            new Expanded(
              child: new Container(),
            ),

            //----------- RESET, RESTART, and PAUSE/RESUME --------
            new EggTimerControls(
              mode: countdownTimer.state,
              onRestart: () {
                countdownTimer.restart();
              },
              onReset: () {
                countdownTimer.reset();
              },
              onPause: () {
                countdownTimer.pause();
              },
              onResume: () {
                countdownTimer.resume();
              },
            ),
          ],
        ),
      ),
    );
  }
}
