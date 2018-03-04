import 'package:egg_timer/egg_timer_button.dart';
import 'package:egg_timer/egg_timer_controls.dart';
import 'package:egg_timer/egg_timer_time_display.dart';
import 'package:egg_timer/framing.dart';
import 'package:flutter/material.dart';

final GRADIENT_TOP = const Color(0xFFF5F5F5);
final GRADIENT_BOTTOM = const Color(0xFFE8E8E8);

void main() {
  runApp(new MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'Egg Timer',
      theme: new ThemeData(
        fontFamily: 'BebasNeue',
      ),
      home: new Scaffold(
        body: new Center(
          child: new Column(
            children: [
              //--------- Time Display --------
              new EggTimerTimeDisplay(

              ),

              //--------- Dial --------
              new Padding(
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
                      padding: const EdgeInsets.all(60.0),
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
                  ),
                ),
              ),

              //------- Expanded Area For Extra Space -------
              new Expanded(child: new Container()),

              //------- Controls -----
              new EggTimerControls(

              ),
            ],
          ),
        ),
      ),
    );
  }
}
