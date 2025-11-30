import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Màu sắc trích xuất từ thiết kế
  static const primaryColor = Color(0xFF13ECB6);
  static const backgroundColor = Color(0xFF121E1E); // Nền tối
  static const surfaceColor = Color(0xFF1E2D2D); // Nền card/input
  static const textWhite = Colors.white;
  static const textGrey = Color(0xFF9CA3AF);

  static final darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    primaryColor: primaryColor,
    scaffoldBackgroundColor: backgroundColor,

    // Cấu hình Font chữ Inter toàn bộ App
    textTheme: GoogleFonts.interTextTheme(ThemeData.dark().textTheme).apply(
      bodyColor: textWhite,
      displayColor: textWhite,
    ),

    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: false,
    ),
  );
}