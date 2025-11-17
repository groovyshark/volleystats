import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:volleystats/features/commands/models/command.dart';
import 'package:volleystats/features/commands/providers/commands_provider.dart';

class CommandForm extends ConsumerStatefulWidget {
  final VoidCallback? onCommandAdded;

  const CommandForm({super.key, this.onCommandAdded});

  @override
  ConsumerState<CommandForm> createState() => _CommandFormState();
}

class _CommandFormState extends ConsumerState<CommandForm> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      final command = Command(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: _nameController.text.trim().toLowerCase(),
        description: _descriptionController.text.trim(),
        createdAt: DateTime.now(),
      );

      // Check if command already exists
      final existingCommands = ref.read(commandsProvider);
      if (existingCommands.any((c) => c.name == command.name)) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Command "${command.name}" already exists'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 2),
          ),
        );
        return;
      }

      ref.read(commandsProvider.notifier).addCommand(command);

      // Reset form
      _nameController.clear();
      _descriptionController.clear();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Command added successfully'),
          duration: Duration(seconds: 1),
        ),
      );

      // Call callback if provided (to close form)
      widget.onCommandAdded?.call();
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
                labelText: 'Command Name *',
                hintText: 'e.g., serve, dig, hit, set',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.keyboard),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter a command name';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description (optional)',
                hintText: 'Brief description of the command',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.description),
              ),
              maxLines: 2,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _submitForm,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: colors.primary,
                foregroundColor: colors.onPrimary,
              ),
              child: const Text(
                'Add Command',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

