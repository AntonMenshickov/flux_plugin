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
      timestamp: fields[0] as int,
      logLevel: fields[1] as LogLevel,
      message: fields[2] as String,
      tags: (fields[3] as List).cast<String>(),
      meta: (fields[4] as Map).cast<String, String>(),
      stackTrace: fields[5] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, EventMessage obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.timestamp)
      ..writeByte(1)
      ..write(obj.logLevel)
      ..writeByte(2)
      ..write(obj.message)
      ..writeByte(3)
      ..write(obj.tags)
      ..writeByte(4)
      ..write(obj.meta)
      ..writeByte(5)
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
