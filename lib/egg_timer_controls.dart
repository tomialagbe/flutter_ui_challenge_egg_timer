import 'package:egg_timer/egg_timer_button.dart';
import 'package:flutter/material.dart';

class EggTimerControls extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new Column(
      children: [
        new Row(
          children: [
            new EggTimerButton(
              icon: Icons.refresh,
              text: 'RESTART',
              onPressed: () { },
            ),
            new Expanded(child: new Container()),
            new EggTimerButton(
              icon: Icons.arrow_back,
              text: 'RESET',
              onPressed: () { },
            ),
          ],
        ),
        new EggTimerButton(
          icon: Icons.pause,
          text: 'PAUSE',
          backgroundColor: Colors.white,
          onPressed: () { },
        ),
      ],
    );
  }
}
