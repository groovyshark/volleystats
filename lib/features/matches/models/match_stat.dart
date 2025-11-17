import 'package:hive/hive.dart';

part 'match_stat.g.dart';

@HiveType(typeId: 3)
class MatchStat extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String matchId;

  @HiveField(2)
  final String playerId;

  @HiveField(3)
  final String action; // dig, hit, serve, set, etc.

  @HiveField(4)
  final String result; // +, -, ++, +-, number, etc.

  @HiveField(5)
  final DateTime timestamp;

  @HiveField(6)
  final String rawCommand; // original command string

  MatchStat({
    required this.id,
    required this.matchId,
    required this.playerId,
    required this.action,
    required this.result,
    required this.timestamp,
    required this.rawCommand,
  });

  MatchStat copyWith({
    String? id,
    String? matchId,
    String? playerId,
    String? action,
    String? result,
    DateTime? timestamp,
    String? rawCommand,
  }) {
    return MatchStat(
      id: id ?? this.id,
      matchId: matchId ?? this.matchId,
      playerId: playerId ?? this.playerId,
      action: action ?? this.action,
      result: result ?? this.result,
      timestamp: timestamp ?? this.timestamp,
      rawCommand: rawCommand ?? this.rawCommand,
    );
  }
}

