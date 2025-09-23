class HighPrecisionTime {
  final int _baseMicroseconds;
  final Stopwatch _stopwatch;

  HighPrecisionTime()
      : _baseMicroseconds = DateTime.timestamp().microsecondsSinceEpoch,
        _stopwatch = Stopwatch()..start();

  int now() {
    return _baseMicroseconds + _stopwatch.elapsedMicroseconds;
  }
}