import 'package:egg_timer/countdown_timer.dart';
import 'package:egg_timer/icon_with_text_button.dart';
import 'package:flutter/material.dart';
import 'package:vector_math/vector_math_64.dart' as vectormath;

class EggTimerControls extends StatefulWidget {

  final CountdownTimerState mode;
  final Function onRestart;
  final Function onReset;
  final Function onPause;
  final Function onResume;

  EggTimerControls({this.mode, this.onRestart, this.onReset, this.onPause, this.onResume});

  @override
  _EggTimerControlsState createState() => new _EggTimerControlsState();
}

//enum EggTimerControlsMode {
//  ready,
//  running,
//  paused,
//}

class _EggTimerControlsState extends State<EggTimerControls> with TickerProviderStateMixin {

  //-------- RESET AND RESTART BUTTON -----
  AnimationController resetAndRestartVisibleAnimationController;

  //-------- RESUME AND PAUSE BUTTON ------
  AnimationController slideInResumeAndPauseButtonAnimationController;

  @override
  void initState() {
    super.initState();

    resetAndRestartVisibleAnimationController = new AnimationController(duration: const Duration(milliseconds: 250), vsync: this)
      ..addListener(() {
        setState(() {});
      });

    slideInResumeAndPauseButtonAnimationController = new AnimationController(duration: const Duration(milliseconds: 250), vsync: this)
      ..addListener(() {
        setState(() {});
      });
  }

  @override
  void dispose() {
    resetAndRestartVisibleAnimationController.dispose();
    slideInResumeAndPauseButtonAnimationController.dispose();

    super.dispose();
  }

  _showResetAndRestartButtons() {
    resetAndRestartVisibleAnimationController.forward();
  }

  _hideResetAndRestartButtons() {
    resetAndRestartVisibleAnimationController.reverse();
  }

  _slideInResumeAndPauseButton() {
    slideInResumeAndPauseButtonAnimationController.forward();
  }

  _slideOutResumeAndPauseButton() {
    slideInResumeAndPauseButtonAnimationController.reverse();
  }

  @override
  Widget build(BuildContext context) {
    switch (widget.mode) {
      case CountdownTimerState.ready:
        _slideOutResumeAndPauseButton();
        _hideResetAndRestartButtons();
        break;
      case CountdownTimerState.running:
        _slideInResumeAndPauseButton();
        _hideResetAndRestartButtons();
        break;
      case CountdownTimerState.paused:
        _slideInResumeAndPauseButton();
        _showResetAndRestartButtons();
        break;
    }

    return new Column(
        children: [
          new Opacity(
            opacity: null == resetAndRestartVisibleAnimationController
                ? 0.0
                : resetAndRestartVisibleAnimationController.value,
            child: new Row(
              children: [
                new IconWithTextButton(
                  icon: Icons.refresh,
                  text: 'RESTART',
                  onPressed: widget.mode == CountdownTimerState.paused
                      ? widget.onRestart
                      : null,
                ),
                new Expanded(
                  child: new Container(),
                ),
                new IconWithTextButton(
                  icon: Icons.arrow_back,
                  text: 'RESET',
                  onPressed: widget.mode == CountdownTimerState.paused
                      ? widget.onReset
                      : null,
                ),
              ],
            ),
          ),
          new Transform(
            transform: new Matrix4.translation(
                slideInResumeAndPauseButtonAnimationController == null
                    ? new vectormath.Vector3(0.0, 300.0, 0.0)
                    : new vectormath.Vector3(0.0, 300.0 * (1.0 - slideInResumeAndPauseButtonAnimationController.value), 0.0)),
            child: new IconWithTextButton(
              icon: widget.mode == CountdownTimerState.running
                  ? Icons.pause
                  : Icons.play_arrow,
              text: widget.mode == CountdownTimerState.running
                  ? 'PAUSE'
                  : 'RESUME',
              color: Colors.white,
              onPressed: widget.mode == CountdownTimerState.running
                  ? widget.onPause
                  : widget.onResume,
            ),
          ),
        ]
    );
  }
}
