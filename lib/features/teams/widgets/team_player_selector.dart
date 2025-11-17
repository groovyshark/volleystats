import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:volleystats/features/teams/models/team.dart';
import 'package:volleystats/features/teams/providers/teams_provider.dart';
import 'package:volleystats/features/players/providers/players_provider.dart';
import 'package:volleystats/features/players/models/player.dart';

class TeamPlayerSelector extends ConsumerWidget {
  final Team team;

  const TeamPlayerSelector({
    super.key,
    required this.team,
  });

  Map<String, List<Player>> _groupPlayersByPosition(List<Player> players) {
    final grouped = <String, List<Player>>{};
    for (final player in players) {
      final position = player.position ?? 'No Position';
      grouped.putIfAbsent(position, () => []).add(player);
    }
    // Sort positions alphabetically, but put "No Position" at the end
    final sortedKeys = grouped.keys.toList()
      ..sort((a, b) {
        if (a == 'No Position') return 1;
        if (b == 'No Position') return -1;
        return a.compareTo(b);
      });
    return Map.fromEntries(
      sortedKeys.map((key) => MapEntry(key, grouped[key]!)),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final players = ref.watch(playersProvider);
    final teams = ref.watch(teamsProvider);
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    // Get the latest team data from the provider
    final currentTeam = teams.firstWhere(
      (t) => t.id == team.id,
      orElse: () => team,
    );

    final teamPlayers = players.where((p) => currentTeam.playerIds.contains(p.id)).toList();
    final availablePlayers = players.where((p) => !currentTeam.playerIds.contains(p.id)).toList();

    final groupedTeamPlayers = _groupPlayersByPosition(teamPlayers);
    final groupedAvailablePlayers = _groupPlayersByPosition(availablePlayers);

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Manage Players',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),
          if (teamPlayers.isNotEmpty) ...[
            Text(
              'Team Players',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ...groupedTeamPlayers.entries.map((entry) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.sports_volleyball,
                          size: 18,
                          color: colors.primary,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          entry.key,
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: colors.primary,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '(${entry.value.length})',
                          style: theme.textTheme.titleSmall?.copyWith(
                            color: colors.onSurface.withValues(alpha: 0.6),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: entry.value.map((player) {
                        return Chip(
                          avatar: CircleAvatar(
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
                          label: Text(player.name),
                          deleteIcon: Icon(
                            Icons.close,
                            size: 18,
                            color: colors.error,
                          ),
                          onDeleted: () {
                            ref.read(teamsProvider.notifier).removePlayerFromTeam(currentTeam.id, player.id);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                backgroundColor: colors.error,
                                content: Text('${player.name} removed from team'),
                                duration: const Duration(seconds: 1),
                              ),
                            );
                          },
                          backgroundColor: colors.primaryContainer.withValues(alpha: 0.3),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              );
            }),
            const SizedBox(height: 24),
          ],
          if (availablePlayers.isNotEmpty) ...[
            Text(
              'Available Players',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ...groupedAvailablePlayers.entries.map((entry) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.sports_volleyball,
                          size: 18,
                          color: colors.onSurface.withValues(alpha: 0.7),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          entry.key,
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: colors.onSurface.withValues(alpha: 0.8),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '(${entry.value.length})',
                          style: theme.textTheme.titleSmall?.copyWith(
                            color: colors.onSurface.withValues(alpha: 0.6),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: entry.value.map((player) {
                        return FilterChip(
                          avatar: CircleAvatar(
                            backgroundColor: colors.surfaceContainerHighest,
                            child: Text(
                              player.number?.toString() ?? player.name[0].toUpperCase(),
                              style: TextStyle(
                                color: colors.onSurface,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          label: Text(player.name),
                          selected: false,
                          onSelected: (selected) {
                            if (selected) {
                              ref.read(teamsProvider.notifier).addPlayerToTeam(currentTeam.id, player.id);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  backgroundColor: colors.primary,
                                  content: Text('${player.name} added to team'),
                                  duration: const Duration(seconds: 1),
                                ),
                              );
                            }
                          },
                        );
                      }).toList(),
                    ),
                  ],
                ),
              );
            }),
          ] else if (players.isEmpty) ...[
            Center(
              child: Column(
                children: [
                  Icon(
                    Icons.person_outline,
                    size: 48,
                    color: colors.onSurface.withValues(alpha: 0.5),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'No players available',
                    style: TextStyle(
                      color: colors.onSurface.withValues(alpha: 0.7),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Add players first',
                    style: TextStyle(
                      color: colors.onSurface.withValues(alpha: 0.5),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ] else ...[
            Center(
              child: Text(
                'All players are already in this team',
                style: TextStyle(
                  color: colors.onSurface.withValues(alpha: 0.7),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

