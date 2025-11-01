import 'dart:async';
import 'dart:convert';

import 'package:flux_plugin/src/api/api.dart';
import 'package:flux_plugin/src/extensions/string_extension.dart';
import 'package:flux_plugin/src/model/device_info.dart';
import 'package:flux_plugin/src/model/event_message.dart';
import 'package:flux_plugin/src/model/log_level.dart';
import 'package:flux_plugin/src/model/ws_message.dart';
import 'package:flux_plugin/src/reliable_batch_queue/reliable_batch_queue.dart';
import 'package:flux_plugin/src/utils/high_precision_time.dart';
import 'package:flux_plugin/src/utils/printer.dart';
import 'package:flux_plugin/src/websocket/websocket_service.dart';

class FluxLogsConfig {
  ///Info about device
  final DeviceInfo deviceInfo;

  ///Log levels that will be sent to server
  final Set<LogLevel> sendLogLevels;

  ///allow socket connection
  final bool enableSocketConnection;

  ///when release mode enabled logs will not be printer. Only sending to server
  final bool releaseMode;

  const FluxLogsConfig({
    required this.deviceInfo,
    this.sendLogLevels = const {LogLevel.error},
    this.enableSocketConnection = true,
    this.releaseMode = true,
  });
}

class FluxLogs {
  static final FluxLogs _instance = FluxLogs();

  static FluxLogs get instance => _instance;

  late final Api _api;
  late final ReliableBatchQueue _queue;
  late final Printer _printer;
  late final HighPrecisionTime _highPrecisionTime;
  late final WebSocketService? _webSocketService;

  late final bool _releaseMode;
  late final List<LogLevel> _sendLogLevels;
  final Map<String, String> _meta = {};

  bool _streamMode = false;
  Timer? _resetStreamModeTimer;

  late final StreamSubscription<String> _wsMessagesSubscription;
  late final StreamSubscription<void> _wsConnectSubscription;

  Future<void> init(
    FluxLogsConfig config,
    ApiConfig apiConfig,
    ReliableBatchQueueOptions queueOptions, [
    PrinterOptions? printerOptions,
  ]) async {
    _api = Api(apiConfig);
    _printer = Printer(printerOptions ?? PrinterOptions());
    _queue = ReliableBatchQueue(
      queueOptions,
      _api,
      deviceInfo: config.deviceInfo,
    );
    _highPrecisionTime = HighPrecisionTime();

    _releaseMode = config.releaseMode;
    _sendLogLevels = config.sendLogLevels.toList();
    final Uri apiUri = Uri.parse(apiConfig.url);
    final Uri websocketUri = Uri(
      scheme: apiUri.scheme == 'https' ? 'wss' : 'ws',
      host: apiUri.host,
      port: apiUri.port,
      path: '/ws',
    );
    if (config.enableSocketConnection) {
      final websocketService = WebSocketService(
        uri: websocketUri,
        deviceInfo: config.deviceInfo,
        token: apiConfig.token,
      );
      _wsMessagesSubscription = websocketService.messages.listen(_onWsMessage);
      _wsConnectSubscription = websocketService.onConnect.listen(
        (_) => _updateMetaDataBySocket(),
      );
      websocketService.connect();
      _webSocketService = websocketService;
    } else {
      _webSocketService = null;
    }

    await _queue.init();
  }

  Future<void> dispose() async {
    _wsMessagesSubscription.cancel();
    _wsConnectSubscription.cancel();
    await _webSocketService?.close();
  }

  void _onWsMessage(String data) {
    final WsMessage message = WsMessage.fromJson(jsonDecode(data));
    switch (message.type) {
      case WsMessageType.startEventsStream:
        _streamMode = true;
        _startResetStreamModeTimer();
        break;
      case WsMessageType.stopEventsStream:
        _removeResetStreamModeTimer();
        _streamMode = false;
        break;
      case WsMessageType.keepEventsStream:
        _startResetStreamModeTimer();
        break;
    }
  }

  void _removeResetStreamModeTimer() {
    _resetStreamModeTimer?.cancel();
    _resetStreamModeTimer = null;
  }

  void _startResetStreamModeTimer() {
    _resetStreamModeTimer?.cancel();
    _resetStreamModeTimer = Timer(Duration(seconds: 10), () {
      _streamMode = false;
      _resetStreamModeTimer = null;
    });
  }

  void _putEventToBox(EventMessage event) {
    _queue.addEvent(event);
  }

  void setMetaKey(String key, String value) {
    _meta[key.trim()] = value.trim();
    _updateMetaDataBySocket();
  }

  void removeMetaKey(String key) {
    _meta.remove(key.trim());
    _updateMetaDataBySocket();
  }

  String? getMetaValueByKey(String key) => _meta[key.trim()];

  void _updateMetaDataBySocket() {
    final webSocketService = _webSocketService;
    if (webSocketService != null && webSocketService.isConnected) {
      webSocketService.send({'type': 1, 'payload': _meta});
    }
  }

  _log(
    String message,
    LogLevel logLevel, [
    List<String> tags = const [],
    Map<String, String> meta = const {},
    StackTrace? stackTrace,
    DateTime? timestamp,
  ]) {
    final List<String> uniqueTags = tags
        .map((t) => t.trim().removeLineBreaks())
        .toSet()
        .toList();
    if (!_releaseMode) {
      _printer.log(message, logLevel, uniqueTags, stackTrace);
    }
    final Map<String, String> metaData = {..._meta, ...meta};
    if (_sendLogLevels.contains(logLevel)) {
      final EventMessage eventMessage = EventMessage(
        timestamp:
            timestamp?.millisecondsSinceEpoch ?? _highPrecisionTime.now(),
        logLevel: logLevel,
        message: message,
        tags: uniqueTags,
        meta: metaData,
        stackTrace: stackTrace?.toString(),
      );
      if (_streamMode && _webSocketService?.isConnected == true) {
        _webSocketService?.send({'type': 0, 'payload': eventMessage.toJson()});
      } else {
        _putEventToBox(eventMessage);
      }
    }
  }

  info(
    String message, {
    List<String> tags = const [],
    Map<String, String> meta = const {},
    StackTrace? stackTrace,
  }) {
    _log(message, LogLevel.info, tags, meta, stackTrace);
  }

  warn(
    String message, {
    List<String> tags = const [],
    Map<String, String> meta = const {},
    StackTrace? stackTrace,
  }) {
    _log(message, LogLevel.warn, tags, meta, stackTrace);
  }

  error(
    String message, {
    List<String> tags = const [],
    Map<String, String> meta = const {},
    StackTrace? stackTrace,
  }) {
    _log(message, LogLevel.error, tags, meta, stackTrace);
  }

  debug(
    String message, {
    List<String> tags = const [],
    Map<String, String> meta = const {},
    StackTrace? stackTrace,
  }) {
    _log(message, LogLevel.debug, tags, meta, stackTrace);
  }

  crash(
    String message, {
    List<String> tags = const [],
    Map<String, String> meta = const {},
    StackTrace? stackTrace,
    DateTime? timestamp,
  }) {
    _log(message, LogLevel.crash, tags, meta, stackTrace, timestamp);
  }

  List<EventMessage> getPendingEvents() {
    return _queue.getQueue();
  }
}
