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
      thumbnailUrl: fields[3] as String,
      streamUrl: fields[4] as String,
      isLive: fields[5] as bool,
      viewerCount: fields[6] as int,
      category: fields[7] as String,
      creatorId: fields[8] as String,
      creatorName: fields[9] as String,
      createdAt: fields[10] as DateTime,
      lastActiveAt: fields[11] as DateTime?,
      tags: (fields[12] as List).cast<String>(),
      isPremium: fields[13] as bool,
      subscriptionPrice: fields[14] as double?,
    );
  }

  @override
  void write(BinaryWriter writer, Channel obj) {
    writer
      ..writeByte(15)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.description)
      ..writeByte(3)
      ..write(obj.thumbnailUrl)
      ..writeByte(4)
      ..write(obj.streamUrl)
      ..writeByte(5)
      ..write(obj.isLive)
      ..writeByte(6)
      ..write(obj.viewerCount)
      ..writeByte(7)
      ..write(obj.category)
      ..writeByte(8)
      ..write(obj.creatorId)
      ..writeByte(9)
      ..write(obj.creatorName)
      ..writeByte(10)
      ..write(obj.createdAt)
      ..writeByte(11)
      ..write(obj.lastActiveAt)
      ..writeByte(12)
      ..write(obj.tags)
      ..writeByte(13)
      ..write(obj.isPremium)
      ..writeByte(14)
      ..write(obj.subscriptionPrice);
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
