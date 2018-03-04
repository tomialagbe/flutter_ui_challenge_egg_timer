import 'dart:math';

import 'package:egg_timer/ui_constants.dart';
import 'package:flutter/material.dart';

class EggTimerDial extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return new Padding(
      padding: const EdgeInsets.only(left: 45.0, right: 45.0),
      child: new AspectRatio(
        aspectRatio: 1.0,
        child: new Container(
          decoration: new BoxDecoration(
            shape: BoxShape.circle,
            gradient: new LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [GRADIENT_TOP, GRADIENT_BOTTOM],
            ),
            boxShadow: [
              const BoxShadow(
                color: const Color(0x44000000),
                blurRadius: 2.0,
                spreadRadius: 1.0,
                offset: const Offset(0.0, 1.0),
              ),
            ],
          ),
          child: new Stack(
            children: [
              new Padding(
                padding: const EdgeInsets.all(55.0),
                child: new Container(
                  width: double.INFINITY,
                  height: double.INFINITY,
                  child: new CustomPaint(
                    painter: new TimeTickPainter(),
                  ),
                ),
              ),
              new Padding(
                padding: const EdgeInsets.all(50.0),
                child: new Knob(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class TimeTickPainter extends CustomPainter {

  static const LONG_TICK = 14.0;
  static const SHORT_TICK = 4.0;

  final tickCount;
  final ticksPerSection;
  final ticksInset;
  final tickPaint;
  final textPainter;
  final textStyle;

  TimeTickPainter({
    this.tickCount = 35,
    this.ticksPerSection = 5,
    this.ticksInset = 0.0,
  }) : tickPaint = new Paint(),
        textPainter = new TextPainter(
          textAlign: TextAlign.center,
          textDirection: TextDirection.ltr,
        ),
        textStyle = const TextStyle(
          color: Colors.black,
          fontFamily: 'BebasNeue',
          fontSize: 20.0,
        ) {
    tickPaint.color = Colors.black;
    tickPaint.strokeWidth = 1.5;
  }

  @override
  void paint(Canvas canvas, Size size) {
    canvas.translate(size.width / 2, size.height / 2);

    // Save canvas position so we can rotate while painting ticks.
    canvas.save();

    // Paint a tick, then rotate the canvas, then paint another tick, etc.
    final radius = size.width / 2;
    for (var i = 0; i < tickCount; ++i) {
      final tickLength = i % ticksPerSection == 0 ? LONG_TICK : SHORT_TICK;

      canvas.drawLine(
        new Offset(0.0, -radius - tickLength),
        new Offset(0.0, -radius),
        tickPaint,
      );

      // We need to paint the minute text at the beginning of every tick section.
      if (i % ticksPerSection == 0) {
        _paintTimeLabel(canvas, size, i);
      }

      // Rotate the canvas so that the next tick can be drawn at the top center
      // of the dial.
      canvas.rotate(2 * PI / tickCount);
    }

    // Restore the original canvas orientation before the tick rotations.
    canvas.restore();
  }

  _paintTimeLabel(canvas, size, tickIndex) {
    canvas.save();
    canvas.translate(0.0, -(size.width / 2) - 30.0);

    // The spec shows text that is aligned differently based on where it
    // falls on the circle. We find where the text is on the circle and handle
    // each quadrant specifically.
    final tickPercent = tickIndex / tickCount;
    var quadrant;
    if (tickPercent < 0.25) {
      quadrant = 1;
    } else if (tickPercent < 0.5) {
      quadrant = 4;
    } else if (tickPercent < 0.75) {
      quadrant = 3;
    } else {
      quadrant = 2;
    }

    // Configure the painting of the minute text.
    textPainter.text = new TextSpan(
      text: '$tickIndex',
      style: textStyle,
    );

    // Call layout so that we can measure how much room the text needs.
    textPainter.layout();

    // Orient the minute text based on the quadrant it belongs to.
    switch (quadrant) {
      case 1:
      // Do nothing, pain the number facing its tick.
        textPainter.paint(
          canvas,
          new Offset(
            -textPainter.width / 2,
            -textPainter.height / 2,
          ),
        );
        break;
      case 4:
      // Rotate the canvas so that the number is drawn with the tick on its left side
        canvas.rotate(-PI / 2);
        textPainter.paint(
          canvas,
          new Offset(
            -textPainter.width / 2,
            -textPainter.height / 2,
          ),
        );
        break;
      case 2:
      case 3:
      // Rotate the canvas so that the number is drawn with the tick on its right side
        canvas.rotate(PI / 2);
        textPainter.paint(
          canvas,
          new Offset(
              -textPainter.width / 2,
              -textPainter.height / 2
          ),
        );
        break;
    }

    canvas.restore();
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }

}

class Knob extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new Stack(
      children: [
        new Container(
          width: double.INFINITY,
          height: double.INFINITY,
          child: new CustomPaint(
            painter: new ArrowPainter(),
          ),
        ),
        new Padding(
          padding: const EdgeInsets.all(10.0),
          child: new Container(
              decoration: new BoxDecoration(
                shape: BoxShape.circle,
                gradient: new LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [GRADIENT_TOP, GRADIENT_BOTTOM],
                ),
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
                  ),
                ],
              ),
              child: new Padding(
                padding: const EdgeInsets.all(10.0),
                child: new Container(
                  decoration: new BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.transparent,
                    border: new Border.all(
                      color: const Color(0xFFDFDFDF),
                      width: 1.5,
                    ),
                  ),
                  child: new Center(
                    child: new Image.network(
                      'https://avatars3.githubusercontent.com/u/14101776?s=400&v=4',
                      width: 50.0,
                      height: 50.0,
                      color: Colors.black,
                    ),
                  ),
                ),
              )
          ),
        ),
      ],
    );
  }
}


class ArrowPainter extends CustomPainter {

  final dialArrowPaint;

  ArrowPainter() : dialArrowPaint = new Paint() {
    dialArrowPaint.color = Colors.black;
    dialArrowPaint.strokeWidth = 3.0;
    dialArrowPaint.style = PaintingStyle.fill;
  }

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.translate(size.width / 2, 0.0);

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
    return true;
  }

}