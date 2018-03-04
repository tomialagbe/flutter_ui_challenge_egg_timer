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
          child: new Padding(
            padding: const EdgeInsets.all(50.0),
            child: new Stack(
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
            ),
          ),
        ),
      ),
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