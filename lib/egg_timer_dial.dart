import 'package:egg_timer/countdown_timer.dart';
import 'package:egg_timer/time_dial.dart';
import 'package:flutter/material.dart';

class EggTimerDial extends StatefulWidget {

  final int ticksPerMinute;
  final int maxTimeInSeconds;
  final CountdownTimerState timerState;
  final int timeInSeconds;
  final Function() onDialTurning;
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
  CountdownTimerState timerState = CountdownTimerState.ready;
  bool isDragging = false;
  int userSelectedTime = 0;
  AnimationController resetDialAnimationController;
  Animation<double> resetDialAnimation;

  @override
  void initState() {
    super.initState();

    timerState = widget.timerState;

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

  _updateDialDisplay() {
    final oldDialPercent = dialPositionAsPercent;
    dialPositionAsPercent = widget.timeInSeconds / widget.maxTimeInSeconds;

    final oldTimerState = timerState;
    timerState = widget.timerState;

    // If the countdown timer was just reset then we want to animate the dial
    // back to zero.
    final timerJustReset = oldTimerState != CountdownTimerState.ready
        && timerState == CountdownTimerState.ready;
    if (timerJustReset) {
      _resetDialWithAnimation(from: oldDialPercent);
    }
  }

  _resetDialWithAnimation({from}) {
    resetDialAnimation =
    new Tween(begin: from, end: 0.0)
        .animate(resetDialAnimationController)
      ..addStatusListener((AnimationStatus status) {
        if (status == AnimationStatus.completed) {
          resetDialAnimation = null;
        }
      });

    resetDialAnimationController.duration = new Duration(
        milliseconds: (from /
            RESET_SPEED_PERCENT_PER_SECOND * 1000).round()
    );
    resetDialAnimationController.value = 0.0;
    resetDialAnimationController.forward();
  }

  _onDialTurnStart(double newDialPositionAsPercent) {
    // No dragging when timer is running or paused.
    if (widget.timerState != CountdownTimerState.ready) {
      return;
    }

    setState(() {
      isDragging = true;
      dialPositionAsPercent = newDialPositionAsPercent;

      // Notify our listener that the user started turning the dial.
      widget.onDialTurning();
    });
  }

  _onDialTurnUpdate(double newDialPositionAsPercent) {
    // No dragging when timer is running or paused.
    if (widget.timerState != CountdownTimerState.ready) {
      return;
    }

    setState(() {
      dialPositionAsPercent = newDialPositionAsPercent;
      userSelectedTime = (widget.maxTimeInSeconds * dialPositionAsPercent).round();

      // Notify our listener that the user has turned the dial.
      widget.onDialTurnToTime(userSelectedTime);
    });
  }

  _onDialTurnEnd() {
    // No dragging when timer is running or paused.
    if (widget.timerState != CountdownTimerState.ready) {
      return;
    }

    setState(() {
      isDragging = false;

      // Notify our listener that the user has finished turning the dial.
      widget.onDialReleasedAtTime(userSelectedTime);
    });
  }

  @override
  Widget build(BuildContext context) {
    _updateDialDisplay();

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
