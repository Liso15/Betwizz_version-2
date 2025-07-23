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
      content: fields[1] as String,
      senderId: fields[2] as String,
      senderName: fields[3] as String,
      senderAvatarUrl: fields[4] as String?,
      timestamp: fields[5] as DateTime,
      isUser: fields[6] as bool,
      type: fields[7] as MessageType,
      channelId: fields[8] as String?,
      metadata: (fields[9] as Map?)?.cast<String, dynamic>(),
      isEdited: fields[10] as bool,
      editedAt: fields[11] as DateTime?,
      reactions: (fields[12] as List).cast<String>(),
    );
  }

  @override
  void write(BinaryWriter writer, ChatMessage obj) {
    writer
      ..writeByte(13)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.content)
      ..writeByte(2)
      ..write(obj.senderId)
      ..writeByte(3)
      ..write(obj.senderName)
      ..writeByte(4)
      ..write(obj.senderAvatarUrl)
      ..writeByte(5)
      ..write(obj.timestamp)
      ..writeByte(6)
      ..write(obj.isUser)
      ..writeByte(7)
      ..write(obj.type)
      ..writeByte(8)
      ..write(obj.channelId)
      ..writeByte(9)
      ..write(obj.metadata)
      ..writeByte(10)
      ..write(obj.isEdited)
      ..writeByte(11)
      ..write(obj.editedAt)
      ..writeByte(12)
      ..write(obj.reactions);
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
        return MessageType.video;
      case 3:
        return MessageType.audio;
      case 4:
        return MessageType.file;
      case 5:
        return MessageType.system;
      case 6:
        return MessageType.betting;
      case 7:
        return MessageType.prediction;
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
      case MessageType.video:
        writer.writeByte(2);
        break;
      case MessageType.audio:
        writer.writeByte(3);
        break;
      case MessageType.file:
        writer.writeByte(4);
        break;
      case MessageType.system:
        writer.writeByte(5);
        break;
      case MessageType.betting:
        writer.writeByte(6);
        break;
      case MessageType.prediction:
        writer.writeByte(7);
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
