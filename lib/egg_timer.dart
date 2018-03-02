import 'dart:math';

import 'package:egg_timer/countdown_timer.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart' hide TextDirection;
import 'package:meta/meta.dart';
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
                new DialGestureDetector(
                  onDialTurnStart: _onDialTurnStart,
                  onDialTurnUpdate: _onDialTurnUpdate,
                  onDialTurnEnd: _onDialTurnEnd,
                  child: new EggTimerDial(
                    totalTicks: (countdownTimer.maxTimeInSeconds / 60).round() * widget.ticksPerMinute,
                    dialPositionAsPercent: null != resetDialAnimation
                        ? resetDialAnimation.value
                        : dialPositionAsPercent,
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

class DialGestureDetector extends StatefulWidget {

  final double initialDialTurnInPercent;
  final DialTurnStart onDialTurnStart;
  final DialTurnUpdate onDialTurnUpdate;
  final DialTurnEnd onDialTurnEnd;
  final Widget child;

  DialGestureDetector({
    this.initialDialTurnInPercent,
    this.onDialTurnStart,
    this.onDialTurnUpdate,
    this.onDialTurnEnd,
    @required this.child,
  });

  @override
  _DialGestureDetectorState createState() => new _DialGestureDetectorState();
}

class _DialGestureDetectorState extends State<DialGestureDetector> {

  double dialPositionAsPercent = 0.0;
  double turningPositionAsPercent = 0.0;
  ParametricCoord startTurningCoord;

  _onRadialDragStart(ParametricCoord coord) {
    startTurningCoord = coord;

    if (null != widget.onDialTurnStart) {
      widget.onDialTurnStart(0.0);
    }
  }

  _onRadialDragUpdate(ParametricCoord coord) {
    if (null != startTurningCoord) {
      final angleDelta = coord.angle - startTurningCoord.angle;
      turningPositionAsPercent = dialPositionAsPercent + (angleDelta / (PI * 2));

      if (null != widget.onDialTurnUpdate) {
        widget.onDialTurnUpdate(turningPositionAsPercent);
      }
    }
  }

  _onRadialDragEnd() {
    startTurningCoord = null;
    turningPositionAsPercent = 0.0;
    dialPositionAsPercent = turningPositionAsPercent;

    if (null != widget.onDialTurnEnd) {
      widget.onDialTurnEnd();
    }
  }

  @override
  Widget build(BuildContext context) {
    return new RadialGestureDetector(
        onRadialDragStart: _onRadialDragStart,
        onRadialDragUpdate: _onRadialDragUpdate,
        onRadialDragEnd: _onRadialDragEnd,
        child: widget.child,
    );
  }
}

typedef DialTurnStart = Function(double dialPositionAsPercent);
typedef DialTurnUpdate = Function(double dialPositionAsPercent);
typedef DialTurnEnd = Function();

class ParametricCoord {
  final angle;
  final radius;

  factory ParametricCoord.fromPoint(Point origin, Point point) {
    Point diffFromOrigin = point - origin;
    Offset vector = new Offset(diffFromOrigin.x, diffFromOrigin.y);

    return new ParametricCoord(
      vector.direction,
      vector.distance,
    );
  }

  ParametricCoord(this.angle, this.radius);
}

class RadialGestureDetector extends StatefulWidget {

  final Offset origin;
  final RadialDragStart onRadialDragStart;
  final RadialDragUpdate onRadialDragUpdate;
  final RadialDragEnd onRadialDragEnd;
  final Widget child;

  RadialGestureDetector({
    this.origin,
    this.onRadialDragStart,
    this.onRadialDragUpdate,
    this.onRadialDragEnd,
    @required this.child
  });

  @override
  _RadialGestureDetectorState createState() => new _RadialGestureDetectorState();
}

class _RadialGestureDetectorState extends State<RadialGestureDetector> {

  _onDragStart(DragStartDetails details) {
    print('Start drag position: ${details.globalPosition}');
    if (null != widget.onRadialDragStart) {
      widget.onRadialDragStart(
          _parametricCoordFromGlobalPosition(details.globalPosition)
      );
    }
  }

  _onDrag(DragUpdateDetails details) {
    if (null != widget.onRadialDragUpdate) {
      widget.onRadialDragUpdate(
          _parametricCoordFromGlobalPosition(details.globalPosition)
      );
    }
  }

  _onDragEnd(DragEndDetails details) {
    if (null != widget.onRadialDragEnd) {
      widget.onRadialDragEnd();
    }
  }

  _parametricCoordFromGlobalPosition(globalPosition) {
    return new ParametricCoord.fromPoint(
      _origin(),
      _localPointFromGlobalPosition(globalPosition),
    );
  }

  _origin() {
    return new Point(
      context.size.width / 2.0,
      context.size.height / 2.0,
    );
  }

  _localPointFromGlobalPosition(globalPosition) {
    Offset localOffset = (context.findRenderObject() as RenderBox)
        .globalToLocal(globalPosition);
    return new Point(
      localOffset.dx,
      localOffset.dy,
    );
  }

  @override
  Widget build(BuildContext context) {
    return new GestureDetector(
      onVerticalDragStart: _onDragStart,
      onVerticalDragUpdate: _onDrag,
      onVerticalDragEnd: _onDragEnd,
      child: widget.child,
    );
  }
}

typedef RadialDragStart = Function(ParametricCoord newCoord);
typedef RadialDragUpdate = Function(ParametricCoord newCoord);
typedef RadialDragEnd = Function();

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
//    print('Size: $size');

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
