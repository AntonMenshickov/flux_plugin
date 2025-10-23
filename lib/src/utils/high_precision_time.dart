class HighPrecisionTime {
  final int _baseMicroseconds;
  final Stopwatch _stopwatch;

  HighPrecisionTime()
      : _baseMicroseconds = DateTime.timestamp().microsecondsSinceEpoch,
        _stopwatch = Stopwatch()..start();

  int nowMicroSeconds() {
    return _baseMicroseconds + _stopwatch.elapsedMicroseconds;
  }

  int now() {
    return (nowMicroSeconds() / 1000).floor();
  }

}