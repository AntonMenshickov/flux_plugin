import 'package:flux_plugin/extensions/string_extension.dart';
import 'package:flux_plugin/model/event_message.dart';
import 'package:flux_plugin/model/log_level.dart';
import 'package:flux_plugin/utils/printer.dart';
import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

class FluxLogsConfig {
  ///platform e.g. android, ios
  final String platform;

  ///App bundle id e.g. com.example.app
  final String bundleId;

  ///Unique device identifier
  final String deviceId;

  ///Generated app token
  final String token;

  ///Directory when events will be stored
  ///for flutter path_provider.getApplicationDocumentsDirectory can be used
  final String storagePath;

  final bool releaseMode;

  const FluxLogsConfig({
    required this.platform,
    required this.bundleId,
    required this.deviceId,
    required this.token,
    required this.storagePath,
    this.releaseMode = true,
  });
}

class FluxLogs {
  static const String _queueBoxName = 'flux_logs_queue_box';
  static const String _processingBoxName = 'flux_logs_processing_box';

  static final FluxLogs _instance = FluxLogs();

  static FluxLogs get instance => _instance;

  late final Uuid _uuid;
  late final Box<EventMessage> _queueBox;
  late final Box<EventMessage> _processingBox;

  late final String _platform;
  late final String _bundleId;
  late final String _deviceId;
  late final String _token;
  late final bool _releaseMode;

  Future<void> init(FluxLogsConfig config) async {
    _uuid = Uuid();

    _platform = config.platform;
    _bundleId = config.bundleId;
    _deviceId = config.deviceId;
    _token = config.token;
    _releaseMode = config.releaseMode;

    Hive.init(config.storagePath);
    Hive.registerAdapter(EventMessageAdapter());
    Hive.registerAdapter(LogLevelAdapter());
    _queueBox = await Hive.openBox(_queueBoxName);
    _processingBox = await Hive.openBox(_processingBoxName);
  }

  void _putEventToBox(EventMessage event) {
    _queueBox.put(_uuid.v4(), event);
  }

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
      Printer.log(message, logLevel, uniqueTags, stackTrace);
    }
    final EventMessage eventMessage = EventMessage(
      timestamp: DateTime.timestamp(),
      logLevel: logLevel,
      platform: _platform,
      bundleId: _bundleId,
      deviceId: _deviceId,
      message: message,
      tags: uniqueTags,
      meta: meta,
      stackTrace: stackTrace?.toString(),
    );
    _putEventToBox(eventMessage);
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
