import 'dart:math';

import 'package:flutter/material.dart';
import 'package:fluttery/gestures.dart';

class KnobTurnGestureDetector extends StatefulWidget {

  final onKnobTurnStart;
  final onKnobTurnUpdate;
  final onKnobTurnEnd;
  final child;

  KnobTurnGestureDetector({
    this.onKnobTurnStart,
    this.onKnobTurnUpdate,
    this.onKnobTurnEnd,
    this.child
  });

  @override
  _KnobTurnGestureDetectorState createState() => new _KnobTurnGestureDetectorState();
}

class _KnobTurnGestureDetectorState extends State<KnobTurnGestureDetector> {

  double turnPercent = 0.0;
  PolarCoord startDraggingCoord;

  _onRadialDragStart(coord) {
    startDraggingCoord = coord;

    if (null != widget.onKnobTurnStart) {
      widget.onKnobTurnStart();
    }
  }

  _onRadialDragUpdate(coord) {
    if (null != startDraggingCoord) {
      // Get the angle that the user has spanned by dragging.
      var turnAngle = coord.angle - startDraggingCoord.angle;

      // Interpret angle as a positive value (add 2*PI if it's negative)
      turnAngle = turnAngle > 0 ? turnAngle : turnAngle + (2 * PI);

      // Change angle to percent.
      turnPercent = turnAngle / (2 * PI);

      if (null != widget.onKnobTurnUpdate) {
        widget.onKnobTurnUpdate(turnPercent);
      }
    }
  }

  _onRadialDragEnd() {
    if (null != startDraggingCoord) {
      startDraggingCoord = null;

      if (null != widget.onKnobTurnEnd) {
        widget.onKnobTurnEnd();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return new RadialDragGestureDetector(
      onRadialDragStart: _onRadialDragStart,
      onRadialDragUpdate: _onRadialDragUpdate,
      onRadialDragEnd: _onRadialDragEnd,
      child: widget.child,
    );
  }
}

typedef OnKnobTurnStart = Function();
typedef OnKnobTurnUpdate = Function(double knobTurnPercent);
typedef OnKnobTurnEnd = Function();