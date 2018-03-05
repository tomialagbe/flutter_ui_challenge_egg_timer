import 'package:egg_timer/egg_timer_button.dart';
import 'package:flutter/material.dart';

class EggTimerControls extends StatefulWidget {

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
  _EggTimerControlsState createState() => new _EggTimerControlsState();
}

class _EggTimerControlsState extends State<EggTimerControls> with TickerProviderStateMixin {

  AnimationController pauseResumeTransition;
  AnimationController resetRestartTransition;


  @override
  void initState() {
    super.initState();

    pauseResumeTransition = new AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    )
    ..addListener(() => setState(() {}));

    resetRestartTransition = new AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    )
    ..addListener(() => setState(() {}));
  }


  @override
  void dispose() {
    pauseResumeTransition.dispose();
    resetRestartTransition.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    switch (widget.displayMode) {
      case ControlsDisplayMode.hidden:
        pauseResumeTransition.reverse();
        resetRestartTransition.reverse();
        break;
      case ControlsDisplayMode.pauseVisible:
        pauseResumeTransition.forward();
        resetRestartTransition.reverse();
        break;
      case ControlsDisplayMode.allVisible:
        pauseResumeTransition.forward();
        resetRestartTransition.forward();
        break;
    }

    return new Column(
      children: [
        new Opacity(
          opacity: resetRestartTransition.value,
          child: new Row(
            children: [
              new EggTimerButton(
                icon: Icons.refresh,
                text: 'RESTART',
                onPressed: widget.onRestart,
              ),
              new Expanded(child: new Container()),
              new EggTimerButton(
                icon: Icons.arrow_back,
                text: 'RESET',
                onPressed: widget.onReset,
              ),
            ],
          ),
        ),
        new Transform(
          transform: new Matrix4.translationValues(
              0.0,
              100.0 * (1.0 - pauseResumeTransition.value),
              0.0,
          ),
          child: new EggTimerButton(
            icon: Icons.pause,
            text: widget.displayMode == ControlsDisplayMode.pauseVisible
                ? 'PAUSE'
                : 'RESUME',
            backgroundColor: Colors.white,
            onPressed: widget.displayMode == ControlsDisplayMode.pauseVisible
                ? widget.onPause
                : widget.onResume,
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