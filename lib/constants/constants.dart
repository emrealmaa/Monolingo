import 'package:flutter/material.dart';

// --- ANA RENK PALETİ ---
const Color kDeepNavy = Color(0xFF0F172A);
const Color kCardNavy = Color(0xFF1E293B);
const Color kAccentCopper = Color(0xFFFB923C);
const Color kLightText = Color(0xFFF8FAFC);

// --- TEMA AYARLARI (INPUT DECORATION FONKSİYONU) ---
// Aga burayı fonksiyon yaptım çünkü context üzerinden o anki temayı kontrol etmemiz lazım
InputDecoration getKInputDecoration(BuildContext context) {
  final isDark = Theme.of(context).brightness == Brightness.dark;

  return InputDecoration(
    filled: true,
    // Aydınlık modda hafif gri, karanlık modda kCardNavy
    fillColor: isDark ? kCardNavy : Colors.grey.shade200,
    labelStyle: TextStyle(color: isDark ? Colors.white54 : Colors.black54),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(15),
      borderSide: BorderSide(color: isDark ? Colors.white10 : Colors.black12),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(15),
      borderSide: const BorderSide(color: kAccentCopper, width: 2),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(15),
      borderSide: const BorderSide(color: Colors.redAccent),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(15),
      borderSide: const BorderSide(color: Colors.redAccent, width: 2),
    ),
  );
}

// --- TEXT STİLLERİ ---
// Bunlar artık direkt 'color: Colors.white' olmamalı, temaya göre değişmeli
TextStyle getKHeadingStyle(BuildContext context) {
  return TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: Theme.of(context).brightness == Brightness.dark
        ? Colors.white
        : kDeepNavy,
    letterSpacing: 1.2,
  );
}

const kSubHeadingStyle = TextStyle(fontSize: 16, color: Colors.white70);

const kButtonTextStyle = TextStyle(
  fontSize: 16,
  fontWeight: FontWeight.bold,
  letterSpacing: 1.5,
);
