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
import 'package:volleystats/features/teams/providers/teams_provider.dart';
import 'package:volleystats/features/matches/widgets/match_stat_list.dart';
import 'package:volleystats/features/matches/widgets/live_results_table.dart';
import 'package:volleystats/features/matches/services/match_export_service.dart';
import 'package:volleystats/features/matches/widgets/command_helper.dart';

class MatchScreen extends ConsumerStatefulWidget {
  final String matchId;

  const MatchScreen({super.key, required this.matchId});

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
    final parseResult = CommandParser.parseCommand(
      input,
      players,
      availableCommands,
    );

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
    final colors = Theme.of(context).colorScheme;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('End Match', style: TextStyle(color: colors.onSurface)),
        content: Text(
          'Are you sure you want to end this match?',
          style: TextStyle(color: colors.onSurface),
        ),
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
                SnackBar(
                  backgroundColor: colors.primary,
                  content: Text(
                    'Match ended',
                    style: TextStyle(
                      color: colors.onPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  duration: Duration(seconds: 1),
                ),
              );
              context.pop();
            },
            style: TextButton.styleFrom(foregroundColor: colors.error),
            child: const Text('End Match'),
          ),
        ],
      ),
    );
  }

  void _pauseMatch() {
    context.pop();
  }

  void _goBack() {
    context.pop();
  }

  Future<void> _exportStats() async {
    final matches = ref.read(matchesProvider);
    final stats = ref.read(matchStatsProvider);
    final players = ref.read(playersProvider);
    final teams = ref.read(teamsProvider);

    final match = matches.firstWhere(
      (m) => m.id == widget.matchId,
      orElse: () => throw StateError('Match not found'),
    );

    // Show loading indicator
    if (!mounted) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      // Filter stats for this match
      final matchStats = stats
          .where((s) => s.matchId == widget.matchId)
          .toList();

      final filePath = await MatchExportService.exportMatchStatsToExcel(
        match: match,
        stats: matchStats,
        players: players,
        teams: teams,
      );

      if (!mounted) return;

      Navigator.of(context).pop(); // Close loading dialog

      if (filePath != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Stats exported successfully to: ${filePath.split('/').last}',
            ),
            duration: const Duration(seconds: 3),
            backgroundColor: Colors.green,
            action: SnackBarAction(
              label: 'Open',
              textColor: Colors.white,
              onPressed: () {
                // Optionally open the file
              },
            ),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Export cancelled or failed'),
            duration: Duration(seconds: 2),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;

      Navigator.of(context).pop(); // Close loading dialog

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error exporting stats: $e'),
          duration: const Duration(seconds: 3),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final availableCommands = ref.watch(commandsProvider);
    final matches = ref.watch(matchesProvider);

    final match = matches.firstWhere(
      (m) => m.id == widget.matchId,
      orElse: () => throw StateError('Match not found'),
    );

    final isActive = match.isActive;
    final isFinished = match.isFinished;

    final content = Column(
      children: [
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            border: Border(
              bottom: BorderSide(color: theme.dividerColor, width: 1),
            ),
          ),
          child: Row(
            children: [
              Icon(
                Icons.sports_volleyball,
                size: 32,
                color: theme.colorScheme.primaryContainer,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  match.name,
                  style: theme.textTheme.headlineMedium?.copyWith(
                    color: colors.onSurface,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              if (isActive) ...[
                // Pause button for active match
                ElevatedButton.icon(
                  onPressed: _pauseMatch,
                  icon: const Icon(Icons.pause_circle),
                  label: const Text('Pause'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                    backgroundColor: colors.primaryContainer,
                    foregroundColor: colors.onPrimaryContainer,
                  ),
                ),
                const SizedBox(width: 12),
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
              ] else if (isFinished) ...[
                // Export button for finished match
                ElevatedButton.icon(
                  onPressed: _exportStats,
                  icon: const Icon(Icons.file_download),
                  label: const Text('Export Stats'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                    backgroundColor: colors.primaryContainer,
                    foregroundColor: colors.onPrimaryContainer,
                  ),
                ),
                const SizedBox(width: 12),
                // Back button for finished match
                ElevatedButton.icon(
                  onPressed: _goBack,
                  icon: const Icon(Icons.arrow_back),
                  label: const Text('Back'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                    backgroundColor: colors.primaryContainer,
                    foregroundColor: colors.onPrimaryContainer,
                  ),
                ),
              ],
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
                          color: colors.onSurface,
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

              Container(width: 1, color: theme.dividerColor),

              Expanded(
                flex: 1,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      child: Text(
                        'Recent Commands',
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: colors.onSurface,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Expanded(child: MatchStatList(matchId: widget.matchId)),
                    if (isActive) const CommandHelper(),
                  ],
                ),
              ),
            ],
          ),
        ),
        // Command input field at bottom (only show if match is active)
        if (isActive)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              border: Border(
                top: BorderSide(color: theme.dividerColor, width: 1),
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
                        style: TextStyle(color: colors.onSurface),
                        decoration: InputDecoration(
                          hintText:
                              'Enter command (e.g., "1 serve +" or "John dig +-")',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12.0),
                          ),
                          prefixIcon: const Icon(Icons.edit),
                          filled: true,
                          fillColor: colors.surfaceContainerHighest,
                        ),
                        textInputAction: TextInputAction.send,
                        onSubmitted: (_) => _submitCommand(),
                        inputFormatters: [
                          FilteringTextInputFormatter.deny(
                            RegExp(r'[^\w\s\+\-\d]'),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    SizedBox(
                      height: 48,
                      child: ElevatedButton.icon(
                        onPressed: _submitCommand,
                        icon: const Icon(Icons.send),
                        label: const Text('Send'),
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.all(
                              Radius.circular(12.0),
                            ),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 16,
                          ),
                          backgroundColor: colors.primaryContainer,
                          foregroundColor: colors.onPrimaryContainer,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
      ],
    );

    return Scaffold(body: content);
  }
}
