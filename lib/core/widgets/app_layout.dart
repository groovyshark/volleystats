import 'package:flutter/material.dart';

import 'app_sidebar.dart';

class AppLayout extends StatelessWidget {
  final Widget? child;

  const AppLayout({super.key, this.child});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          const AppSidebar(),
          Expanded(
            child: child ?? const Center(child: Text('Page Context')),
          ),
        ],
      ),
    );
  }
}