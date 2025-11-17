import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:volleystats/features/players/models/player.dart';
import 'package:volleystats/features/players/providers/players_provider.dart';

class PlayerForm extends ConsumerStatefulWidget {
  final VoidCallback? onPlayerAdded;

  const PlayerForm({super.key, this.onPlayerAdded});

  @override
  ConsumerState<PlayerForm> createState() => _PlayerFormState();
}

class _PlayerFormState extends ConsumerState<PlayerForm> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _numberController = TextEditingController();
  final _positionController = TextEditingController();

  String? _selectedPosition;

  final List<String> _positions = [
    'Setter',
    'Outside Hitter',
    'Opposite Hitter',
    'Middle Blocker',
    'Libero',
    'Defensive Specialist',
    'Common'
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _numberController.dispose();
    _positionController.dispose();
    super.dispose();
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      final player = Player(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: _nameController.text.trim(),
        number: _numberController.text.isNotEmpty
            ? int.tryParse(_numberController.text)
            : null,
        position: _selectedPosition ??
            (_positionController.text.trim().isNotEmpty
                ? _positionController.text.trim()
                : null),
        createdAt: DateTime.now(),
      );

      ref.read(playersProvider.notifier).addPlayer(player);

      // Reset form
      _nameController.clear();
      _numberController.clear();
      _positionController.clear();
      setState(() {
        _selectedPosition = null;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Theme.of(context).colorScheme.primary,
          content: Text('Player added successfully'),
          duration: Duration(seconds: 1),
        ),
      );

      // Call callback if provided (to close form)
      widget.onPlayerAdded?.call();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Name *',
                hintText: 'Enter player name',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.person),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter a name';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _numberController,
                    decoration: const InputDecoration(
                      labelText: 'Jersey Number',
                      hintText: 'e.g., 10',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.numbers),
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value != null &&
                          value.isNotEmpty &&
                          int.tryParse(value) == null) {
                        return 'Please enter a valid number';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _selectedPosition,
                    decoration: const InputDecoration(
                      labelText: 'Position',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.sports_volleyball),
                    ),
                    items: _positions.map((position) {
                      return DropdownMenuItem(
                        value: position,
                        child: Text(position),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedPosition = value;
                      });
                    },
                  ),
                ),
              ],
            ),
            if (_selectedPosition == null) ...[
              const SizedBox(height: 16),
              TextFormField(
                controller: _positionController,
                decoration: const InputDecoration(
                  labelText: 'Custom Position',
                  hintText: 'Or enter custom position',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.edit),
                ),
              ),
            ],
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _submitForm,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: colors.primary,
                foregroundColor: colors.onPrimary,
              ),
              child: const Text(
                'Add Player',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

