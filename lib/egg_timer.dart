import 'package:egg_timer/countdown_timer.dart';
import 'package:egg_timer/time_dial.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart' hide TextDirection;
import 'package:vector_math/vector_math_64.dart' as vectormath;

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

  static const double RESET_SPEED_PERCENT_PER_SECOND = 3.0;

  CountdownTimer countdownTimer;

  //------- TIME DISPLAY --------
  final DateFormat draggingMinutesFormat = new DateFormat('mm');
  String draggingMinutes = '00';

  final DateFormat countdownFormat = new DateFormat('mm:ss');
  String countdownTime = '00:00';

  AnimationController textTransitionAnimationController;

  //-------- DIAL AND COUNTDOWN -------
  double dialPositionAsPercent;
  bool isDragging;
  AnimationController resetDialAnimationController;
  Animation<double> resetDialAnimation;

  //-------- RESET AND RESTART BUTTON -----
  AnimationController resetAndRestartVisibleAnimationController;

  //-------- RESUME AND PAUSE BUTTON ------
  AnimationController slideInResumeAndPauseButtonAnimationController;

  _EggTimerState({
    this.dialPositionAsPercent = 0.0,
  }) {
    textTransitionAnimationController = new AnimationController(duration: const Duration(milliseconds: 250), vsync: this)
      ..addListener(() {
        setState(() {});
      });

    resetDialAnimationController = new AnimationController(duration: const Duration(milliseconds: 250), vsync: this)
      ..addListener(() {
        setState(() {});
      });

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
  void initState() {
    super.initState();

    countdownTimer = new CountdownTimer(
      onTimerUpdate: _onTimerUpdate,
      maxTimeInSeconds: widget.maxTimerAmount.inSeconds,
    );
  }

  @override
  void dispose() {
    textTransitionAnimationController.dispose();
    resetAndRestartVisibleAnimationController.dispose();
    slideInResumeAndPauseButtonAnimationController.dispose();
    super.dispose();
  }

  _onTimerUpdate() {
    setState(() {
      print('Tick Render Update. Time: ${countdownTimer.time}');

      final newDialPercent = countdownTimer.time / widget.maxTimerAmount.inSeconds;
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

      // TODO: move "alarm" to an event instead of simply checking for zero
      if (countdownTimer.time == 0) {
        // The alarm is done.
        _updateDraggingMinute();
        _transitionToTimeSelection();
      }

      switch (countdownTimer.state) {
        case CountdownTimerState.ready:
          _updateDraggingMinute();

          _hideResetAndRestartButtons();
          _slideOutResumeAndPauseButton();
          break;
        case CountdownTimerState.running:
          _updateCountdownTime();

          _hideResetAndRestartButtons();
          break;
        case CountdownTimerState.paused:
          _updateCountdownTime();

          _showResetAndRestartButtons();
          break;
      }
    });
  }

  _onDialTurnStart(double newDialPositionAsPercent) {
    if (countdownTimer.state != CountdownTimerState.ready) {
      return;
    }

    setState(() {
      isDragging = true;
      dialPositionAsPercent = newDialPositionAsPercent;
    });
  }

  _onDialTurnUpdate(double newDialPositionAsPercent) {
    if (countdownTimer.state != CountdownTimerState.ready) {
      return;
    }

    setState(() {
      print('Updating turn to percent: $newDialPositionAsPercent');
      dialPositionAsPercent = newDialPositionAsPercent;

      // Round to the nearest minute before setting the countdown timer.
      double selectedTimeRoundedToMinutes = (countdownTimer.maxTimeInSeconds * dialPositionAsPercent / 60.0);//.round();

      countdownTimer.time = (selectedTimeRoundedToMinutes * 60).round();
    });
  }

  _onDialTurnEnd() {
    if (countdownTimer.state != CountdownTimerState.ready) {
      return;
    }

    setState(() {
      isDragging = false;

      // Round the time to the nearest minute (this is a design feature of the clock).
      countdownTimer.time = (countdownTimer.time / 60).round() * 60;

      // Start the clock.
      countdownTimer.resume();

      // TODO: get rid of what's below
      setState(() {
        _updateCountdownTime();
        _transitionToCountdown();
        _slideInResumeAndPauseButton();
      });
    });
  }

  _transitionToTimeSelection() {
    textTransitionAnimationController.reverse();
  }

  _transitionToCountdown() {
    textTransitionAnimationController.forward();
  }

  _updateDraggingMinute() {
    setState(() {
      int selectedTimeRoundedToMinutes = new Duration(minutes: (widget.maxTimerAmount.inSeconds * dialPositionAsPercent / 60.0).round()).inMinutes;
      DateTime dateTime = new DateTime(new DateTime.now().year, 0, 0, 0, selectedTimeRoundedToMinutes);
      draggingMinutes = draggingMinutesFormat.format(dateTime);
    });
  }

  _updateCountdownTime() {
    setState(() {
      Duration countdown = new Duration(
          seconds: countdownTimer.time
      );
      DateTime dateTime = new DateTime(new DateTime.now().year, 0, 0, 0, 0, countdown.inSeconds);
      countdownTime = countdownFormat.format(dateTime);
    });
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
    return new MaterialApp(
      theme: new ThemeData(
        fontFamily: 'BebasNeue',
      ),
      title: 'Kitchen Timer',
      home: new Scaffold(
        body: new Container(
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
                new Padding(
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
                ),

                //------------ DIAL --------------
                new DraggableTimeDial(
                  onDialTurnStart: _onDialTurnStart,
                  onDialTurnUpdate: _onDialTurnUpdate,
                  onDialTurnEnd: _onDialTurnEnd,
                  tickCount: (countdownTimer.maxTimeInSeconds / 60).round() * widget.ticksPerMinute,
                  dialPositionAsPercent: null != resetDialAnimation
                      ? resetDialAnimation.value
                      : dialPositionAsPercent,
                ),

                new Expanded(
                  child: new Container(),
                ),

                //----------- RESET AND RESTART ROW --------
                new Opacity(
                  opacity: null == resetAndRestartVisibleAnimationController
                      ? 0.0
                      : resetAndRestartVisibleAnimationController.value,
                  child: new Row(
                    children: [
                      new IconWithTextButton(
                        icon: Icons.refresh,
                        text: 'RESTART',
                        padding: const EdgeInsets.only(left: 25.0, right: 25.0, top: 25.0, bottom: 25.0),
                        onPressed: CountdownTimerState.paused == countdownTimer.state
                            ? countdownTimer.restart
                            : null,
                      ),
                      new Expanded(
                        child: new Container(),
                      ),
                      new IconWithTextButton(
                        icon: Icons.arrow_back,
                        text: 'RESET',
                        padding: const EdgeInsets.only(left: 25.0, right: 25.0, top: 25.0, bottom: 25.0),
                        onPressed: CountdownTimerState.paused == countdownTimer.state
                          ? countdownTimer.reset
                          : null,
                      ),
                    ],
                  ),
                ),
                //---------- PAUSE AND RESUME BUTTON ---------
                new Transform(
                  transform: new Matrix4.translation(
                      slideInResumeAndPauseButtonAnimationController == null
                      ? new vectormath.Vector3(0.0, 300.0, 0.0)
                      : new vectormath.Vector3(0.0, 300.0 * (1.0 - slideInResumeAndPauseButtonAnimationController.value), 0.0)),
                  child: new IconWithTextButton(
                    icon: CountdownTimerState.running == countdownTimer.state
                        ? Icons.pause
                        : Icons.play_arrow,
                    text: CountdownTimerState.running == countdownTimer.state
                        ? 'PAUSE'
                        : 'RESUME',
                    color: Colors.white,
                    onPressed: CountdownTimerState.running == countdownTimer.state
                        ? countdownTimer.pause
                        : countdownTimer.resume,
                  ),
                ),
              ]
            ),
          ),
        ),
      ),
    );
  }
}

class IconWithTextButton extends StatelessWidget {

  final IconData icon;
  final String text;
  final Color color;
  final EdgeInsets padding;
  final Function onPressed;

  IconWithTextButton({
    this.icon,
    this.text = '',
    this.color = Colors.transparent,
    this.padding = const EdgeInsets.only(top: 25.0, bottom: 25.0),
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return new FlatButton(
      color: color,
      splashColor: const Color(0x22000000),
      onPressed: onPressed,
      child: new Padding(
        padding: padding,
        child: new Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            new Padding(
              padding: const EdgeInsets.only(right: 3.0),
              child: new Icon(
                icon,
                color: Colors.black,
              ),
            ),
            new Text(
              text,
              style: new TextStyle(
                color: Colors.black,
                fontSize: 20.0,
                fontWeight: FontWeight.bold,
                letterSpacing: 3.0,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
