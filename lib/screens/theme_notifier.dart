import 'package:flutter/material.dart';
import '../constants/constants.dart';

class ThemeNotifier {
  // KARANLIK TEMA (Senin mevcut tasarımın)
  static final darkTheme = ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: kDeepNavy, // #0A0E21
    cardColor: kCardNavy, // #1D1E33
    primaryColor: kAccentCopper, // Bakır rengin
    appBarTheme: const AppBarTheme(backgroundColor: kDeepNavy, elevation: 0),
    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: Colors.white),
      bodyMedium: TextStyle(color: Colors.white70),
    ),
  );

  // AYDINLIK TEMA (Yeni temiz tasarım)
  static final lightTheme = ThemeData(
    brightness: Brightness.light,
    scaffoldBackgroundColor: const Color(0xFFF5F7FA), // Ferah gri-beyaz
    cardColor: Colors.white, // Saf beyaz kartlar
    primaryColor: kAccentCopper, // Bakır vurgu kalsın, şık durur
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFFF5F7FA),
      elevation: 0,
      iconTheme: IconThemeData(color: kDeepNavy),
      titleTextStyle: TextStyle(
        color: kDeepNavy,
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
    ),
    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: kDeepNavy),
      bodyMedium: TextStyle(color: Colors.black87),
    ),
  );
}
