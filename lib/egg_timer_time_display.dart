import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class EggTimerTimeDisplay extends StatefulWidget {

  final displayMode;
  final selectionTime;
  final countdownTime;

  EggTimerTimeDisplay({
    this.displayMode = TimeDisplayMode.selection,
    this.selectionTime = 0,
    this.countdownTime = 0,
  });

  @override
  _EggTimerTimeDisplayState createState() => new _EggTimerTimeDisplayState();
}

class _EggTimerTimeDisplayState extends State<EggTimerTimeDisplay> with TickerProviderStateMixin {

  final DateFormat selectionTimeFormat = new DateFormat('mm');
  final DateFormat countdownTimeFormat = new DateFormat('mm:ss');

  AnimationController transitionToCountdown;

  @override
  void initState() {
    super.initState();
    transitionToCountdown = new AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    )
    ..addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    transitionToCountdown.dispose();
    super.dispose();
  }

  get formattedSelectionTime {
    DateTime dateTime = new DateTime(new DateTime.now().year, 0, 0, 0, 0, widget.selectionTime);
    return selectionTimeFormat.format(dateTime);
  }

  get formattedCountdownTime {
    DateTime dateTime = new DateTime(new DateTime.now().year, 0, 0, 0, 0, widget.countdownTime);
    return countdownTimeFormat.format(dateTime);
  }

  @override
  Widget build(BuildContext context) {

    if (widget.displayMode == TimeDisplayMode.selection) {
      transitionToCountdown.reverse();
    } else {
      transitionToCountdown.forward();
    }

    return new Padding(
      padding: const EdgeInsets.only(top: 15.0),
      child: new Stack(
        alignment: Alignment.center,
        children: [
          new Opacity(
            opacity: 1.0 - transitionToCountdown.value,
            child: new Text(
              '$formattedSelectionTime',
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
          new Transform(
            transform: new Matrix4.translationValues(
                0.0,
                -175.0 * (1.0 - transitionToCountdown.value),
                0.0
            ),
            child: new Text(
              '$formattedCountdownTime',
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
        ],
      ),
    );
  }
}

enum TimeDisplayMode {
  selection,
  countdown,
}