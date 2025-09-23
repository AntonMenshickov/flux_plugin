import 'package:flux_plugin/src/model/hive_type_ids.dart';
import 'package:hive/hive.dart';

part 'log_level.g.dart';

@HiveType(typeId: HiveTypeIds.logLevel)
enum LogLevel {
  @HiveField(0)
  info('info'),
  @HiveField(1)
  warn('warn'),
  @HiveField(2)
  error('error'),
  @HiveField(3)
  debug('debug');

  final String value;

  const LogLevel(this.value);
}
