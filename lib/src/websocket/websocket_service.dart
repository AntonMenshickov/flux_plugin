import 'dart:async';
import 'dart:convert';
import 'dart:io';

class WebSocketService {
  final Uri uri;
  WebSocket? _socket;
  final _controller = StreamController<String>.broadcast();

  Stream<String> get messages => _controller.stream;

  bool _manuallyClosed = false;

  int _attempt = 0;
  final Duration _baseDelay = const Duration(seconds: 2);
  final Duration _stepDelay = const Duration(seconds: 30);
  final int _maxAttemptsForIncrease = 10;

  bool get isConnected =>
      _socket != null && _socket!.readyState == WebSocket.open;

  WebSocketService(this.uri);

  Future<void> connect() async {
    _manuallyClosed = false;
    _attempt = 0;
    await _connectInternal();
  }

  void send(Map<String, dynamic> data) {
    if (isConnected) {
      _socket?.add(jsonEncode(data));
    }
  }

  Future<void> _connectInternal() async {
    while (!_manuallyClosed) {
      try {
        print(
          '[$WebSocketService] Connecting to $uri… (attempt ${_attempt + 1})',
        );
        _socket = await WebSocket.connect(uri.toString());
        print('[$WebSocketService] Connected to websocket');
        _attempt = 0;
        _socket!.listen(
          (data) => _controller.add(data),
          onDone: _handleClose,
          onError: _handleError,
          cancelOnError: true,
        );
        break;
      } catch (e) {
        _attempt++;
        final delay = _calculateDelay();
        print(
          '[$WebSocketService] Connection failed: $e. Reconnecting in ${delay.inSeconds}s (attempt $_attempt)',
        );
        await Future.delayed(delay);
      }
    }
  }

  Duration _calculateDelay() {
    if (_attempt == 0) return _baseDelay;
    if (_attempt >= _maxAttemptsForIncrease) {
      return _baseDelay + _stepDelay * (_maxAttemptsForIncrease - 1);
    }
    return _baseDelay + _stepDelay * (_attempt - 1);
  }

  void _handleClose() {
    print('[$WebSocketService] Connection closed');
    if (!_manuallyClosed) {
      _scheduleReconnect();
    }
  }

  void _handleError(dynamic error) {
    print('[$WebSocketService] WebSocket error: $error');
    if (!_manuallyClosed) {
      _scheduleReconnect();
    }
  }

  void _scheduleReconnect() {
    Future.delayed(_calculateDelay(), () {
      if (!_manuallyClosed) {
        _connectInternal();
      }
    });
  }

  Future<void> close() async {
    _manuallyClosed = true;
    await _socket?.close();
    await _controller.close();
  }
}
