import 'package:volleystats/features/commands/models/command.dart';
import 'package:volleystats/features/players/models/player.dart';

class CommandParser {
  static CommandParseResult parseCommand(
    String input,
    List<Player> players,
    List<Command> availableCommands,
  ) {
    if (input.trim().isEmpty) {
      return CommandParseResult(
        success: false,
        error: 'Command cannot be empty',
      );
    }

    final parts = input.trim().split(RegExp(r'\s+'));
    
    if (parts.length < 2) {
      return CommandParseResult(
        success: false,
        error: 'Command must have at least 2 parts: <player> <action> [result]',
      );
    }

    final playerIdentifier = parts[0];
    final action = parts[1].toLowerCase();
    final result = parts.length > 2 ? parts[2] : '+';

    // Validate action against available commands
    final validActions = availableCommands.map((c) => c.name).toList();
    if (!validActions.contains(action)) {
      return CommandParseResult(
        success: false,
        error: 'Invalid action: $action. Valid actions: ${validActions.join(", ")}',
      );
    }

    // Try to find player by jersey number or name
    Player? player;
    final jerseyNumber = int.tryParse(playerIdentifier);
    
    try {
      if (jerseyNumber != null) {
        player = players.firstWhere(
          (p) => p.number == jerseyNumber,
        );
      } else {
        player = players.firstWhere(
          (p) => p.name.toLowerCase() == playerIdentifier.toLowerCase(),
        );
      }
    } catch (e) {
      return CommandParseResult(
        success: false,
        error: 'Player not found: $playerIdentifier',
      );
    }

    return CommandParseResult(
      success: true,
      playerIdentifier: playerIdentifier,
      action: action,
      result: result,
      player: player,
      rawCommand: input.trim(),
    );
  }
}

class CommandParseResult {
  final bool success;
  final String? playerIdentifier;
  final String? action;
  final String? result;
  final Player? player;
  final String? error;
  final String? rawCommand;

  CommandParseResult({
    required this.success,
    this.playerIdentifier,
    this.action,
    this.result,
    this.player,
    this.error,
    this.rawCommand,
  });
}

