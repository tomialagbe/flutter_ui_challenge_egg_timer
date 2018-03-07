class EggTimer {

  final Duration maxTime;
  Duration _currentTime = const Duration(seconds: 0);
  EggTimerState state = EggTimerState.ready;

  EggTimer({
    this.maxTime,
  });

  get currentTime {
    return _currentTime;
  }

  set currentTime(newTime) {
    if (state == EggTimerState.ready) {
      _currentTime = newTime;
    }
  }
}

enum EggTimerState {
  ready,
  running,
  paused,
}