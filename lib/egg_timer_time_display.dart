import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class EggTimerTimeDisplay extends StatelessWidget {

  final DateFormat selectionTimeFormat = new DateFormat('mm');
  final DateFormat countdownTimeFormat = new DateFormat('mm:ss');

  final displayMode;
  final selectionTime;
  final countdownTime;

  EggTimerTimeDisplay({
    this.displayMode = TimeDisplayMode.selection,
    this.selectionTime = 0,
    this.countdownTime = 0,
  });

  get formattedSelectionTime {
    DateTime dateTime = new DateTime(new DateTime.now().year, 0, 0, 0, 0, selectionTime);
    return selectionTimeFormat.format(dateTime);
  }

  get formattedCountdownTime {
    DateTime dateTime = new DateTime(new DateTime.now().year, 0, 0, 0, 0, countdownTime);
    return countdownTimeFormat.format(dateTime);
  }

  @override
  Widget build(BuildContext context) {
    return new Padding(
      padding: const EdgeInsets.only(top: 15.0),
      child: new Stack(
        alignment: Alignment.center,
        children: [
          new Opacity(
            opacity: displayMode == TimeDisplayMode.selection
              ? 1.0
              : 0.0,
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
            transform: displayMode == TimeDisplayMode.countdown
              ? new Matrix4.identity()
              : new Matrix4.translationValues(0.0, -175.0, 0.0),
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