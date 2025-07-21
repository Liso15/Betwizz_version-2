// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'channel.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ChannelAdapter extends TypeAdapter<Channel> {
  @override
  final int typeId = 0;

  @override
  Channel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Channel(
      id: fields[0] as String,
      name: fields[1] as String,
      description: fields[2] as String,
      imageUrl: fields[3] as String,
      isLive: fields[4] as bool,
      viewerCount: fields[5] as int,
      category: fields[6] as String,
      tags: (fields[7] as List).cast<String>(),
      createdAt: fields[8] as DateTime,
      lastActivity: fields[9] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, Channel obj) {
    writer
      ..writeByte(10)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.description)
      ..writeByte(3)
      ..write(obj.imageUrl)
      ..writeByte(4)
      ..write(obj.isLive)
      ..writeByte(5)
      ..write(obj.viewerCount)
      ..writeByte(6)
      ..write(obj.category)
      ..writeByte(7)
      ..write(obj.tags)
      ..writeByte(8)
      ..write(obj.createdAt)
      ..writeByte(9)
      ..write(obj.lastActivity);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ChannelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
