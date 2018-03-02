import 'dart:math';

import 'package:egg_timer/radial_drag.dart';
import 'package:flutter/material.dart';
import 'package:meta/meta.dart';

class DraggableTimeDial extends StatelessWidget {

  final onDialTurnStart;
  final onDialTurnUpdate;
  final onDialTurnEnd;
  final tickCount;
  final dialPositionAsPercent;

  DraggableTimeDial({
      this.onDialTurnStart,
      this.onDialTurnUpdate,
      this.onDialTurnEnd,
      this.tickCount,
      this.dialPositionAsPercent
  });

  @override
  Widget build(BuildContext context) {
    return new DialGestureDetector(
      onDialTurnStart: onDialTurnStart,
      onDialTurnUpdate: onDialTurnUpdate,
      onDialTurnEnd: onDialTurnEnd,
      child: new EggTimerDial(
        totalTicks: tickCount,
        dialPositionAsPercent: dialPositionAsPercent,
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