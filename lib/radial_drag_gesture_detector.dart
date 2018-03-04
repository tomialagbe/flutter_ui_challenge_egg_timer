import 'dart:math';

import 'package:flutter/material.dart';

class RadialDragGestureDetector extends StatefulWidget {

  final RadialDragStart onRadialDragStart;
  final RadialDragUpdate onRadialDragUpdate;
  final RadialDragEnd onRadialDragEnd;
  final Widget child;

  RadialDragGestureDetector({
    this.onRadialDragStart,
    this.onRadialDragUpdate,
    this.onRadialDragEnd,
    this.child,
  });

  @override
  _RadialDragGestureDetectorState createState() => new _RadialDragGestureDetectorState();
}

class _RadialDragGestureDetectorState extends State<RadialDragGestureDetector> {

  _onPanStart(DragStartDetails details) {
    // Convert the user's global touch offset to an offset that is local to
    // this Widget.
    final localTouchOffset = (context.findRenderObject() as RenderBox)
        .globalToLocal(details.globalPosition);

    // Convert the local offset to a Point so that we can do math with it.
    final localTouchPoint = new Point(localTouchOffset.dx, localTouchOffset.dy);

    // Create a Point at the center of this Widget to act as the origin.
    final originPoint = new Point(context.size.width / 2, context.size.height / 2);

    // Subtract the origin from the touch point to get the vector from the origin
    // to the touch point.
    final vectorPoint = localTouchPoint - originPoint;
    final vector = new Offset(vectorPoint.x, vectorPoint.y);

    final polarCoord = new PolarCoord(
      vector.direction,
      vector.distance,
    );

    widget.onRadialDragStart(polarCoord);
  }

  _onPanUpdate(DragUpdateDetails details) {

  }

  _onPanEnd(DragEndDetails details) {

  }

  @override
  Widget build(BuildContext context) {
    return new GestureDetector(
      onPanStart: _onPanStart,
      onPanUpdate: _onPanUpdate,
      onPanEnd: _onPanEnd,
      child: widget.child,
    );
  }
}

class PolarCoord {
  final double angle;
  final double radius;

  PolarCoord(this.angle, this.radius);

  @override
  toString() {
    return 'Polar Coord: $radius at ${angle / (2 * PI) * 360} degrees';
  }
}

typedef RadialDragStart = Function(PolarCoord startCoord);
typedef RadialDragUpdate = Function(PolarCoord updateCoord);
typedef RadialDragEnd = Function();