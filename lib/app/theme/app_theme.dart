import 'package:flutter/material.dart';
import 'package:volleystats/app/theme/typography.dart';

import 'colors.dart';

class AppTheme {
  static ThemeData light() {
    final scheme = lightColorScheme;
    return ThemeData(
      colorScheme: scheme,
      textTheme: buildTextTheme(Brightness.light),
    );
  }

  static ThemeData dark() {
    final scheme = darkColorScheme;
    return ThemeData(
      textTheme: buildTextTheme(Brightness.dark),
      colorScheme: scheme,
    );
  }
}