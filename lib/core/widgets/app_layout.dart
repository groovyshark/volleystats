import 'package:flutter/material.dart';

import 'app_sidebar.dart';

class AppLayout extends StatelessWidget {
  final Widget? child;
  final bool showSidebar;

  const AppLayout({super.key, this.child, this.showSidebar = true});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LayoutBuilder(
        builder: (_, constraints) {
          final totalWidth = constraints.maxWidth;
          double sidebarWidth = totalWidth * 0.15;

          const minSidebarWidth = 240.0;
          if (sidebarWidth < minSidebarWidth) {
            sidebarWidth = minSidebarWidth;
          }

          return Row(
            children: [
              if (showSidebar)
                SizedBox(width: sidebarWidth, child: const AppSidebar()),
              Expanded(
                child: child ?? const Center(child: Text('Page Context')),
              ),
            ],
          );
        },
      ),
    );
  }
}
