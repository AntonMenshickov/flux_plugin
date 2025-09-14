import 'package:flux_plugin/model/hive_type_ids.dart';
import 'package:flux_plugin/model/log_level.dart';
import 'package:hive/hive.dart';

part 'event_message.g.dart';

@HiveType(typeId: HiveTypeIds.eventMessage)
class EventMessage extends HiveObject {
  @HiveField(0)
  final DateTime timestamp;
  @HiveField(1)
  final LogLevel logLevel;
  @HiveField(2)
  final String platform;
  @HiveField(3)
  final String bundleId;
  @HiveField(4)
  final String deviceId;
  @HiveField(5)
  final String message;
  @HiveField(6)
  final List<String> tags;
  @HiveField(7)
  final Map<String, String> meta;
  @HiveField(8)
  final String? stackTrace;

  EventMessage({
    required this.timestamp,
    required this.logLevel,
    required this.platform,
    required this.bundleId,
    required this.deviceId,
    required this.message,
    required this.tags,
    required this.meta,
    this.stackTrace,
  });

  EventMessage clone() => EventMessage(
    timestamp: timestamp,
    logLevel: logLevel,
    platform: platform,
    bundleId: bundleId,
    deviceId: deviceId,
    message: message,
    tags: tags,
    meta: meta,
  );
}
