import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:volleystats/features/players/models/player.dart';
import 'package:volleystats/features/players/providers/players_provider.dart';

class PlayerListWithSearch extends ConsumerStatefulWidget {
  final VoidCallback onAddPlayerPressed;
  final void Function(Player) onPlayerSelected;

  const PlayerListWithSearch({
    super.key,
    required this.onAddPlayerPressed,
    required this.onPlayerSelected,
  });

  @override
  ConsumerState<PlayerListWithSearch> createState() =>
      _PlayerListWithSearchState();
}

class _PlayerListWithSearchState extends ConsumerState<PlayerListWithSearch> {
  final _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Player> _filterPlayers(List<Player> players, String query) {
    if (query.isEmpty) return players;

    final lowerQuery = query.toLowerCase();
    return players.where((player) {
      final nameMatch = player.name.toLowerCase().contains(lowerQuery);
      final positionMatch =
          player.position?.toLowerCase().contains(lowerQuery) ?? false;
      final numberMatch = player.number?.toString().contains(query) ?? false;
      return nameMatch || positionMatch || numberMatch;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final players = ref.watch(playersProvider);
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    final filteredPlayers = _filterPlayers(players, _searchQuery);

    return Column(
      children: [
        // Search bar
        Container(
          padding: const EdgeInsets.all(16),
          child: TextField(
            controller: _searchController,
            style: TextStyle(color: colors.onSurface),
            decoration: InputDecoration(
              hintText: 'Search players...',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _searchQuery.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _searchController.clear();

                        setState(() {
                          _searchQuery = '';
                        });
                      },
                    )
                  : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.0),
              ),
              filled: true,
              fillColor: colors.surfaceContainerHighest,
            ),
            onChanged: (value) {
              setState(() {
                _searchQuery = value;
              });
            },
          ),
        ),

        Expanded(
          child: filteredPlayers.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        _searchQuery.isEmpty
                            ? Icons.people_outline
                            : Icons.search_off,
                        size: 64,
                        color: colors.onSurface.withValues(alpha: 0.5),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        _searchQuery.isEmpty
                            ? 'No players yet'
                            : 'No players found',
                        style: theme.textTheme.titleLarge?.copyWith(
                          color: colors.onSurface.withValues(alpha: 0.7),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _searchQuery.isEmpty
                            ? 'Add your first player using the button below'
                            : 'Try a different search term',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: colors.onSurface.withValues(alpha: 0.5),
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: filteredPlayers.length,
                  itemBuilder: (context, index) {
                    final player = filteredPlayers[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        onTap: () => widget.onPlayerSelected(player),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        leading: CircleAvatar(
                          radius: 34,
                          backgroundColor: colors.primaryContainer,
                          child: Text(
                            player.number?.toString() ??
                                player.name[0].toUpperCase(),
                            style: TextStyle(
                              color: colors.onPrimaryContainer,
                              fontSize: 18.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        title: Text(
                          player.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (player.position != null) ...[
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Icon(
                                    Icons.sports_volleyball,
                                    size: 16,
                                    color: colors.onSurface.withValues(
                                      alpha: 0.7,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    player.position!,
                                    style: TextStyle(
                                      color: colors.onSurface.withValues(
                                        alpha: 0.7,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ],
                        ),
                        trailing: Icon(
                          Icons.chevron_right,
                          color: colors.onSurface.withValues(alpha: 0.5),
                        ),
                      ),
                    );
                  },
                ),
        ),
        // Add new player button
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: theme.colorScheme.surface),
          child: SizedBox(
            height: 56.0,
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: widget.onAddPlayerPressed,
              icon: const Icon(Icons.person_add),
              label: const Text(
                'Add New Player',
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
