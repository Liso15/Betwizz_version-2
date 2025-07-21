// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chat_message.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ChatMessageAdapter extends TypeAdapter<ChatMessage> {
  @override
  final int typeId = 1;

  @override
  ChatMessage read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ChatMessage(
      id: fields[0] as String,
      userId: fields[1] as String,
      userName: fields[2] as String,
      userAvatar: fields[3] as String?,
      message: fields[4] as String,
      timestamp: fields[5] as DateTime,
      type: fields[6] as MessageType,
      channelId: fields[7] as String?,
      isFromAI: fields[8] as bool,
      metadata: (fields[9] as Map?)?.cast<String, dynamic>(),
    );
  }

  @override
  void write(BinaryWriter writer, ChatMessage obj) {
    writer
      ..writeByte(10)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.userId)
      ..writeByte(2)
      ..write(obj.userName)
      ..writeByte(3)
      ..write(obj.userAvatar)
      ..writeByte(4)
      ..write(obj.message)
      ..writeByte(5)
      ..write(obj.timestamp)
      ..writeByte(6)
      ..write(obj.type)
      ..writeByte(7)
      ..write(obj.channelId)
      ..writeByte(8)
      ..write(obj.isFromAI)
      ..writeByte(9)
      ..write(obj.metadata);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ChatMessageAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class MessageTypeAdapter extends TypeAdapter<MessageType> {
  @override
  final int typeId = 2;

  @override
  MessageType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return MessageType.text;
      case 1:
        return MessageType.image;
      case 2:
        return MessageType.system;
      case 3:
        return MessageType.bet;
      case 4:
        return MessageType.tip;
      default:
        return MessageType.text;
    }
  }

  @override
  void write(BinaryWriter writer, MessageType obj) {
    switch (obj) {
      case MessageType.text:
        writer.writeByte(0);
        break;
      case MessageType.image:
        writer.writeByte(1);
        break;
      case MessageType.system:
        writer.writeByte(2);
        break;
      case MessageType.bet:
        writer.writeByte(3);
        break;
      case MessageType.tip:
        writer.writeByte(4);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MessageTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
