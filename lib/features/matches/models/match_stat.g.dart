// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'match_stat.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class MatchStatAdapter extends TypeAdapter<MatchStat> {
  @override
  final int typeId = 3;

  @override
  MatchStat read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return MatchStat(
      id: fields[0] as String,
      matchId: fields[1] as String,
      playerId: fields[2] as String,
      action: fields[3] as String,
      result: fields[4] as String,
      timestamp: fields[5] as DateTime,
      rawCommand: fields[6] as String,
    );
  }

  @override
  void write(BinaryWriter writer, MatchStat obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.matchId)
      ..writeByte(2)
      ..write(obj.playerId)
      ..writeByte(3)
      ..write(obj.action)
      ..writeByte(4)
      ..write(obj.result)
      ..writeByte(5)
      ..write(obj.timestamp)
      ..writeByte(6)
      ..write(obj.rawCommand);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MatchStatAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
