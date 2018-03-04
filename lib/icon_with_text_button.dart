import 'package:flutter/material.dart';

class IconWithTextButton extends StatelessWidget {

  final IconData icon;
  final String text;
  final Color color;
  final Function onPressed;

  IconWithTextButton({
    this.icon,
    this.text = '',
    this.color = Colors.transparent,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return new FlatButton(
      color: color,
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
              style: new TextStyle(
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