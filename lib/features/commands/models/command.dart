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
  final DateTime createdAt;

  Command({
    required this.id,
    required this.name,
    this.description = '',
    required this.createdAt,
  });

  Command copyWith({
    String? id,
    String? name,
    String? description,
    DateTime? createdAt,
  }) {
    return Command(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

typedef Commands = List<Command>;
