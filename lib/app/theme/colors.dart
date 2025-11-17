import 'package:flutter/material.dart';

const _seed = Color.fromARGB(255, 0, 47, 255);

final lightColorScheme = ColorScheme.fromSeed(
  seedColor: _seed,
  // surface: Color.fromARGB(255, 252, 249, 234),
  brightness: Brightness.light,
);

final darkColorScheme = ColorScheme.fromSeed(
  seedColor: _seed,
  brightness: Brightness.dark,
);