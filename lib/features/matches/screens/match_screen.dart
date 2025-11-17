import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:volleystats/features/matches/models/match_stat.dart';
import 'package:volleystats/features/matches/providers/match_stats_provider.dart';
import 'package:volleystats/features/matches/providers/matches_provider.dart';
import 'package:volleystats/features/commands/utils/command_parser.dart';
import 'package:volleystats/features/commands/providers/commands_provider.dart';
import 'package:volleystats/features/players/providers/players_provider.dart';
import 'package:volleystats/features/matches/widgets/match_stat_list.dart';
import 'package:volleystats/features/matches/widgets/live_results_table.dart';

class MatchScreen extends ConsumerStatefulWidget {
  final String matchId;

  const MatchScreen({
    super.key,
    required this.matchId,
  });

  @override
  ConsumerState<MatchScreen> createState() => _MatchScreenState();
}

class _MatchScreenState extends ConsumerState<MatchScreen> {
  final _commandController = TextEditingController();
  final _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    // Set the match ID in the provider
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(matchStatsProvider.notifier).setMatchId(widget.matchId);
    });
  }

  @override
  void dispose() {
    _commandController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _submitCommand() {
    final input = _commandController.text.trim();
    if (input.isEmpty) return;

    final players = ref.read(playersProvider);
    final availableCommands = ref.read(commandsProvider);
    final parseResult = CommandParser.parseCommand(input, players, availableCommands);

    if (parseResult.success &&
        parseResult.player != null &&
        parseResult.action != null &&
        parseResult.result != null &&
        parseResult.rawCommand != null) {
      final stat = MatchStat(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        matchId: widget.matchId,
        playerId: parseResult.player!.id,
        action: parseResult.action!,
        result: parseResult.result!,
        timestamp: DateTime.now(),
        rawCommand: parseResult.rawCommand!,
      );

      ref.read(matchStatsProvider.notifier).addStat(stat);
      _commandController.clear();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Stat recorded: ${parseResult.rawCommand}'),
          duration: const Duration(seconds: 1),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(parseResult.error ?? 'Invalid command'),
          duration: const Duration(seconds: 2),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _endMatch() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('End Match'),
        content: const Text('Are you sure you want to end this match?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              ref.read(matchesProvider.notifier).endMatch(widget.matchId);
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Match ended'),
                  duration: Duration(seconds: 1),
                ),
              );
              context.pop();
            },
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('End Match'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final availableCommands = ref.watch(commandsProvider);

    return Scaffold(
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              border: Border(
                bottom: BorderSide(
                  color: theme.dividerColor,
                  width: 1,
                ),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.sports_volleyball,
                  size: 32,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Match',
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: _endMatch,
                  icon: const Icon(Icons.stop_circle),
                  label: const Text('End Match'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                    backgroundColor: colors.error,
                    foregroundColor: colors.onError,
                  ),
                ),
              ],
            ),
          ),
          // Main content area
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Left side: Live results table
                Expanded(
                  flex: 3,
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Live Results',
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Expanded(
                          child: LiveResultsTable(matchId: widget.matchId),
                        ),
                      ],
                    ),
                  ),
                ),
                // Divider
                Container(
                  width: 1,
                  color: theme.dividerColor,
                ),
                // Right side: Recent commands
                Expanded(
                  flex: 2,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surface,
                          border: Border(
                            bottom: BorderSide(
                              color: theme.dividerColor,
                              width: 1,
                            ),
                          ),
                        ),
                        child: Text(
                          'Recent Commands',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Expanded(
                        child: MatchStatList(matchId: widget.matchId),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Command input field at bottom
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              border: Border(
                top: BorderSide(
                  color: theme.dividerColor,
                  width: 1,
                ),
              ),
            ),
            child: Column(
              children: [
                // Help text
                Container(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        size: 16,
                        color: colors.onSurface.withValues(alpha: 0.7),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          availableCommands.isNotEmpty
                              ? 'Syntax: <player> <action> <result> | Available actions: ${availableCommands.map((c) => c.name).join(", ")}'
                              : 'No commands defined. Add commands in the Commands screen first.',
                          style: TextStyle(
                            fontSize: 12,
                            color: colors.onSurface.withValues(alpha: 0.7),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                // Input field
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _commandController,
                        focusNode: _focusNode,
                        decoration: InputDecoration(
                          hintText: 'Enter command (e.g., "1 serve +" or "John dig +-")',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          prefixIcon: const Icon(Icons.edit),
                          filled: true,
                          fillColor: colors.surfaceContainerHighest,
                        ),
                        textInputAction: TextInputAction.send,
                        onSubmitted: (_) => _submitCommand(),
                        inputFormatters: [
                          FilteringTextInputFormatter.deny(RegExp(r'[^\w\s\+\-\d]')),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton.icon(
                      onPressed: _submitCommand,
                      icon: const Icon(Icons.send),
                      label: const Text('Send'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 16,
                        ),
                        backgroundColor: colors.primary,
                        foregroundColor: colors.onPrimary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

