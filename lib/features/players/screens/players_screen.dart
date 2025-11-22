import 'package:flutter/material.dart';
import 'package:volleystats/features/players/models/player.dart';
import 'package:volleystats/features/players/widgets/player_form.dart';
import 'package:volleystats/features/players/widgets/player_list_with_search.dart';

class PlayersScreen extends StatefulWidget {
  const PlayersScreen({super.key});

  @override
  State<PlayersScreen> createState() => _PlayersScreenState();
}

class _PlayersScreenState extends State<PlayersScreen> {
  bool _showForm = false;
  Player? _selectedPlayer;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final text = theme.textTheme;

    return Scaffold(
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(24.0),
            child: Row(
              children: [
                Icon(Icons.people, size: 40, color: colors.primary),
                const SizedBox(width: 12),
                Text(
                  'Manage Players',
                  style: text.headlineLarge?.copyWith(
                    color: colors.onSurface,
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
                // Left side: Player list with search
                Expanded(
                  flex: 1,
                  child: PlayerListWithSearch(
                    onAddPlayerPressed: () {
                      setState(() {
                        _selectedPlayer = null;
                        _showForm = true;
                      });
                    },
                    onPlayerSelected: (player) {
                      setState(() {
                        _selectedPlayer = player;
                        _showForm = true;
                      });
                    },
                  ),
                ),

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
                                    _selectedPlayer != null
                                        ? 'Edit Player'
                                        : 'Add New Player',
                                    textAlign: TextAlign.center,
                                    style: theme.textTheme.titleLarge?.copyWith(
                                      color: colors.onSurface,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.close),
                                  onPressed: () {
                                    setState(() {
                                      _showForm = false;
                                      _selectedPlayer = null;
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
                              child: PlayerForm(
                                player: _selectedPlayer,
                                onPlayerSaved: () {
                                  setState(() {
                                    _showForm = false;
                                    _selectedPlayer = null;
                                  });
                                },
                                onPlayerDeleted: () {
                                  setState(() {
                                    _showForm = false;
                                    _selectedPlayer = null;
                                  });
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
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
                            Icons.person_add_outlined,
                            size: 64,
                            color: theme.colorScheme.onSurface.withValues(
                              alpha: 0.5,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No form selected',
                            style: theme.textTheme.titleLarge?.copyWith(
                              color: theme.colorScheme.onSurface.withValues(
                                alpha: 0.7,
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Click "Add New Player" to start',
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
