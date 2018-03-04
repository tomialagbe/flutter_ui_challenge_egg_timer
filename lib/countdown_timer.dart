import 'dart:async';

import 'package:meta/meta.dart';

class CountdownTimer {

  static const int DEFAULT_MAX_TIME_IN_SECONDS = 35 * 60;

  final TimerUpdate onTimerUpdate;
  CountdownTimerState state = CountdownTimerState.ready;
  Stopwatch _stopwatch = new Stopwatch();
  final int maxTimeInSeconds;
  int _timeInSeconds;
  int _startCountdownInSeconds;

  CountdownTimer({
    @required this.onTimerUpdate,
    this.maxTimeInSeconds = DEFAULT_MAX_TIME_IN_SECONDS,
    timeInSeconds = 0,
  }) :
        _timeInSeconds = timeInSeconds,
        _startCountdownInSeconds = timeInSeconds;

  get time {
    return _timeInSeconds;
  }

  set time(time) {
    if (state == CountdownTimerState.ready) {
      _timeInSeconds = time;
      _startCountdownInSeconds = time;
    } else if (state == CountdownTimerState.running) {
      reset();
      this.time = time;
      resume();
    } else if (state == CountdownTimerState.paused) {
      _stopwatch.reset();
      _startCountdownInSeconds = time;
    }

    onTimerUpdate();
  }

  get currentCountdownStartTime {
    return _startCountdownInSeconds;
  }

  resume() {
    // Round to the nearest minute before starting the countdown. This is a
    // desired feature of the timer, to start at whole minutes.
    final timeRoundedToMinute = (time / 60.0).round() * 60;
    _timeInSeconds = timeRoundedToMinute;
    _startCountdownInSeconds = _timeInSeconds;

    if ((state == CountdownTimerState.ready || state == CountdownTimerState.paused)
        && time > 0) {
      state = CountdownTimerState.running;
      _stopwatch.start();
      _tick();
      onTimerUpdate();
    }
  }

  pause() {
    if (state == CountdownTimerState.running) {
      state = CountdownTimerState.paused;
      _stopwatch.stop();
      onTimerUpdate();
    }
  }

  reset() {
    state = CountdownTimerState.ready;
    _timeInSeconds = 0;
    _startCountdownInSeconds = 0;
    _stopwatch.reset();
    onTimerUpdate();
  }

  restart() {
    state = CountdownTimerState.running;
    _timeInSeconds = _startCountdownInSeconds;
    _stopwatch.reset();
    _stopwatch.start();
    onTimerUpdate();

    _tick();
  }

  _tick() {
    if (_timeInSeconds > 0) {
      _timeInSeconds = _startCountdownInSeconds - _stopwatch.elapsed.inSeconds;
//      print('Stopwatch: ${_stopwatch.elapsed.inSeconds}, time: $_timeInSeconds');

      // Notify our listener.
      onTimerUpdate();

      if (state == CountdownTimerState.running) {
        new Timer(new Duration(seconds: 1), _tick);
      }
    } else {
      reset();
    }
  }
}

typedef TimerUpdate = Function();

enum CountdownTimerState {
  ready,
  running,
  paused,
}