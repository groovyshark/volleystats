import 'package:hive/hive.dart';

part 'team.g.dart';

@HiveType(typeId: 1)
class Team extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final List<String> playerIds;

  @HiveField(3)
  final DateTime createdAt;

  Team({
    required this.id,
    required this.name,
    required this.playerIds,
    required this.createdAt,
  });

  Team copyWith({
    String? id,
    String? name,
    List<String>? playerIds,
    DateTime? createdAt,
  }) {
    return Team(
      id: id ?? this.id,
      name: name ?? this.name,
      playerIds: playerIds ?? this.playerIds,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

