import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:data_table_2/data_table_2.dart';
import 'package:volleystats/features/matches/providers/match_stats_provider.dart';
import 'package:volleystats/features/players/providers/players_provider.dart';
import 'package:volleystats/features/players/models/player.dart';
import 'package:volleystats/features/matches/models/match.dart';
import 'package:volleystats/features/matches/providers/matches_provider.dart';
import 'package:volleystats/features/teams/providers/teams_provider.dart';

class LiveResultsTable extends ConsumerWidget {
  final String matchId;

  const LiveResultsTable({super.key, required this.matchId});

  Map<String, Map<String, int>> _calculateStats(
    List<dynamic> stats,
    List<Player> players,
  ) {
    final playerStats = <String, Map<String, int>>{};

    for (final stat in stats) {
      final playerId = stat.playerId;
      final action = stat.action;
      final result = stat.result;

      if (!playerStats.containsKey(playerId)) {
        playerStats[playerId] = {};
      }

      // Count actions
      playerStats[playerId]![action] =
          (playerStats[playerId]![action] ?? 0) + 1;

      // Count positive/negative results
      if (result.startsWith('+')) {
        playerStats[playerId]!['${action}_positive'] =
            (playerStats[playerId]!['${action}_positive'] ?? 0) + 1;
      } else if (result.startsWith('-')) {
        playerStats[playerId]!['${action}_negative'] =
            (playerStats[playerId]!['${action}_negative'] ?? 0) + 1;
      }
    }

    return playerStats;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stats = ref.watch(matchStatsProvider);
    final players = ref.watch(playersProvider);
    final matches = ref.watch(matchesProvider);
    final teams = ref.watch(teamsProvider);
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    final match = matches.firstWhere(
      (m) => m.id == matchId,
      orElse: () => Match(
        id: matchId,
        name: 'Unknown',
        teamIds: [],
        playerIds: [],
        createdAt: DateTime.now(),
      ),
    );

    // Get players in this match
    final matchPlayerIds = <String>{};
    // Add directly selected players
    matchPlayerIds.addAll(match.playerIds);
    // Add players from selected teams
    for (final teamId in match.teamIds) {
      try {
        final team = teams.firstWhere((t) => t.id == teamId);
        matchPlayerIds.addAll(team.playerIds);
      } catch (e) {
        // Team not found, skip it
      }
    }

    final matchPlayers = players
        .where((p) => matchPlayerIds.contains(p.id))
        .toList();

    // If no players, show all players (for stats that might have been recorded)
    final displayPlayers = matchPlayers.isEmpty ? players : matchPlayers;

    final playerStats = _calculateStats(stats, displayPlayers);
    final allActions = <String>{};
    for (final stat in stats) {
      allActions.add(stat.action);
    }
    final sortedActions = allActions.toList()..sort();

    if (displayPlayers.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.table_chart_outlined,
              size: 64,
              color: colors.onSurface.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'No players in match',
              style: theme.textTheme.titleLarge?.copyWith(
                color: colors.onSurface.withValues(alpha: 0.7),
              ),
            ),
          ],
        ),
      );
    }

    return DataTable2(
      headingRowColor: WidgetStateProperty.all(colors.surfaceContainerHighest),
      columnSpacing: 12,
      horizontalMargin: 12,
      minWidth: 600,
      columns: [
        DataColumn2(
          label: Text(
            'Player',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: colors.onSurface,
            ),
          ),
          size: ColumnSize.L,
        ),
        ...sortedActions.map((action) {
          return DataColumn2(
            label: Text(
              action.toUpperCase(),
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: colors.onSurface,
              ),
            ),
            size: ColumnSize.S,
          );
        }),
        DataColumn2(
          label: Text(
            'Total',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: colors.onSurface,
            ),
          ),
          size: ColumnSize.S,
        ),
      ],
      rows: displayPlayers.map((player) {
        final stats = playerStats[player.id] ?? {};
        final rowData = <String, int>{};
        int total = 0;

        for (final action in sortedActions) {
          final count = stats[action] ?? 0;
          rowData[action] = count;
          total += count;
        }

        return DataRow2(
          cells: [
            DataCell(
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircleAvatar(
                    radius: 16,
                    backgroundColor: colors.primaryContainer,
                    child: Text(
                      player.number?.toString() ?? player.name[0].toUpperCase(),
                      style: TextStyle(
                        color: colors.onPrimaryContainer,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    player.name,
                    style: TextStyle(color: colors.onSurface, fontSize: 16),
                  ),
                ],
              ),
            ),
            ...sortedActions.map((action) {
              final count = rowData[action] ?? 0;
              return DataCell(
                Text(
                  count.toString(),
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: count > 0 ? FontWeight.bold : FontWeight.normal,
                    color: count > 0
                        ? colors.secondary
                        : colors.onSurface.withValues(alpha: 0.5),
                  ),
                ),
              );
            }),
            DataCell(
              Text(
                total.toString(),
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: colors.primary,
                ),
              ),
            ),
          ],
        );
      }).toList(),
    );
  }
}
