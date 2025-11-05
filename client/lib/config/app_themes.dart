import 'package:flutter/material.dart';

class AppThemes {
  static const Color primaryColor = Color(0xFF24BAEC);

  static ThemeData lightTheme = ThemeData(
    primaryColor: primaryColor,
    fontFamily: 'Inter',
    scaffoldBackgroundColor: Colors.white,
    appBarTheme: const AppBarTheme(
      color: Colors.white,
      elevation: 0,
      iconTheme: IconThemeData(color: Colors.black),
      titleTextStyle: TextStyle(
        color: Colors.black,
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
    ),
  );
}