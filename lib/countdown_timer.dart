import 'dart:async';

/// CountdownTimer is a logical representation of an egg timer that can be set
/// to a given position and then counts down until it reaches zero and alarms.
///
/// This class has nothing to do with any user interface - it only represents the
/// logic of a countdown timer. Hook methods can be provided to be notified of
/// time updates and an alarm going off.
class CountdownTimer {

  final CountdownTimerUpdate onTimerUpdate;
  final CountdownTimerAlarm onTimerAlarm;
  final stopwatch = new Stopwatch(); // Stopwatch counts time up, we count time down.
  CountdownTimerState state = CountdownTimerState.ready;
  int _timeInSeconds = 0;
  int _lastStartTimeInSeconds = 0;

  CountdownTimer({
    this.onTimerUpdate,
    this.onTimerAlarm,
  });

  get time {
    return _timeInSeconds;
  }

  // Starts the countdown if the timer is READY or PAUSED.
  resume() {
    if (state != CountdownTimerState.running && _timeInSeconds > 0) {
      print('Resuming from $_timeInSeconds seconds');
      state = CountdownTimerState.running;
      stopwatch.start();
      _tick();
    }
  }

  // Pauses the countdown if the timer is RUNNING.
  pause() {
    if (state == CountdownTimerState.running) {
      state = CountdownTimerState.paused;
      stopwatch.stop();

      if (null != onTimerUpdate) {
        onTimerUpdate(time);
      }
    }
  }

  // If the timer is PAUSED, returns the timer to its original countdown position
  // and starts it running.
  restart() {
    if (state == CountdownTimerState.paused) {
      _timeInSeconds = _lastStartTimeInSeconds;
      stopwatch.reset();
      resume();
    }
  }

  // If the timer is PAUSED, returns the timer to the zero position and puts it
  // in the READY state.
  reset() {
    if (state == CountdownTimerState.paused) {
      _timeInSeconds = 0;
      _lastStartTimeInSeconds = 0;
      state = CountdownTimerState.ready;
      stopwatch.reset();

      if (null != onTimerUpdate) {
        onTimerUpdate(time);
      }
    }
  }

  // If the timer is READY, sets the time to the desired time.
  selectTime(timeInSeconds) {
    if (state == CountdownTimerState.ready) {
      _timeInSeconds = timeInSeconds;
      _lastStartTimeInSeconds = timeInSeconds;

      if (null != onTimerUpdate) {
        onTimerUpdate(time);
      }
    }
  }

  _tick() {
    if (state == CountdownTimerState.running) {
      _timeInSeconds = (_lastStartTimeInSeconds - stopwatch.elapsed.inSeconds).clamp(0, double.INFINITY);

      if (null != onTimerUpdate) {
        onTimerUpdate(_timeInSeconds);
      }

      if (_timeInSeconds > 0) {
        new Timer(new Duration(seconds: 1), _tick);
      } else if (null != onTimerAlarm) {
        onTimerAlarm();
      }
    }
  }
}

enum CountdownTimerState {
  ready,
  running,
  paused,
}

typedef CountdownTimerUpdate = Function(int timeInSeconds);
typedef CountdownTimerAlarm = Function();