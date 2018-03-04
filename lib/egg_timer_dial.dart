import 'package:egg_timer/countdown_timer.dart';
import 'package:egg_timer/time_dial.dart';
import 'package:flutter/material.dart';

class EggTimerDial extends StatefulWidget {

  final int ticksPerMinute;
  final int maxTimeInSeconds;
  final CountdownTimerState timerState;
  final int timeInSeconds;
  final Function onDialTurning;
  final Function(int) onDialTurnToTime;
  final Function(int) onDialReleasedAtTime;

  EggTimerDial({
    this.ticksPerMinute,
    this.maxTimeInSeconds,
    this.timerState,
    this.timeInSeconds,
    this.onDialTurning,
    this.onDialTurnToTime,
    this.onDialReleasedAtTime,
  });

  @override
  _EggTimerDialState createState() => new _EggTimerDialState();
}

class _EggTimerDialState extends State<EggTimerDial> with TickerProviderStateMixin {

  static const double RESET_SPEED_PERCENT_PER_SECOND = 3.0;

  //-------- DIAL AND COUNTDOWN -------
  double dialPositionAsPercent = 0.0;
  bool isDragging = false;
  int userSelectedTime = 0;
  AnimationController resetDialAnimationController;
  Animation<double> resetDialAnimation;

  @override
  void initState() {
    super.initState();

    resetDialAnimationController = new AnimationController(duration: const Duration(milliseconds: 250), vsync: this)
      ..addListener(() {
        setState(() {});
      });
  }

  @override
  void dispose() {
    resetDialAnimationController.dispose();
    super.dispose();
  }

  _onTimerUpdate() {
    setState(() {
      print('Tick Render Update. Time: ${widget.timeInSeconds}');

      final newDialPercent = widget.timeInSeconds / widget.maxTimeInSeconds;
      if (!isDragging) {
        resetDialAnimationController.duration = new Duration(
            milliseconds: (dialPositionAsPercent / RESET_SPEED_PERCENT_PER_SECOND * 1000).round()
        );
        resetDialAnimationController.value = 0.0;
        resetDialAnimation = new Tween(begin: dialPositionAsPercent, end: newDialPercent)
            .animate(resetDialAnimationController)
          ..addListener(() {

          });
        resetDialAnimationController.forward();
      } else {
        if (null != resetDialAnimation) {
          resetDialAnimationController.stop();
          resetDialAnimation = null;
        }
      }
      dialPositionAsPercent = newDialPercent;
    });
  }

  _onDialTurnStart(double newDialPositionAsPercent) {
    if (widget.timerState != CountdownTimerState.ready) {
      return;
    }

    setState(() {
      isDragging = true;
      dialPositionAsPercent = newDialPositionAsPercent;
    });
  }

  _onDialTurnUpdate(double newDialPositionAsPercent) {
    if (widget.timerState != CountdownTimerState.ready) {
      return;
    }

    setState(() {
      print('Updating turn to percent: $newDialPositionAsPercent');
      dialPositionAsPercent = newDialPositionAsPercent;

      // Round to the nearest minute before setting the countdown timer.
      final selectedTime = (widget.maxTimeInSeconds * dialPositionAsPercent).round();
//      final selectedTimeRoundedToMinutes = (widget.maxTimeInSeconds * dialPositionAsPercent / 60.0).round();
//      final selectedTimeAsSeconds = (selectedTimeRoundedToMinutes * 60).round();
      userSelectedTime = selectedTime;

      widget.onDialTurnToTime(userSelectedTime);
//      countdownTimer.time = (selectedTimeRoundedToMinutes * 60).round();
    });
  }

  _onDialTurnEnd() {
    if (widget.timerState != CountdownTimerState.ready) {
      return;
    }

    setState(() {
      isDragging = false;

      widget.onDialReleasedAtTime(userSelectedTime);
//      // Round the time to the nearest minute (this is a design feature of the clock).
//      countdownTimer.time = (countdownTimer.time / 60).round() * 60;
//
//      // Start the clock.
//      countdownTimer.resume();
    });
  }

  @override
  Widget build(BuildContext context) {
    _onTimerUpdate();

    return new DraggableTimeDial(
      onDialTurnStart: _onDialTurnStart,
      onDialTurnUpdate: _onDialTurnUpdate,
      onDialTurnEnd: _onDialTurnEnd,
      tickCount: (widget.maxTimeInSeconds / 60).round() * widget.ticksPerMinute,
      dialPositionAsPercent: null != resetDialAnimation
          ? resetDialAnimation.value
          : dialPositionAsPercent,
    );
  }
}
