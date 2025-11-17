import 'package:flutter/material.dart';

import 'package:go_router/go_router.dart';

class AppSidebar extends StatelessWidget {
  const AppSidebar({super.key});

  @override
  Widget build(BuildContext context) {
    // final theme = Theme.of(context);
    // final colors = theme.colorScheme;

    return Container(
      width: 240,
      color: Colors.grey[900],
      child: Column(
        children: [
          const SizedBox(height: 20),
          _navItem(context, label: "Matches", route: '/matches'),
          _navItem(context, label: "Players", route: '/players'),
          _navItem(context, label: "Teams", route: '/teams'),
          _navItem(context, label: "Commands", route: '/commands'),
        ],
      ),
    );
  }

  Widget _navItem(
    BuildContext context, {
    required String label,
    required String route,
  }) {
    return ListTile(title: Text(label), onTap: () => context.go(route));
  }
}
