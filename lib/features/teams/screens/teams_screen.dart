import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:volleystats/features/teams/widgets/team_form.dart';
import 'package:volleystats/features/teams/widgets/team_list.dart';
import 'package:volleystats/features/teams/widgets/team_player_selector.dart';
import 'package:volleystats/features/teams/models/team.dart';
import 'package:volleystats/features/teams/providers/teams_provider.dart';

class TeamsScreen extends ConsumerStatefulWidget {
  const TeamsScreen({super.key});

  @override
  ConsumerState<TeamsScreen> createState() => _TeamsScreenState();
}

class _TeamsScreenState extends ConsumerState<TeamsScreen> {
  bool _showForm = false;
  String? _selectedTeamId;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

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
                  Icons.group,
                  size: 32,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 12),
                Text(
                  'Teams',
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Left side: Team list
                Expanded(
                  flex: 2,
                  child: Column(
                    children: [
                      // Create team button
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
                        child: SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: () {
                            setState(() {
                              _showForm = true;
                              _selectedTeamId = null;
                            });
                            },
                            icon: const Icon(Icons.add),
                            label: const Text(
                              'Create New Team',
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              backgroundColor: theme.colorScheme.primary,
                              foregroundColor: theme.colorScheme.onPrimary,
                            ),
                          ),
                        ),
                      ),
                      // Team list
                      Expanded(
                        child: TeamList(
                          onTeamSelected: (team) {
                            setState(() {
                              _selectedTeamId = team.id;
                              _showForm = false;
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                // Divider
                Container(
                  width: 1,
                  color: theme.dividerColor,
                ),
                // Right side: Form or player selector
                Expanded(
                  flex: 3,
                  child: _showForm
                      ? SingleChildScrollView(
                          child: Column(
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
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        'Create New Team',
                                        style: theme.textTheme.titleLarge?.copyWith(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.close),
                                      onPressed: () {
                                        setState(() {
                                          _showForm = false;
                                          _selectedTeamId = null;
                                        });
                                      },
                                    ),
                                  ],
                                ),
                              ),
                              TeamForm(
                                onTeamAdded: () {
                                  setState(() {
                                    _showForm = false;
                                    _selectedTeamId = null;
                                  });
                                },
                              ),
                            ],
                          ),
                        )
                      : _selectedTeamId != null
                          ? Builder(
                              builder: (context) {
                                final teams = ref.watch(teamsProvider);
                                final selectedTeam = teams.firstWhere(
                                  (t) => t.id == _selectedTeamId,
                                  orElse: () => Team(
                                    id: _selectedTeamId!,
                                    name: 'Unknown',
                                    playerIds: [],
                                    createdAt: DateTime.now(),
                                  ),
                                );

                                return SingleChildScrollView(
                                  child: Column(
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
                                        child: Row(
                                          children: [
                                            Expanded(
                                              child: Text(
                                                selectedTeam.name,
                                                style: theme.textTheme.titleLarge?.copyWith(
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                            IconButton(
                                              icon: const Icon(Icons.close),
                                              onPressed: () {
                                                setState(() {
                                                  _selectedTeamId = null;
                                                });
                                              },
                                            ),
                                          ],
                                        ),
                                      ),
                                      TeamPlayerSelector(team: selectedTeam),
                                    ],
                                  ),
                                );
                              },
                            )
                          : Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.group_outlined,
                                    size: 64,
                                    color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    'No team selected',
                                    style: theme.textTheme.titleLarge?.copyWith(
                                      color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Create a new team or select an existing one',
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

