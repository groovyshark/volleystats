import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:volleystats/features/teams/models/team.dart';
import 'package:volleystats/features/teams/providers/teams_provider.dart';
import 'package:volleystats/features/players/providers/players_provider.dart';

class TeamList extends ConsumerWidget {
  final Function(Team) onTeamSelected;
  final VoidCallback onAddTeamPressed;

  const TeamList({
    super.key,
    required this.onTeamSelected,
    required this.onAddTeamPressed,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final teams = ref.watch(teamsProvider);
    final players = ref.watch(playersProvider);
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Column(
      children: [
        Expanded(
          child: teams.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.group_outlined,
                        size: 64,
                        color: colors.onSurface.withValues(alpha: 0.5),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No teams yet',
                        style: theme.textTheme.titleLarge?.copyWith(
                          color: colors.onSurface.withValues(alpha: 0.7),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Create your first team using the button below',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: colors.onSurface.withValues(alpha: 0.5),
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: teams.length,
                  itemBuilder: (context, index) {
                    final team = teams[index];
                    final teamPlayers = players
                        .where((p) => team.playerIds.contains(p.id))
                        .toList();

                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: InkWell(
                        onTap: () => onTeamSelected(team),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  CircleAvatar(
                                    backgroundColor: colors.primaryContainer,
                                    child: Icon(
                                      Icons.group,
                                      color: colors.onPrimaryContainer,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      team.name,
                                      style: TextStyle(
                                        color: colors.onSurface,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18,
                                      ),
                                    ),
                                  ),
                                  IconButton(
                                    icon: Icon(
                                      Icons.delete_outline,
                                      color: colors.error,
                                    ),
                                    onPressed: () {
                                      showDialog(
                                        context: context,
                                        builder: (context) => AlertDialog(
                                          title: const Text('Delete Team'),
                                          content: Text(
                                            'Are you sure you want to delete ${team.name}?',
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
                                                      teamsProvider.notifier,
                                                    )
                                                    .removeTeam(team.id);
                                                Navigator.of(context).pop();

                                                ScaffoldMessenger.of(
                                                  context,
                                                ).clearSnackBars();
                                                ScaffoldMessenger.of(
                                                  context,
                                                ).showSnackBar(
                                                  SnackBar(
                                                    backgroundColor: Theme.of(
                                                      context,
                                                    ).colorScheme.error,
                                                    content: Text(
                                                      '${team.name} deleted',
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
                              const SizedBox(height: 12),
                              if (teamPlayers.isEmpty)
                                Text(
                                  'No players added',
                                  style: TextStyle(
                                    color: colors.onSurface.withValues(
                                      alpha: 0.6,
                                    ),
                                    fontStyle: FontStyle.italic,
                                  ),
                                )
                              else
                                Wrap(
                                  spacing: 8,
                                  runSpacing: 8,
                                  children: teamPlayers.map((player) {
                                    return Chip(
                                      avatar: CircleAvatar(
                                        backgroundColor:
                                            colors.primaryContainer,
                                        child: Text(
                                          player.number?.toString() ??
                                              player.name[0].toUpperCase(),
                                          style: TextStyle(
                                            color: colors.onPrimaryContainer,
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      label: Text(player.name),
                                      backgroundColor:
                                          colors.surfaceContainerHighest,
                                    );
                                  }).toList(),
                                ),
                              const SizedBox(height: 8),
                              Text(
                                '${teamPlayers.length} player${teamPlayers.length != 1 ? 's' : ''}',
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
                      ),
                    );
                  },
                ),
        ),
        // Add new team button
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: theme.colorScheme.surface),
          child: SizedBox(
            height: 56.0,
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: onAddTeamPressed,
              icon: const Icon(Icons.add),
              label: const Text(
                'Create New Team',
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
