import 'package:flux_plugin/extensions/string_extension.dart';
import 'package:flux_plugin/model/event_message.dart';
import 'package:flux_plugin/model/log_level.dart';
import 'package:flux_plugin/reliable_batch_queue/reliable_batch_queue.dart';
import 'package:flux_plugin/utils/high_precision_time.dart';
import 'package:flux_plugin/utils/printer.dart';

import 'api/api.dart';

class FluxLogsConfig {
  ///platform e.g. android, ios
  final String platform;

  ///App bundle id e.g. com.example.app
  final String bundleId;

  ///Unique device identifier
  final String deviceId;

  ///Log levels that will be sent to server
  final Set<LogLevel> sendLogLevels;

  ///when release mode enabled logs will not be printer. Only sending to server
  final bool releaseMode;

  const FluxLogsConfig({
    required this.platform,
    required this.bundleId,
    required this.deviceId,
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

  late final String _platform;
  late final String _bundleId;
  late final String _deviceId;
  late final bool _releaseMode;
  late final List<LogLevel> _sendLogLevels;
  final Map<String, String> _meta = {};

  Future<void> init(
    FluxLogsConfig config,
    ApiConfig apiConfig,
    ReliableBatchQueueOptions queueOptions, [
    PrinterOptions? printerOptions,
  ]) async {
    _api = Api(apiConfig);
    _printer = Printer(printerOptions ?? PrinterOptions());
    _queue = ReliableBatchQueue(queueOptions, _api);
    _highPrecisionTime = HighPrecisionTime();

    _platform = config.platform;
    _bundleId = config.bundleId;
    _deviceId = config.deviceId;
    _releaseMode = config.releaseMode;
    _sendLogLevels = config.sendLogLevels.toList();

    await _queue.init();
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
        platform: _platform,
        bundleId: _bundleId,
        deviceId: _deviceId,
        message: message,
        tags: uniqueTags,
        meta: metaData,
        stackTrace: stackTrace?.toString(),
      );
      _putEventToBox(eventMessage);
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
