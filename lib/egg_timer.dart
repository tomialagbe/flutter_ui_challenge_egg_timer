import 'dart:async';
import 'dart:math';

import 'package:intl/intl.dart' hide TextDirection;
import 'package:flutter/material.dart';
import 'package:meta/meta.dart';
import 'package:vector_math/vector_math_64.dart' as vectormath;

class EggTimer extends StatefulWidget {

  final Duration maxTimerAmount;
  final int ticksPerMinute;

  EggTimer({
    this.maxTimerAmount = const Duration(minutes: 15),
    this.ticksPerMinute = 1,
  });

  @override
  _EggTimerState createState() => new _EggTimerState();
}

class _EggTimerState extends State<EggTimer> with TickerProviderStateMixin {

  EggTimerState state = EggTimerState.READY;
  Duration timeToAlarm;

  //------- TIME DISPLAY --------
  final DateFormat draggingMinutesFormat = new DateFormat('mm');
  String draggingMinutes = '00';

  final DateFormat countdownFormat = new DateFormat('mm:ss');
  String countdownTime = '00:00';

  AnimationController textTransitionAnimationController;

  //-------- DIAL AND COUTNDOWN -------
  Stopwatch stopwatch;
  bool running = false;
  double dialPositionAsPercent;
  Offset startDragPosition;
  AnimationController resetDialAnimationController;

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
    stopwatch = new Stopwatch();
  }

  @override
  void dispose() {
    textTransitionAnimationController.dispose();
    resetAndRestartVisibleAnimationController.dispose();
    slideInResumeAndPauseButtonAnimationController.dispose();
    super.dispose();
  }

  _start() {
    setState(() {
      state = EggTimerState.RUNNING;

      running = true;
      stopwatch.start();
      _updateCountdownTime();
      _scheduleTick();

      _transitionToCountdown();
      _slideInResumeAndPauseButton();
    });
  }

  _toggle() {
    setState(() {
      if (running) {
        state = EggTimerState.PAUSED;
        running = false;
        stopwatch.stop();
        _showResetAndRestartButtons();
      } else {
        state = EggTimerState.RUNNING;
        running = true;
        stopwatch.start();
        _scheduleTick();
        _hideResetAndRestartButtons();
      }
    });
  }

  _reset() {
    setState(() {
      state = EggTimerState.READY;
      running = false;
      stopwatch.reset();
      stopwatch.stop();
      resetDialAnimationController.value = dialPositionAsPercent;
      resetDialAnimationController.reverse();
      dialPositionAsPercent = 0.0;
      _updateDraggingMinute();
      _transitionToTimeSelection();
      _hideResetAndRestartButtons();
      _slideOutResumeAndPauseButton();
    });
  }

  _restart() {
    setState(() {
      state = EggTimerState.RUNNING;
      running = true;
      stopwatch.reset();
      stopwatch.start();
      dialPositionAsPercent = timeToAlarm.inSeconds / widget.maxTimerAmount.inSeconds;
      _updateCountdownTime();
      _hideResetAndRestartButtons();
      _scheduleTick();
    });
  }

  _scheduleTick() {
    new Timer(new Duration(seconds: 1), _onTick);
  }

  _onTick() {
    if (running) {
      setState(() {
        dialPositionAsPercent =
            (timeToAlarm.inSeconds - stopwatch.elapsed.inSeconds) /
                widget.maxTimerAmount.inSeconds;

        if (stopwatch.elapsed.inSeconds >= timeToAlarm.inSeconds) {
          // The alarm is done.
          _doAlarm();
        }
      });

      _updateCountdownTime();

      _scheduleTick();
    }
  }

  _doAlarm() {
    setState(() {
      state = EggTimerState.READY;
      running = false;
      timeToAlarm = null;
      stopwatch.stop();
      stopwatch.reset();
      resetDialAnimationController.value = 0.0;
      slideInResumeAndPauseButtonAnimationController.value = 0.0;
      _updateDraggingMinute();
      _transitionToTimeSelection();
    });
  }

  _onDragStart(DragStartDetails details) {
    if (state != EggTimerState.READY) {
      return;
    }

    startDragPosition = details.globalPosition;
    _updateDraggingMinute();
  }

  _onDrag(DragUpdateDetails details) {
    if (state != EggTimerState.READY) {
      return;
    }

    print('Drag startY: ${startDragPosition.dy}, currY: ${details.globalPosition.dy}');
    double deltaPercent = details.delta.dy / 250.0;
    double newDialPercent = dialPositionAsPercent + deltaPercent;

    setState(() {
      dialPositionAsPercent = newDialPercent;
      dialPositionAsPercent = dialPositionAsPercent.clamp(0.0, 1.0);
      resetDialAnimationController.value = dialPositionAsPercent;
    });

    _updateDraggingMinute();
  }

  _onDragEnd(DragEndDetails details) {
    if (state != EggTimerState.READY) {
      return;
    }

    setState(() {
      startDragPosition = null;
      timeToAlarm = new Duration(minutes: (widget.maxTimerAmount.inSeconds * dialPositionAsPercent / 60.0).round());
      dialPositionAsPercent = timeToAlarm.inSeconds / widget.maxTimerAmount.inSeconds;
      _start();
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
//      draggingMinutes = '$selectedTimeRoundedToMinutes';
      DateTime dateTime = new DateTime(new DateTime.now().year, 0, 0, 0, selectedTimeRoundedToMinutes);
      draggingMinutes = draggingMinutesFormat.format(dateTime);
    });
  }

  _updateCountdownTime() {
    setState(() {
      if (running) {
        Duration countdown = new Duration(
            seconds: timeToAlarm.inSeconds - stopwatch.elapsed.inSeconds);
        DateTime dateTime = new DateTime(new DateTime.now().year, 0, 0, 0, 0, countdown.inSeconds);
        countdownTime = countdownFormat.format(dateTime);
      }
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
                new GestureDetector(
                  onVerticalDragStart: _onDragStart,
                  onVerticalDragUpdate: _onDrag,
                  onVerticalDragEnd: _onDragEnd,
                  child: new EggTimerDial(
                    totalTicks: widget.maxTimerAmount.inMinutes * widget.ticksPerMinute,
                    dialPositionAsPercent: EggTimerState.READY != state
                        ? dialPositionAsPercent
                        : null == resetDialAnimationController ? 0.0 : resetDialAnimationController.value,
                  ),
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
                        onPressed: EggTimerState.PAUSED == state
                            ? _restart
                            : null,
                      ),
                      new Expanded(
                        child: new Container(),
                      ),
                      new IconWithTextButton(
                        icon: Icons.arrow_back,
                        text: 'RESET',
                        padding: const EdgeInsets.only(left: 25.0, right: 25.0, top: 25.0, bottom: 25.0),
                        onPressed: EggTimerState.PAUSED == state
                          ? _reset
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
                    icon: running ? Icons.pause : Icons.play_arrow,
                    text: running ? 'PAUSE' : 'RESUME',
                    color: Colors.white,
                    onPressed: _toggle,
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

enum EggTimerState {
  READY,
  RUNNING,
  PAUSED
}

class EggTimerDial extends StatelessWidget {

  final int totalTicks;
  final double dialPositionAsPercent;

  EggTimerDial({
    @required this.totalTicks,
    @required this.dialPositionAsPercent,
  });

  @override
  Widget build(BuildContext context) {
    return new Container(
      child: new Padding(
        padding: const EdgeInsets.only(left: 45.0, right: 45.0),
        child: new AspectRatio(
          aspectRatio: 1.0,
          child: new Container(
            child: new Container(
              decoration: new BoxDecoration(
                gradient: new LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [const Color(0xFFF5F5F5), const Color(0xFFE8E8E8)],
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  const BoxShadow(
                    color: const Color(0x44000000),
                    blurRadius: 2.0,
                    spreadRadius: 1.0,
                    offset: const Offset(0.0, 1.0),
                  )
                ]
              ),
              child: new TicksAndRotatingDial(
                tickCount: totalTicks,
                dialPositionAsPercent: dialPositionAsPercent,
                dialInset: 60.0,
              )
            )
          ),
        ),
      ),
    );
  }
}

class TicksAndRotatingDial extends StatelessWidget {

  final int tickCount;
  final double dialInset;
  final double dialPositionAsPercent;
  final child;

  TicksAndRotatingDial({
    this.tickCount = 35,
    this.dialInset = 50.0,
    this.dialPositionAsPercent = 0.0,
    this.child,
  });

  @override
  Widget build(BuildContext context) {
    return new CustomPaint(
      painter: new DialPainter(
        tickCount: tickCount,
        dialInset: dialInset,
        dialPositionAsPercent: dialPositionAsPercent,
      ),
      child: new Padding(
        padding: new EdgeInsets.all(dialInset + 5.0),
        child: new Container(
          decoration: new BoxDecoration(
              gradient: new LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [const Color(0xFFF5F5F5), const Color(0xFFE8E8E8)],
              ),
              shape: BoxShape.circle,
              boxShadow: [
                const BoxShadow(
                  color: const Color(0x33000000),
                  blurRadius: 4.0,
                  spreadRadius: 1.0,
                  offset: const Offset(0.0, 2.0),
                ),
                const BoxShadow(
                  color: const Color(0x22000000),
                  blurRadius: 6.0,
                  spreadRadius: 3.0,
                  offset: const Offset(0.0, 5.0),
                )
              ]
          ),
          child: new Padding(
            padding: const EdgeInsets.all(15.0),
            child: new Container(
                decoration: new BoxDecoration(
                  color: Colors.transparent,
                  shape: BoxShape.circle,
                  border: new Border.all(
                    color: const Color(0xFFDFDFDF),
                    width: 1.5,
                  ),
                ),
                child: new Center(
                  child: new Transform.rotate(
                    angle: 2 * PI * dialPositionAsPercent,
                    child: new Image.network(
                      'https://avatars3.githubusercontent.com/u/14101776?s=400&v=4',
                      width: 50.0,
                      height: 50.0,
                      color: Colors.black,
                    ),
                  ),
                )
            ),
          ),
        ),
      )
    );
  }
}


class DialPainter extends CustomPainter {

  final tickCount;
  final dialInset;
  final dialPositionAsPercent;
  final tickPaint;
  final dialArrowPaint;

  DialPainter({
    @required this.tickCount,
    @required this.dialInset,
    @required this.dialPositionAsPercent,
  }) : tickPaint = new Paint(), dialArrowPaint = new Paint() {
    tickPaint.color = Colors.black;
    tickPaint.strokeWidth = 1.5;

    dialArrowPaint.color = Colors.black;
    dialArrowPaint.strokeWidth = 3.0;
    dialArrowPaint.style = PaintingStyle.fill;
  }

  @override
  void paint(Canvas canvas, Size size) {
    print('Size: $size');

    canvas.translate(size.width / 2, size.height / 2);

    final textPainter = new TextPainter(
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    );

    canvas.save();
    var length;
    for (var i = 0; i < tickCount; ++i) {
      length = i % 5 == 0 ? 10.0 : 4.0;

      canvas.drawLine(
          new Offset(0.0, -(size.width / 2) + dialInset - length),
          new Offset(0.0, -(size.width / 2) + dialInset),
          tickPaint
      );

      if (i % 5 == 0) {
        _paintTimeLabel(canvas, textPainter, size, tickCount, i);
      }
      
      canvas.rotate(2 * PI / tickCount);
    }
    canvas.restore();

    _paintDialArrow(canvas, size, dialPositionAsPercent);
  }

  void _paintTimeLabel(Canvas canvas, TextPainter textPainter, Size size, int totalTickCount, int secondsCount) {
    canvas.save();
    canvas.translate(0.0, -(size.width / 2) + dialInset - 30.0);

    double tickPercent = secondsCount / totalTickCount;
    int quadrant;
    if (tickPercent < 0.25) {
      quadrant = 1;
    } else if (tickPercent < 0.5) {
      quadrant = 4;
    } else if (tickPercent < 0.75) {
      quadrant = 3;
    } else {
      quadrant = 2;
    }

    textPainter.text = new TextSpan(
      text: '$secondsCount',
      style: new TextStyle(
        color: Colors.black,
        fontFamily: 'BebasNeue',
        fontSize: 20.0,
      ),
    );
    textPainter.layout();

    switch (quadrant) {
      case 1:
        // Do nothing, paint the number facing its tick.
        textPainter.paint(canvas, new Offset(-textPainter.width / 2, -textPainter.height * 0.25));
        break;
      case 4:
        // Rotate the canvas so that the number is drawn with the tick on its left side
        canvas.rotate(-(PI / 2));
        textPainter.paint(canvas, new Offset(-12.0, -textPainter.height / 2));
        break;
      case 2:
      case 3:
        // Rotate the canvas so that the number is drawn with the tick on its right side
      canvas.rotate(PI / 2);
      textPainter.paint(canvas, new Offset(-5.0, -textPainter.height / 2));
        break;
    }

    canvas.restore();
  }

  _paintDialArrow(Canvas canvas, Size size, double dialPositionAsPercent) {
    canvas.save();
    canvas.rotate(2 * PI * dialPositionAsPercent);
    canvas.translate(0.0, -(size.width / 2) + dialInset - 3.0);

    Path path = new Path();
    path.moveTo(0.0, -5.0);
    path.lineTo(10.0, 10.0);
    path.lineTo(-10.0, 10.0);
    path.close();

    canvas.drawShadow(path, Colors.black, 3.0, false);
    canvas.drawPath(path, dialArrowPaint);

    canvas.restore();
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    // TODO: implement shouldRepaint
    return true;
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
