import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:volleystats/features/commands/providers/commands_provider.dart';

class CommandHelper extends ConsumerWidget {
  const CommandHelper({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final commands = ref.watch(commandsProvider);
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.surfaceContainerHighest.withValues(alpha: 0.3),
        border: Border(top: BorderSide(color: theme.dividerColor)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Icon(Icons.help_outline, size: 16, color: colors.primary),
              const SizedBox(width: 8),
              Text(
                'Command Syntax',
                style: theme.textTheme.labelLarge?.copyWith(
                  color: colors.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: colors.surface,
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: theme.dividerColor),
            ),
            child: Text(
              '<player> <action> [result]',
              style: TextStyle(
                fontFamily: 'monospace',
                fontSize: 12,
                color: colors.onSurface,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Note: <player> can be jersey number or name',
            style: TextStyle(
              fontSize: 11,
              color: colors.onSurfaceVariant,
              fontStyle: FontStyle.italic,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Available Commands:',
            style: theme.textTheme.labelMedium?.copyWith(
              color: colors.onSurfaceVariant,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          if (commands.isEmpty)
            Text(
              'No commands defined',
              style: TextStyle(
                fontSize: 12,
                color: colors.onSurfaceVariant,
                fontStyle: FontStyle.italic,
              ),
            )
          else
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: commands.map((cmd) {
                return Tooltip(
                  message: cmd.description.isNotEmpty
                      ? cmd.description
                      : cmd.name,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: colors.secondaryContainer,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: RichText(
                      text: TextSpan(
                        style: TextStyle(
                          fontSize: 11,
                          color: colors.onSecondaryContainer,
                        ),
                        children: [
                          TextSpan(
                            text: cmd.name,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          if (cmd.shortcut.isNotEmpty) ...[
                            TextSpan(
                              text: ' (${cmd.shortcut})',
                              style: TextStyle(
                                color: colors.onSecondaryContainer.withValues(
                                  alpha: 0.7,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
        ],
      ),
    );
  }
}
