import 'package:flutter/material.dart';

class EggTimerButton extends StatelessWidget {

  final IconData icon;
  final String text;
  final Function() onPressed;

  EggTimerButton({
    this.icon,
    this.text,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return new FlatButton(
        splashColor: const Color(0x22000000),
        onPressed: onPressed,
        child: new Padding(
          padding: const EdgeInsets.all(25.0),
          child: new Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              new Padding(
                padding: const EdgeInsets.only(right: 3.0),
                child: new Icon(
                  icon,
                  color: Colors.black,
                ),
              ),
              new Text(
                text,
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 20.0,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 3.0,
                ),
              ),
            ],
          ),
        )
    );
  }
}
