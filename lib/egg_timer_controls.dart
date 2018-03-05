import 'package:egg_timer/egg_timer_button.dart';
import 'package:flutter/material.dart';

class EggTimerControls extends StatelessWidget {

  final displayMode;
  final onRestart;
  final onReset;
  final onPause;
  final onResume;

  EggTimerControls({
    this.displayMode = ControlsDisplayMode.hidden,
    this.onRestart,
    this.onReset,
    this.onPause,
    this.onResume
  });

  @override
  Widget build(BuildContext context) {
    return new Column(
      children: [
        new Opacity(
          opacity: displayMode == ControlsDisplayMode.allVisible
            ? 1.0
            : 0.0,
          child: new Row(
            children: [
              new EggTimerButton(
                icon: Icons.refresh,
                text: 'RESTART',
                onPressed: onRestart,
              ),
              new Expanded(child: new Container()),
              new EggTimerButton(
                icon: Icons.arrow_back,
                text: 'RESET',
                onPressed: onReset,
              ),
            ],
          ),
        ),
        new Transform(
          transform: displayMode == ControlsDisplayMode.hidden
            ? new Matrix4.translationValues(0.0, 100.0, 0.0)
            : new Matrix4.identity(),
          child: new EggTimerButton(
            icon: Icons.pause,
            text: displayMode == ControlsDisplayMode.pauseVisible
                ? 'PAUSE'
                : 'RESUME',
            backgroundColor: Colors.white,
            onPressed: displayMode == ControlsDisplayMode.pauseVisible
                ? onPause
                : onResume,
          ),
        ),
      ],
    );
  }
}

enum ControlsDisplayMode {
  hidden,
  pauseVisible,
  allVisible,
}