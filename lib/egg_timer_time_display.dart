import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:vector_math/vector_math_64.dart' as vectormath;

class EggTimerTimeDisplay extends StatefulWidget {

  final selectionTimeInMinutes;
  final countdownTimeInSeconds;
  final timeDisplayMode;

  EggTimerTimeDisplay({
    selectionTimeInSeconds,
    this.countdownTimeInSeconds,
    this.timeDisplayMode,
  }) : selectionTimeInMinutes = new Duration(seconds: selectionTimeInSeconds).inMinutes;

  @override
  _EggTimerTimeDisplayState createState() => new _EggTimerTimeDisplayState();
}

enum TimeDisplayMode {
  notRunning,
  running,
}

class _EggTimerTimeDisplayState extends State<EggTimerTimeDisplay> with TickerProviderStateMixin {

  final DateFormat draggingMinutesFormat = new DateFormat('mm');
  String draggingMinutes = '00';

  final DateFormat countdownFormat = new DateFormat('mm:ss');
  String countdownTime = '00:00';

  AnimationController textTransitionAnimationController;

  _updateDraggingMinute() {
    setState(() {
      DateTime dateTime = new DateTime(new DateTime.now().year, 0, 0, 0, widget.selectionTimeInMinutes);
      draggingMinutes = draggingMinutesFormat.format(dateTime);
    });
  }

  _updateCountdownTime() {
    setState(() {
      Duration countdown = new Duration(
        seconds: widget.countdownTimeInSeconds,
      );
      DateTime dateTime = new DateTime(new DateTime.now().year, 0, 0, 0, 0, countdown.inSeconds);
      countdownTime = countdownFormat.format(dateTime);
    });
  }

  @override
  void initState() {
    super.initState();

    textTransitionAnimationController = new AnimationController(
        duration: const Duration(milliseconds: 250),
        vsync: this
    )
      ..addListener(() {
        setState(() {});
      });
  }

  @override
  void dispose() {
    textTransitionAnimationController.dispose();

    super.dispose();
  }

  _transitionToTimeSelection() {
    textTransitionAnimationController.reverse();
  }

  _transitionToCountdown() {
    textTransitionAnimationController.forward();
  }

  @override
  Widget build(BuildContext context) {
    _updateDraggingMinute();
    _updateCountdownTime();

    switch (widget.timeDisplayMode) {
      case TimeDisplayMode.notRunning:
        _transitionToTimeSelection();
        break;
      case TimeDisplayMode.running:
        _transitionToCountdown();
        break;
    }

    return new Padding(
      padding: const EdgeInsets.only(top: 15.0),
      child: new Stack(
        alignment: Alignment.center,
        children: [
          new Opacity(
            opacity: null == textTransitionAnimationController ? 1.0 : 1.0 - textTransitionAnimationController.value,
            child: new Text(
              draggingMinutes,
              style: new TextStyle(
                color: Colors.black,
                fontSize: 150.0,
                fontWeight: FontWeight.bold,
                letterSpacing: 10.0,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          new Transform(
            transform: new Matrix4.translation(new vectormath.Vector3(0.0, -300 * (1.0 - textTransitionAnimationController.value), 0.0)),
            child: new Opacity(
              opacity: null == textTransitionAnimationController ? 0.0 : textTransitionAnimationController.value,
              child: new Text(
                countdownTime,
                style: new TextStyle(
                  color: Colors.black,
                  fontSize: 150.0,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 10.0,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          )
        ],
      ),
    );
  }
}