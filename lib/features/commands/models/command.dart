import 'package:hive/hive.dart';

part 'command.g.dart';

@HiveType(typeId: 2)
class Command extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name; // Command name/template, e.g., "serve", "dig", "hit"

  @HiveField(2)
  final String description; // Optional description

  @HiveField(3)
  final String shortcut; // Shortcut for quick command entry, e.g., "s", "d", "h"

  @HiveField(4)
  final DateTime createdAt;

  Command({
    required this.id,
    required this.name,
    this.description = '',
    this.shortcut = '',
    required this.createdAt,
  });

  Command copyWith({
    String? id,
    String? name,
    String? description,
    String? shortcut,
    DateTime? createdAt,
  }) {
    return Command(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      shortcut: shortcut ?? this.shortcut,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

typedef Commands = List<Command>;
