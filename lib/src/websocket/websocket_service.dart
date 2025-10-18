import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flux_plugin/flux_plugin.dart';

class WebSocketService {
  late final Uri _uri;
  late final DeviceInfo _deviceInfo;
  late final String _token;
  WebSocket? _socket;
  final _messagesStreamController = StreamController<String>.broadcast();
  final _onConnectStreamController = StreamController<void>.broadcast();

  Stream<String> get messages => _messagesStreamController.stream;
  Stream<void> get onConnect => _onConnectStreamController.stream;

  bool _manuallyClosed = false;

  int _attempt = 0;
  final Duration _baseDelay = const Duration(seconds: 2);
  final Duration _stepDelay = const Duration(seconds: 30);
  final int _maxAttemptsForIncrease = 10;

  bool get isConnected =>
      _socket != null && _socket!.readyState == WebSocket.open;

  WebSocketService({
    required Uri uri,
    required DeviceInfo deviceInfo,
    required String token,
  }) : _uri = uri,
       _deviceInfo = deviceInfo,
       _token = token;

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
          '[$WebSocketService] Connecting to $_uri… (attempt ${_attempt + 1})',
        );
        _socket = await WebSocket.connect(
          _uri.toString(),
          headers: {
            'client': 'device',
            'token': _token,
            ..._deviceInfo.toJson(),
          },
        );
        _onConnectStreamController.add(null);
        print('[$WebSocketService] Connected to websocket');
        _attempt = 0;
        _socket!.listen(
          (data) => _messagesStreamController.add(data),
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
    await _onConnectStreamController.close();
    await _messagesStreamController.close();
  }
}
