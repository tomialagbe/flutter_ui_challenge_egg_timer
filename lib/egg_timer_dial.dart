import 'dart:math';

import 'package:egg_timer/egg_timer_knob.dart';
import 'package:flutter/material.dart';

final Color GRADIENT_TOP = const Color(0xFFF5F5F5);
final Color GRADIENT_BOTTOM = const Color(0xFFE8E8E8);

class EggTimerDial extends StatefulWidget {
  @override
  _EggTimerDialState createState() => new _EggTimerDialState();
}

class _EggTimerDialState extends State<EggTimerDial> {
  @override
  Widget build(BuildContext context) {
    return new Container(
      width: double.INFINITY,
      child: new Padding(
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
                new BoxShadow(
                  color: const Color(0x44000000),
                  blurRadius: 2.0,
                  spreadRadius: 1.0,
                  offset: const Offset(0.0, 1.0),
                ),
              ],
            ),
            child: new Stack(
              children: [
                new Container(
                  width: double.INFINITY,
                  height: double.INFINITY,
                  padding: const EdgeInsets.all(55.0),
                  child: new CustomPaint(
                    painter: new TickPainter(

                    ),
                  ),
                ),

                new Padding(
                  padding: const EdgeInsets.all(65.0),
                  child: new EggTimerDialKnob(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class TickPainter extends CustomPainter {

  final LONG_TICK = 14.0;
  final SHORT_TICK = 4.0;

  final tickCount;
  final ticksPerSection;
  final ticksInset;
  final tickPaint;
  final textPainter;
  final textStyle;

  TickPainter({
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

    canvas.save();

    final radius = size.width / 2;
    for (var i = 0; i < tickCount; ++i) {
      final tickLength = i % ticksPerSection == 0 ? LONG_TICK : SHORT_TICK;

      canvas.drawLine(
        new Offset(0.0, -radius),
        new Offset(0.0, -radius - tickLength),
        tickPaint,
      );

      if (i % ticksPerSection == 0) {
        // Paint text.
        canvas.save();
        canvas.translate(0.0, -(size.width / 2) - 30.0);

        textPainter.text = new TextSpan(
          text: '$i',
          style: textStyle,
        );

        // Layout the text
        textPainter.layout();

        // Figure out which quadrant the text is in.
        final tickPercent = i / tickCount;
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

        switch (quadrant) {
          case 4:
            canvas.rotate(-PI / 2);
            break;
          case 2:
          case 3:
            canvas.rotate(PI / 2);
            break;
        }

        textPainter.paint(
          canvas,
          new Offset(
            -textPainter.width / 2,
            -textPainter.height / 2,
          ),
        );

        canvas.restore();
      }

      canvas.rotate(2 * PI / tickCount);
    }

    canvas.restore();
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }

}