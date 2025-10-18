// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'log_level.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class LogLevelAdapter extends TypeAdapter<LogLevel> {
  @override
  final int typeId = 1;

  @override
  LogLevel read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return LogLevel.info;
      case 1:
        return LogLevel.warn;
      case 2:
        return LogLevel.error;
      case 3:
        return LogLevel.debug;
      case 4:
        return LogLevel.crash;
      default:
        return LogLevel.info;
    }
  }

  @override
  void write(BinaryWriter writer, LogLevel obj) {
    switch (obj) {
      case LogLevel.info:
        writer.writeByte(0);
        break;
      case LogLevel.warn:
        writer.writeByte(1);
        break;
      case LogLevel.error:
        writer.writeByte(2);
        break;
      case LogLevel.debug:
        writer.writeByte(3);
        break;
      case LogLevel.crash:
        writer.writeByte(4);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LogLevelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
