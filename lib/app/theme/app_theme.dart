import 'package:flutter/material.dart';

import 'colors.dart';

class AppTheme {
  static ThemeData light() {
    final scheme = lightColorScheme;
    return ThemeData(
      colorScheme: scheme,
    );
  }

  static ThemeData dark() {
    final scheme = darkColorScheme;
    return ThemeData(
      colorScheme: scheme,
    );
  }
}