import 'package:hive/hive.dart';

part 'match.g.dart';

@HiveType(typeId: 4)
class Match extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final List<String> teamIds;

  @HiveField(3)
  final List<String> playerIds;

  @HiveField(4)
  final DateTime createdAt;

  @HiveField(5)
  final DateTime? startedAt;

  @HiveField(6)
  final DateTime? endedAt;

  Match({
    required this.id,
    required this.name,
    required this.teamIds,
    required this.playerIds,
    required this.createdAt,
    this.startedAt,
    this.endedAt,
  });

  Match copyWith({
    String? id,
    String? name,
    List<String>? teamIds,
    List<String>? playerIds,
    DateTime? createdAt,
    DateTime? startedAt,
    DateTime? endedAt,
  }) {
    return Match(
      id: id ?? this.id,
      name: name ?? this.name,
      teamIds: teamIds ?? this.teamIds,
      playerIds: playerIds ?? this.playerIds,
      createdAt: createdAt ?? this.createdAt,
      startedAt: startedAt ?? this.startedAt,
      endedAt: endedAt ?? this.endedAt,
    );
  }

  bool get isActive => startedAt != null && endedAt == null;
  bool get isFinished => endedAt != null;
}

