import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:volleystats/features/commands/models/command.dart';
import 'package:volleystats/features/commands/widgets/command_list.dart';
import 'package:volleystats/features/commands/widgets/command_form.dart';

class CommandsScreen extends ConsumerStatefulWidget {
  const CommandsScreen({super.key});

  @override
  ConsumerState<CommandsScreen> createState() => _CommandsScreenState();
}

class _CommandsScreenState extends ConsumerState<CommandsScreen> {
  bool _showForm = false;
  Command? _selectedCommand;

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
                Icon(
                  Icons.keyboard,
                  size: 40,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 12),
                Text(
                  'Commands',
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
                // Left side: Command list
                Expanded(
                  flex: 1,
                  child: CommandList(
                    onAddCommandPressed: () {
                      setState(() {
                        _selectedCommand = null;
                        _showForm = true;
                      });
                    },
                    onCommandSelected: (command) {
                      setState(() {
                        _selectedCommand = command;
                        _showForm = true;
                      });
                    },
                  ),
                ),
                // Right side: Form
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
                                    _selectedCommand != null
                                        ? 'Edit Command'
                                        : 'Add New Command',
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
                                      _selectedCommand = null;
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
                              child: CommandForm(
                                command: _selectedCommand,
                                onCommandAdded: () {
                                  setState(() {
                                    _showForm = false;
                                    _selectedCommand = null;
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
                            Icons.keyboard_outlined,
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
                            'Click "Add New Command" to start',
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
