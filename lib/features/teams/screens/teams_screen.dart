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
            padding: const EdgeInsets.all(24.0),
            child: Row(
              children: [
                Icon(Icons.group, size: 40, color: theme.colorScheme.primary),
                const SizedBox(width: 12),
                Text(
                  'Teams',
                  style: theme.textTheme.headlineLarge?.copyWith(
                    color: theme.colorScheme.onSurface,
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
                  flex: 1,
                  child: TeamList(
                    onTeamSelected: (team) {
                      setState(() {
                        _selectedTeamId = team.id;
                        _showForm = false;
                      });
                    },
                    onAddTeamPressed: () {
                      setState(() {
                        _showForm = true;
                        _selectedTeamId = null;
                      });
                    },
                  ),
                ),
                // Right side: Form or player selector
                if (_showForm)
                  Expanded(
                    flex: 2,
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    'Create New Team',
                                    textAlign: TextAlign.center,
                                    style: theme.textTheme.titleLarge?.copyWith(
                                      color: theme.colorScheme.onSurface,
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
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12.0,
                              vertical: 8.0,
                            ),
                            child: Card(
                              child: TeamForm(
                                onTeamAdded: () {
                                  setState(() {
                                    _showForm = false;
                                    _selectedTeamId = null;
                                  });
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                else if (_selectedTeamId != null)
                  Expanded(
                    flex: 2,
                    child: Builder(
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
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        selectedTeam.name,
                                        textAlign: TextAlign.center,
                                        style: theme.textTheme.titleLarge
                                            ?.copyWith(
                                              color:
                                                  theme.colorScheme.onSurface,
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
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12.0,
                                  vertical: 8.0,
                                ),
                                child: Card(
                                  child: TeamPlayerSelector(team: selectedTeam),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  )
                else
                  Expanded(
                    flex: 2,
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.group_outlined,
                            size: 64,
                            color: theme.colorScheme.onSurface.withValues(
                              alpha: 0.5,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No team selected',
                            style: theme.textTheme.titleLarge?.copyWith(
                              color: theme.colorScheme.onSurface.withValues(
                                alpha: 0.7,
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Create a new team or select an existing one',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onSurface.withValues(
                                alpha: 0.5,
                              ),
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
