import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:volleystats/features/matches/providers/matches_provider.dart';
import 'package:volleystats/features/teams/providers/teams_provider.dart';
import 'package:volleystats/features/players/providers/players_provider.dart';

class MatchList extends ConsumerWidget {
  final VoidCallback onAddMatchPressed;

  const MatchList({super.key, required this.onAddMatchPressed});

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final matches = ref.watch(matchesProvider);
    final teams = ref.watch(teamsProvider);
    final players = ref.watch(playersProvider);
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Column(
      children: [
        Expanded(
          child: matches.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.sports_volleyball_outlined,
                        size: 64,
                        color: colors.onSurface.withValues(alpha: 0.5),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No matches yet',
                        style: theme.textTheme.titleLarge?.copyWith(
                          color: colors.onSurface.withValues(alpha: 0.7),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Create a new match to start',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: colors.onSurface.withValues(alpha: 0.5),
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: matches.length,
                  itemBuilder: (context, index) {
                    final match = matches[index];
                    final matchTeams = teams
                        .where((t) => match.teamIds.contains(t.id))
                        .toList();
                    final matchPlayers = players
                        .where((p) => match.playerIds.contains(p.id))
                        .toList();

                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: InkWell(
                        onTap: () {
                          if (!match.isFinished) {
                            ref
                                .read(matchesProvider.notifier)
                                .startMatch(match.id);
                          }
                          context.push('/match/${match.id}');
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  CircleAvatar(
                                    backgroundColor: match.isActive
                                        ? Colors.green
                                        : match.isFinished
                                        ? colors.surfaceContainerHighest
                                        : colors.primaryContainer,
                                    child: Icon(
                                      match.isActive
                                          ? Icons.play_circle
                                          : match.isFinished
                                          ? Icons.check_circle
                                          : Icons.sports_volleyball,
                                      color: match.isActive || match.isFinished
                                          ? Colors.white
                                          : colors.onPrimaryContainer,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          match.name,
                                          style: TextStyle(
                                            color: colors.onSurface,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 18,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          'Created: ${_formatDate(match.createdAt)}',
                                          style: TextStyle(
                                            color: colors.onSurface.withValues(
                                              alpha: 0.7,
                                            ),
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 6,
                                    ),
                                    decoration: BoxDecoration(
                                      color: match.isActive
                                          ? Colors.green.withValues(alpha: 0.2)
                                          : match.isFinished
                                          ? colors.surfaceContainerHighest
                                          : colors.primaryContainer,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      match.isActive
                                          ? 'Active'
                                          : match.isFinished
                                          ? 'Finished'
                                          : 'Not Started',
                                      style: TextStyle(
                                        color: match.isActive
                                            ? Colors.green
                                            : match.isFinished
                                            ? colors.onSurface.withValues(
                                                alpha: 0.7,
                                              )
                                            : colors.onPrimaryContainer,
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  IconButton(
                                    icon: Icon(
                                      Icons.delete_outline,
                                      color: colors.error,
                                    ),
                                    onPressed: () {
                                      showDialog(
                                        context: context,
                                        builder: (context) => AlertDialog(
                                          title: const Text('Delete Match'),
                                          content: Text(
                                            'Are you sure you want to delete "${match.name}"?',
                                          ),
                                          actions: [
                                            TextButton(
                                              onPressed: () =>
                                                  Navigator.of(context).pop(),
                                              child: const Text('Cancel'),
                                            ),
                                            TextButton(
                                              onPressed: () {
                                                ref
                                                    .read(
                                                      matchesProvider.notifier,
                                                    )
                                                    .removeMatch(match.id);
                                                Navigator.of(context).pop();
                                                ScaffoldMessenger.of(
                                                  context,
                                                ).showSnackBar(
                                                  SnackBar(
                                                    content: Text(
                                                      'Match "${match.name}" deleted',
                                                    ),
                                                    duration: const Duration(
                                                      seconds: 1,
                                                    ),
                                                  ),
                                                );
                                              },
                                              style: TextButton.styleFrom(
                                                foregroundColor: colors.error,
                                              ),
                                              child: const Text('Delete'),
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                  ),
                                ],
                              ),
                              if (matchTeams.isNotEmpty ||
                                  matchPlayers.isNotEmpty) ...[
                                const SizedBox(height: 12),
                                Wrap(
                                  spacing: 8,
                                  runSpacing: 8,
                                  children: [
                                    ...matchTeams.map((team) {
                                      return Chip(
                                        avatar: const Icon(
                                          Icons.group,
                                          size: 18,
                                        ),
                                        label: Text(team.name),
                                        backgroundColor:
                                            colors.primaryContainer,
                                      );
                                    }),
                                    ...matchPlayers.map((player) {
                                      return Chip(
                                        avatar: CircleAvatar(
                                          backgroundColor:
                                              colors.surfaceContainerHighest,
                                          radius: 12,
                                          child: Text(
                                            player.number?.toString() ??
                                                player.name[0].toUpperCase(),
                                            style: const TextStyle(
                                              fontSize: 10,
                                            ),
                                          ),
                                        ),
                                        label: Text(player.name),
                                        backgroundColor:
                                            colors.surfaceContainerHighest,
                                      );
                                    }),
                                  ],
                                ),
                              ],
                              if (match.isActive) ...[
                                const SizedBox(height: 12),
                                SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton.icon(
                                    onPressed: () {
                                      context.push('/match/${match.id}');
                                    },
                                    icon: const Icon(Icons.play_arrow),
                                    label: const Text('Continue Match'),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.green,
                                      foregroundColor: Colors.white,
                                    ),
                                  ),
                                ),
                              ] else if (!match.isFinished) ...[
                                const SizedBox(height: 12),
                                SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton.icon(
                                    onPressed: () {
                                      ref
                                          .read(matchesProvider.notifier)
                                          .startMatch(match.id);
                                      context.push('/match/${match.id}');
                                    },
                                    icon: const Icon(Icons.play_arrow),
                                    label: const Text('Start Match'),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: colors.primaryContainer,
                                      foregroundColor:
                                          colors.onPrimaryContainer,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
        ),
        // Add new match button
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: theme.colorScheme.surface),
          child: SizedBox(
            height: 56.0,
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: onAddMatchPressed,
              icon: const Icon(Icons.add),
              label: const Text(
                'New Match',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadiusGeometry.circular(12.0),
                ),
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: colors.primaryContainer,
                foregroundColor: colors.onPrimaryContainer,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
