import 'package:flux_plugin/src/model/hive_type_ids.dart';
import 'package:flux_plugin/src/model/log_level.dart';
import 'package:hive/hive.dart';

part 'event_message.g.dart';

@HiveType(typeId: HiveTypeIds.eventMessage)
class EventMessage extends HiveObject {
  @HiveField(0)
  final int timestamp;
  @HiveField(1)
  final LogLevel logLevel;
  @HiveField(2)
  final String message;
  @HiveField(3)
  final List<String> tags;
  @HiveField(4)
  final Map<String, String> meta;
  @HiveField(5)
  final String? stackTrace;

  EventMessage({
    required this.timestamp,
    required this.logLevel,
    required this.message,
    required this.tags,
    required this.meta,
    this.stackTrace,
  });

  EventMessage clone() => EventMessage(
    timestamp: timestamp,
    logLevel: logLevel,
    message: message,
    tags: tags,
    meta: meta,
    stackTrace: stackTrace,
  );

  Map<String, dynamic> toJson() => {
    "timestamp": timestamp,
    "logLevel": logLevel.value,
    "message": message,
    if (tags.isNotEmpty) "tags": tags,
    if (meta.isNotEmpty) "meta": meta,
    if (stackTrace != null) "stackTrace": stackTrace,
  };
}
