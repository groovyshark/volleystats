import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class AppSidebar extends ConsumerWidget {
  const AppSidebar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeRoute = GoRouterState.of(context).uri.toString();

    return Material(
      color: Colors.grey[900],
      child: SizedBox(
        width: 240,
        child: Column(
          children: [
            const SizedBox(height: 20),
            _navItem(
              context,
              activeRoute: activeRoute,
              label: "Matches",
              route: '/matches',
              iconData: Icons.sports_volleyball
            ),
            _navItem(
              context,
              activeRoute: activeRoute,
              label: "Players",
              route: '/players',
              iconData: Icons.people_alt_outlined,
            ),
            _navItem(
              context,
              activeRoute: activeRoute,
              label: "Teams",
              route: '/teams',
              iconData: Icons.shield_outlined,
            ),
            _navItem(
              context,
              activeRoute: activeRoute,
              label: "Commands",
              route: '/commands',
              iconData: Icons.terminal
            ),
          ],
        ),
      ),
    );
  }

  Widget _navItem(
    BuildContext context, {
    required String activeRoute,
    required String label,
    required String route,
    required IconData iconData,
  }) {
    final bool isActive = activeRoute.startsWith(route);

    final colors = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 2.0),
      child: ListTile(
        tileColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12), // Optional: for rounded corners
        ),
        selected: isActive,
        selectedColor: colors.onPrimaryContainer,
        selectedTileColor: colors.primaryContainer,
        leading: Icon(iconData),
        title: Text(
          label,
          style: TextStyle(
            color: isActive ? colors.onPrimaryContainer : colors.onSurface,
            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
            fontSize: 18.0,
          ),
        ),
        onTap: () => context.go(route),
      ),
    );
  }
}
