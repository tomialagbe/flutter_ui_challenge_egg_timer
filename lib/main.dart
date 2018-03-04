import 'package:egg_timer/egg_timer_time_display.dart';
import 'package:egg_timer/framing.dart';
import 'package:flutter/material.dart';

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
              new RandomColorBlock(
                width: double.INFINITY,
                child: new Padding(
                  padding: const EdgeInsets.only(left: 45.0, right: 45.0),
                  child: new AspectRatio(
                    aspectRatio: 1.0,
                    child: new RandomColorBlock(
                      width: double.INFINITY,
                    ),
                  ),
                ),
              ),

              //------- Expanded Area For Extra Space -------
              new Expanded(child: new Container()),

              //------- Controls -----
              new Column(
                children: [
                  new Row(
                    children: [
                      new RandomColorBlock(
                        width: 200.0,
                        height: 75.0,
                      ),
                      new Expanded(child: new Container()),
                      new RandomColorBlock(
                        width: 200.0,
                        height: 75.0,
                      ),
                    ],
                  ),
                  new FlatButton(
                    splashColor: const Color(0x22000000),
                    onPressed: () { },
                    child: new Padding(
                      padding: const EdgeInsets.all(25.0),
                      child: new Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          new Padding(
                            padding: const EdgeInsets.only(right: 3.0),
                            child: new Icon(
                              Icons.pause,
                              color: Colors.black,
                            ),
                          ),
                          new Text(
                            'Pause',
                            style: const TextStyle(
                              color: Colors.black,
                              fontSize: 20.0,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 3.0,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
