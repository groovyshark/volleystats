import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:volleystats/features/players/models/player.dart';
import 'package:volleystats/features/players/providers/players_provider.dart';

class PlayerForm extends ConsumerStatefulWidget {
  final Player? player;
  final VoidCallback? onPlayerSaved;
  final VoidCallback? onPlayerDeleted;

  const PlayerForm({
    super.key,
    this.player,
    this.onPlayerSaved,
    this.onPlayerDeleted,
  });

  @override
  ConsumerState<PlayerForm> createState() => _PlayerFormState();
}

class _PlayerFormState extends ConsumerState<PlayerForm> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _numberController;
  late TextEditingController _positionController;

  String? _selectedPosition;

  final List<String> _positions = [
    'Setter',
    'Outside Hitter',
    'Opposite Hitter',
    'Middle Blocker',
    'Libero',
    'Defensive Specialist',
    'Common',
  ];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _numberController = TextEditingController();
    _positionController = TextEditingController();
    _updateFormValues();
  }

  @override
  void didUpdateWidget(PlayerForm oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.player != oldWidget.player) {
      _updateFormValues();
    }
  }

  void _updateFormValues() {
    _nameController.text = widget.player?.name ?? '';
    _numberController.text = widget.player?.number?.toString() ?? '';

    final initialPosition = widget.player?.position;
    if (initialPosition != null && _positions.contains(initialPosition)) {
      _selectedPosition = initialPosition;
      _positionController.text = '';
    } else {
      _selectedPosition = null;
      _positionController.text = initialPosition ?? '';
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _numberController.dispose();
    _positionController.dispose();
    super.dispose();
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      final name = _nameController.text.trim();
      final number = _numberController.text.isNotEmpty
          ? int.tryParse(_numberController.text)
          : null;
      final position =
          _selectedPosition ??
          (_positionController.text.trim().isNotEmpty
              ? _positionController.text.trim()
              : null);

      if (widget.player != null) {
        // Update existing player
        final updatedPlayer = widget.player!.copyWith(
          name: name,
          number: number,
          position: position,
        );
        ref.read(playersProvider.notifier).updatePlayer(updatedPlayer);

        final colors = Theme.of(context).colorScheme;

        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: colors.primary,
            content: Text(
              'Player updated successfully',
              style: TextStyle(color: colors.onPrimary),
            ),
            duration: const Duration(seconds: 1),
          ),
        );
      } else {
        // Add new player
        final newPlayer = Player(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          name: name,
          number: number,
          position: position,
          createdAt: DateTime.now(),
        );
        ref.read(playersProvider.notifier).addPlayer(newPlayer);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Theme.of(context).colorScheme.primaryContainer,
            content: Text('Player added successfully'),
            duration: const Duration(seconds: 1),
          ),
        );
      }

      widget.onPlayerSaved?.call();
    }
  }

  void _deletePlayer() {
    if (widget.player == null) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Delete Player',
          style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
        ),
        content: Text(
          'Are you sure you want to delete "${widget.player!.name}"?',
          style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              ref
                  .read(playersProvider.notifier)
                  .removePlayer(widget.player!.id);
              Navigator.of(context).pop(); // Close dialog
              widget.onPlayerDeleted?.call(); // Notify parent

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  backgroundColor: Theme.of(context).colorScheme.error,
                  content: Text('Player "${widget.player!.name}" deleted'),
                  duration: const Duration(seconds: 1),
                ),
              );
            },
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final isEditing = widget.player != null;

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
                    style: TextStyle(color: colors.onSurface),
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
                    initialValue: _selectedPosition,
                    style: TextStyle(color: colors.onSurface),
                    decoration: const InputDecoration(
                      labelText: 'Position',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.sports_volleyball),
                    ),
                    items: [
                      ..._positions.map((position) {
                        return DropdownMenuItem(
                          value: position,
                          child: Text(position),
                        );
                      }),
                      const DropdownMenuItem(
                        value: null,
                        child: Text('Custom / Other'),
                      ),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _selectedPosition = value;
                        if (value != null) {
                          _positionController.clear();
                        }
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
            Row(
              children: [
                if (isEditing) ...[
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _deletePlayer,
                      icon: const Icon(Icons.delete_outline),
                      label: Text(
                        'Delete',
                        style: TextStyle(color: colors.error, fontSize: 16),
                      ),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        foregroundColor: colors.error,
                        side: BorderSide(color: colors.error),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                ],
                Expanded(
                  flex: 2,
                  child: ElevatedButton(
                    onPressed: _submitForm,
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadiusGeometry.circular(12.0),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: colors.primaryContainer,
                      foregroundColor: colors.onPrimaryContainer,
                    ),
                    child: Text(
                      isEditing ? 'Save Changes' : 'Add Player',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
