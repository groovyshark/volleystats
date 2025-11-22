import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

TextTheme buildTextTheme(Brightness brightness) { 
  final base = GoogleFonts.ubuntuTextTheme();

  return base;
  // return base.copyWith(
  //   displayLarge: base.displayLarge?.copyWith(fontWeight: FontWeight.w700),
  //   headlineSmall: base.headlineSmall?.copyWith(letterSpacing: 0.2),
  //   titleLarge: base.titleLarge?.copyWith(
  //     fontWeight: FontWeight.w600,
  //     fontSize: 24,
  //   ),
  //   titleMedium: base.titleMedium?.copyWith(
  //     fontWeight: FontWeight.w500,
  //     fontSize: 20,
  //     letterSpacing: 1,
  //   ),
  //   titleSmall: base.titleSmall?.copyWith(
  //     fontWeight: FontWeight.w400,
  //     fontSize: 16,
  //     letterSpacing: 1.0,
  //   ),
  //   bodyLarge: base.bodyLarge?.copyWith(height: 1.25),
  //   labelLarge: base.labelLarge?.copyWith(
  //     fontWeight: FontWeight.w600,
  //     letterSpacing: 0.2,
  //     fontSize: 18,
  //   ),
  //   labelMedium: base.labelMedium?.copyWith(
  //     fontWeight: FontWeight.w600,
  //     fontSize: 16,
  //   ),
  // ).apply(
  //   bodyColor: brightness == Brightness.dark ? Colors.white : Colors.black,
  //   displayColor: brightness == Brightness.dark ? Colors.white : Colors.black,
  // );
}