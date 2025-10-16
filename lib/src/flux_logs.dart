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

  ///when release mode enabled logs will not be printer. Only sending to server
  final bool releaseMode;

  const FluxLogsConfig({
    required this.deviceInfo,
    this.sendLogLevels = const {LogLevel.error},
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
  late final WebSocketService _webSocketService;

  late final bool _releaseMode;
  late final List<LogLevel> _sendLogLevels;
  final Map<String, String> _meta = {};
  bool _streamMode = false;

  late final StreamSubscription<dynamic> _wsMessagesSubscription;

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
    _webSocketService = WebSocketService(
      uri: websocketUri,
      deviceInfo: config.deviceInfo,
      token: apiConfig.token,
    );
    _webSocketService.connect();
    _wsMessagesSubscription = _webSocketService.messages.listen(_onWsMessage);

    await _queue.init();
  }

  Future<void> dispose() async {
    _wsMessagesSubscription.cancel();
    await _webSocketService.close();
  }

  void _onWsMessage(dynamic data) {
    if (data is String) {
      final WsMessage message = WsMessage.fromJson(jsonDecode(data));
      switch (message.type) {
        case WsMessageType.startEventsStream:
          _streamMode = true;
        case WsMessageType.stopEventsStream:
          _streamMode = false;
      }
    }
  }

  void _putEventToBox(EventMessage event) {
    _queue.addEvent(event);
  }

  void setMetaKey(String key, String value) => _meta[key.trim()] = value.trim();

  String? getMetaValueByKey(String key) => _meta[key.trim()];

  _log(
    String message,
    LogLevel logLevel, [
    List<String> tags = const [],
    Map<String, String> meta = const {},
    StackTrace? stackTrace,
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
        timestamp: _highPrecisionTime.now(),
        logLevel: logLevel,
        message: message,
        tags: uniqueTags,
        meta: metaData,
        stackTrace: stackTrace?.toString(),
      );
      if (_streamMode && _webSocketService.isConnected) {
        _webSocketService.send({'type': 0, 'payload': eventMessage.toJson()});
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
    String message, [
    List<String> tags = const [],
    Map<String, String> meta = const {},
    StackTrace? stackTrace,
  ]) {
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
}
