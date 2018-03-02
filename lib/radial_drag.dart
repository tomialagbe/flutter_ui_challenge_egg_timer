import 'dart:math';

import 'package:flutter/material.dart';
import 'package:meta/meta.dart';

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