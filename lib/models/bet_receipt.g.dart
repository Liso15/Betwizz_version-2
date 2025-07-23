// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'bet_receipt.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class BetReceiptAdapter extends TypeAdapter<BetReceipt> {
  @override
  final int typeId = 3;

  @override
  BetReceipt read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return BetReceipt(
      id: fields[0] as String,
      bookmaker: fields[1] as String,
      betType: fields[2] as String,
      stakeAmount: fields[3] as double,
      odds: fields[4] as double,
      winAmount: fields[5] as double?,
      isWin: fields[6] as bool,
      dateTime: fields[7] as DateTime,
      imageUrl: fields[8] as String?,
      description: fields[9] as String?,
      selections: (fields[10] as List).cast<BetSelection>(),
      status: fields[11] as ReceiptStatus,
      referenceNumber: fields[12] as String?,
      metadata: (fields[13] as Map?)?.cast<String, dynamic>(),
    );
  }

  @override
  void write(BinaryWriter writer, BetReceipt obj) {
    writer
      ..writeByte(14)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.bookmaker)
      ..writeByte(2)
      ..write(obj.betType)
      ..writeByte(3)
      ..write(obj.stakeAmount)
      ..writeByte(4)
      ..write(obj.odds)
      ..writeByte(5)
      ..write(obj.winAmount)
      ..writeByte(6)
      ..write(obj.isWin)
      ..writeByte(7)
      ..write(obj.dateTime)
      ..writeByte(8)
      ..write(obj.imageUrl)
      ..writeByte(9)
      ..write(obj.description)
      ..writeByte(10)
      ..write(obj.selections)
      ..writeByte(11)
      ..write(obj.status)
      ..writeByte(12)
      ..write(obj.referenceNumber)
      ..writeByte(13)
      ..write(obj.metadata);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BetReceiptAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class BetSelectionAdapter extends TypeAdapter<BetSelection> {
  @override
  final int typeId = 4;

  @override
  BetSelection read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return BetSelection(
      id: fields[0] as String,
      event: fields[1] as String,
      selection: fields[2] as String,
      odds: fields[3] as double,
      result: fields[4] as String?,
      isWin: fields[5] as bool?,
    );
  }

  @override
  void write(BinaryWriter writer, BetSelection obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.event)
      ..writeByte(2)
      ..write(obj.selection)
      ..writeByte(3)
      ..write(obj.odds)
      ..writeByte(4)
      ..write(obj.result)
      ..writeByte(5)
      ..write(obj.isWin);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BetSelectionAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class ReceiptStatusAdapter extends TypeAdapter<ReceiptStatus> {
  @override
  final int typeId = 5;

  @override
  ReceiptStatus read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return ReceiptStatus.pending;
      case 1:
        return ReceiptStatus.verified;
      case 2:
        return ReceiptStatus.settled;
      case 3:
        return ReceiptStatus.cancelled;
      case 4:
        return ReceiptStatus.error;
      default:
        return ReceiptStatus.pending;
    }
  }

  @override
  void write(BinaryWriter writer, ReceiptStatus obj) {
    switch (obj) {
      case ReceiptStatus.pending:
        writer.writeByte(0);
        break;
      case ReceiptStatus.verified:
        writer.writeByte(1);
        break;
      case ReceiptStatus.settled:
        writer.writeByte(2);
        break;
      case ReceiptStatus.cancelled:
        writer.writeByte(3);
        break;
      case ReceiptStatus.error:
        writer.writeByte(4);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ReceiptStatusAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
