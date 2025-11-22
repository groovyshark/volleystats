import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:volleystats/features/matches/models/match.dart';
import 'package:volleystats/features/matches/providers/matches_provider.dart';
import 'package:volleystats/features/teams/providers/teams_provider.dart';
import 'package:volleystats/features/players/providers/players_provider.dart';

class MatchForm extends ConsumerStatefulWidget {
  final VoidCallback? onMatchCreated;

  const MatchForm({super.key, this.onMatchCreated});

  @override
  ConsumerState<MatchForm> createState() => _MatchFormState();
}

class _MatchFormState extends ConsumerState<MatchForm> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final Set<String> _selectedTeamIds = {};
  final Set<String> _selectedPlayerIds = {};

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      if (_selectedTeamIds.isEmpty && _selectedPlayerIds.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please select at least one team or player'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 2),
          ),
        );
        return;
      }

      final match = Match(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: _nameController.text.trim(),
        teamIds: _selectedTeamIds.toList(),
        playerIds: _selectedPlayerIds.toList(),
        createdAt: DateTime.now(),
      );

      ref.read(matchesProvider.notifier).addMatch(match);

      // Reset form
      _nameController.clear();
      _selectedTeamIds.clear();
      _selectedPlayerIds.clear();
      setState(() {});

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Match created successfully'),
          duration: Duration(seconds: 1),
        ),
      );

      widget.onMatchCreated?.call();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final teams = ref.watch(teamsProvider);
    final players = ref.watch(playersProvider);

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextFormField(
              controller: _nameController,
              style: TextStyle(color: colors.onSurface),
              decoration: const InputDecoration(
                labelText: 'Match Name *',
                hintText: 'Enter match name',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.sports_volleyball),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter a match name';
                }
                return null;
              },
            ),
            const SizedBox(height: 24),
            Text(
              'Select Teams',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            if (teams.isEmpty)
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  'No teams available. Create teams first.',
                  style: TextStyle(
                    color: colors.onSurface.withValues(alpha: 0.6),
                    fontStyle: FontStyle.italic,
                  ),
                ),
              )
            else
              Container(
                constraints: const BoxConstraints(maxHeight: 200),
                decoration: BoxDecoration(
                  border: Border.all(color: colors.outline),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: teams.length,
                  itemBuilder: (context, index) {
                    final team = teams[index];
                    final isSelected = _selectedTeamIds.contains(team.id);

                    return CheckboxListTile(
                      title: Text(team.name),
                      value: isSelected,
                      onChanged: (value) {
                        setState(() {
                          if (value == true) {
                            _selectedTeamIds.add(team.id);
                          } else {
                            _selectedTeamIds.remove(team.id);
                          }
                        });
                      },
                    );
                  },
                ),
              ),
            const SizedBox(height: 24),
            Text(
              'Select Players',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            if (players.isEmpty)
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  'No players available. Add players first.',
                  style: TextStyle(
                    color: colors.onSurface.withValues(alpha: 0.6),
                    fontStyle: FontStyle.italic,
                  ),
                ),
              )
            else
              Container(
                constraints: const BoxConstraints(maxHeight: 200),
                decoration: BoxDecoration(
                  border: Border.all(color: colors.outline),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: players.length,
                  itemBuilder: (context, index) {
                    final player = players[index];
                    final isSelected = _selectedPlayerIds.contains(player.id);

                    return CheckboxListTile(
                      title: Text(player.name),
                      subtitle: player.number != null
                          ? Text('Jersey #${player.number}')
                          : null,
                      value: isSelected,
                      onChanged: (value) {
                        setState(() {
                          if (value == true) {
                            _selectedPlayerIds.add(player.id);
                          } else {
                            _selectedPlayerIds.remove(player.id);
                          }
                        });
                      },
                    );
                  },
                ),
              ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _submitForm,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: colors.primaryContainer,
                foregroundColor: colors.onPrimaryContainer,
              ),
              child: const Text(
                'Create Match',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
