import 'package:hive/hive.dart';

part 'player.g.dart';

@HiveType(typeId: 0)
class Player extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final int? number;

  @HiveField(3)
  final String? position;

  @HiveField(4)
  final DateTime createdAt;

  Player({
    required this.id,
    required this.name,
    this.number,
    this.position,
    required this.createdAt,
  });

  Player copyWith({
    String? id,
    String? name,
    int? number,
    String? position,
    DateTime? createdAt,
  }) {
    return Player(
      id: id ?? this.id,
      name: name ?? this.name,
      number: number ?? this.number,
      position: position ?? this.position,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

typedef Players = List<Player>;