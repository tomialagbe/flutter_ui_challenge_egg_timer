import 'package:flutter/material.dart';

class EggTimerButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new FlatButton(
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
    );
  }
}
