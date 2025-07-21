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
      userId: fields[1] as String,
      betSlipId: fields[2] as String,
      bookmaker: fields[3] as String,
      totalStake: fields[4] as double,
      potentialWin: fields[5] as double,
      actualWin: fields[6] as double?,
      status: fields[7] as ReceiptStatus,
      selections: (fields[8] as List).cast<BetSelection>(),
      placedAt: fields[9] as DateTime,
      settledAt: fields[10] as DateTime?,
      imageUrl: fields[11] as String?,
      ocrText: fields[12] as String?,
      confidence: fields[13] as double,
      metadata: (fields[14] as Map?)?.cast<String, dynamic>(),
    );
  }

  @override
  void write(BinaryWriter writer, BetReceipt obj) {
    writer
      ..writeByte(15)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.userId)
      ..writeByte(2)
      ..write(obj.betSlipId)
      ..writeByte(3)
      ..write(obj.bookmaker)
      ..writeByte(4)
      ..write(obj.totalStake)
      ..writeByte(5)
      ..write(obj.potentialWin)
      ..writeByte(6)
      ..write(obj.actualWin)
      ..writeByte(7)
      ..write(obj.status)
      ..writeByte(8)
      ..write(obj.selections)
      ..writeByte(9)
      ..write(obj.placedAt)
      ..writeByte(10)
      ..write(obj.settledAt)
      ..writeByte(11)
      ..write(obj.imageUrl)
      ..writeByte(12)
      ..write(obj.ocrText)
      ..writeByte(13)
      ..write(obj.confidence)
      ..writeByte(14)
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
      market: fields[2] as String,
      selection: fields[3] as String,
      odds: fields[4] as double,
      stake: fields[5] as double,
      isWin: fields[6] as bool?,
      sport: fields[7] as String,
      league: fields[8] as String?,
      eventDate: fields[9] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, BetSelection obj) {
    writer
      ..writeByte(10)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.event)
      ..writeByte(2)
      ..write(obj.market)
      ..writeByte(3)
      ..write(obj.selection)
      ..writeByte(4)
      ..write(obj.odds)
      ..writeByte(5)
      ..write(obj.stake)
      ..writeByte(6)
      ..write(obj.isWin)
      ..writeByte(7)
      ..write(obj.sport)
      ..writeByte(8)
      ..write(obj.league)
      ..writeByte(9)
      ..write(obj.eventDate);
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
        return ReceiptStatus.processing;
      case 2:
        return ReceiptStatus.verified;
      case 3:
        return ReceiptStatus.won;
      case 4:
        return ReceiptStatus.lost;
      case 5:
        return ReceiptStatus.void;
      case 6:
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
      case ReceiptStatus.processing:
        writer.writeByte(1);
        break;
      case ReceiptStatus.verified:
        writer.writeByte(2);
        break;
      case ReceiptStatus.won:
        writer.writeByte(3);
        break;
      case ReceiptStatus.lost:
        writer.writeByte(4);
        break;
      case ReceiptStatus.void:
        writer.writeByte(5);
        break;
      case ReceiptStatus.error:
        writer.writeByte(6);
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
