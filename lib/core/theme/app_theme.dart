import 'package:flutter/material.dart';

/// App-wide Material theme. The seed color matches the warm, paper-like
/// palette used by the original prototype `main.dart`.
class AppTheme {
  AppTheme._();

  static const Color brandOrange = Color(0xffff7b4b);
  static const Color creamBackground = Color(0xfff5ede2);
  static const Color brandNavy = Color(0xff2a3647);

  static ThemeData get light => ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: creamBackground),
        appBarTheme: const AppBarTheme(
          backgroundColor: creamBackground,
          foregroundColor: brandOrange,
          titleTextStyle: TextStyle(
            color: brandOrange,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
      );
}
