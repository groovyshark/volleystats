import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:volleystats/features/commands/models/command.dart';
import 'package:volleystats/features/commands/providers/commands_provider.dart';

class CommandForm extends ConsumerStatefulWidget {
  final VoidCallback? onCommandAdded;
  final Command? command; // Optional command for editing

  const CommandForm({super.key, this.onCommandAdded, this.command});

  @override
  ConsumerState<CommandForm> createState() => _CommandFormState();
}

class _CommandFormState extends ConsumerState<CommandForm> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _shortcutController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _initializeForm();
  }

  @override
  void didUpdateWidget(CommandForm oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.command?.id != widget.command?.id) {
      _initializeForm();
    }
  }

  void _initializeForm() {
    if (widget.command != null) {
      _nameController.text = widget.command!.name;
      _descriptionController.text = widget.command!.description;
      _shortcutController.text = widget.command!.shortcut;
    } else {
      _nameController.clear();
      _descriptionController.clear();
      _shortcutController.clear();
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _shortcutController.dispose();
    super.dispose();
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      final isEditing = widget.command != null;

      final command = Command(
        id: isEditing
            ? widget.command!.id
            : DateTime.now().millisecondsSinceEpoch.toString(),
        name: _nameController.text.trim().toLowerCase(),
        description: _descriptionController.text.trim(),
        shortcut: _shortcutController.text.trim().toLowerCase(),
        createdAt: isEditing ? widget.command!.createdAt : DateTime.now(),
      );

      // Check if command name already exists (excluding current command when editing)
      final existingCommands = ref.read(commandsProvider);
      final duplicateName = existingCommands.any(
        (c) => c.name == command.name && c.id != command.id,
      );

      ScaffoldMessenger.of(context).clearSnackBars();

      final colors = Theme.of(context).colorScheme;

      if (duplicateName) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Command name "${command.name}" already exists'),
            backgroundColor: colors.error,
            duration: const Duration(seconds: 2),
          ),
        );
        return;
      }

      // Check if shortcut already exists (excluding current command when editing)
      if (command.shortcut.isNotEmpty) {
        final duplicateShortcut = existingCommands.any(
          (c) => c.shortcut == command.shortcut && c.id != command.id,
        );
        if (duplicateShortcut) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Shortcut "${command.shortcut}" already exists'),
              backgroundColor: colors.error,
              duration: const Duration(seconds: 2),
            ),
          );
          return;
        }
      }

      if (isEditing) {
        ref.read(commandsProvider.notifier).updateCommand(command);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: colors.primary,
            content: Text(
              'Command updated successfully',
              style: TextStyle(color: colors.onPrimary),
            ),
            duration: const Duration(seconds: 1),
          ),
        );
      } else {
        ref.read(commandsProvider.notifier).addCommand(command);

        // Reset form
        _nameController.clear();
        _descriptionController.clear();
        _shortcutController.clear();

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: colors.primary,
            content: Text(
              'Command added successfully',
              style: TextStyle(color: colors.onPrimary),
            ),
            duration: const Duration(seconds: 1),
          ),
        );
      }

      // Call callback if provided (to close form)
      widget.onCommandAdded?.call();
    }
  }

  void _showDeleteDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Delete Command',
          style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
        ),
        content: Text(
          'Are you sure you want to delete "${widget.command!.name}"?',
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
                  .read(commandsProvider.notifier)
                  .removeCommand(widget.command!.id);
              Navigator.of(context).pop();

              final colors = Theme.of(context).colorScheme;

              ScaffoldMessenger.of(context).clearSnackBars();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  backgroundColor: colors.primary,
                  content: Text(
                    'Command deleted successfully',
                    style: TextStyle(color: colors.onPrimary),
                  ),
                  duration: const Duration(seconds: 1),
                ),
              );

              // Call callback to close form
              widget.onCommandAdded?.call();
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
              style: TextStyle(color: colors.onSurface),
              decoration: const InputDecoration(
                labelText: 'Description (optional)',
                hintText: 'Brief description of the command',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.description),
              ),
              maxLines: 2,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _shortcutController,
              style: TextStyle(color: colors.onSurface),
              decoration: const InputDecoration(
                labelText: 'Shortcut (optional)',
                hintText: 'e.g., s, d, h',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.flash_on),
              ),
              validator: (value) {
                if (value != null && value.trim().isNotEmpty) {
                  final shortcut = value.trim().toLowerCase();
                  if (shortcut.length > 3) {
                    return 'Shortcut should be 3 characters or less';
                  }
                }
                return null;
              },
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _submitForm,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: colors.primaryContainer,
                foregroundColor: colors.onPrimaryContainer,
              ),
              child: Text(
                widget.command != null ? 'Update Command' : 'Add Command',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            if (widget.command != null) ...[
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: _showDeleteDialog,
                icon: const Icon(Icons.delete_outline),
                label: const Text(
                  'Delete Command',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  foregroundColor: colors.error,
                  side: BorderSide(color: colors.error),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
