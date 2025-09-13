// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'event_message.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class EventMessageAdapter extends TypeAdapter<EventMessage> {
  @override
  final int typeId = 0;

  @override
  EventMessage read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return EventMessage(
      timestamp: fields[0] as DateTime,
      logLevel: fields[1] as LogLevel,
      platform: fields[2] as String,
      bundleId: fields[3] as String,
      deviceId: fields[4] as String,
      message: fields[5] as String,
      tags: (fields[6] as List).cast<String>(),
      meta: (fields[7] as Map).cast<String, String>(),
      stackTrace: fields[8] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, EventMessage obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.timestamp)
      ..writeByte(1)
      ..write(obj.logLevel)
      ..writeByte(2)
      ..write(obj.platform)
      ..writeByte(3)
      ..write(obj.bundleId)
      ..writeByte(4)
      ..write(obj.deviceId)
      ..writeByte(5)
      ..write(obj.message)
      ..writeByte(6)
      ..write(obj.tags)
      ..writeByte(7)
      ..write(obj.meta)
      ..writeByte(8)
      ..write(obj.stackTrace);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EventMessageAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
