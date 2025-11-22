import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:volleystats/features/commands/models/command.dart';
import 'package:volleystats/features/commands/providers/commands_provider.dart';

class CommandList extends ConsumerWidget {
  final VoidCallback onAddCommandPressed;
  final Function(Command) onCommandSelected;

  const CommandList({
    super.key,
    required this.onAddCommandPressed,
    required this.onCommandSelected,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final commands = ref.watch(commandsProvider);
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Column(
      children: [
        Expanded(
          child: commands.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.keyboard_outlined,
                        size: 64,
                        color: colors.onSurface.withValues(alpha: 0.5),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No commands defined',
                        style: theme.textTheme.titleLarge?.copyWith(
                          color: colors.onSurface.withValues(alpha: 0.7),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Add commands that can be used during matches',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: colors.onSurface.withValues(alpha: 0.5),
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: commands.length,
                  itemBuilder: (context, index) {
                    final command = commands[index];

                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        onTap: () => onCommandSelected(command),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        leading: CircleAvatar(
                          backgroundColor: colors.primaryContainer,
                          child: Icon(
                            Icons.keyboard,
                            color: colors.onPrimaryContainer,
                          ),
                        ),
                        title: Text(
                          command.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        subtitle:
                            command.description.isNotEmpty ||
                                command.shortcut.isNotEmpty
                            ? Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  if (command.description.isNotEmpty)
                                    Text(command.description),
                                  if (command.shortcut.isNotEmpty)
                                    Text(
                                      'Shortcut: ${command.shortcut}',
                                      style: TextStyle(
                                        color: colors.primary,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                ],
                              )
                            : null,
                        trailing: Icon(
                          Icons.chevron_right,
                          color: colors.onSurface.withValues(alpha: 0.5),
                        ),
                      ),
                    );
                  },
                ),
        ),
        // Add new command button
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: theme.colorScheme.surface),
          child: SizedBox(
            height: 56.0,
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: onAddCommandPressed,
              icon: const Icon(Icons.add),
              label: const Text(
                'Add New Command',
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
