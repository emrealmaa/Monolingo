import 'package:flutter/material.dart';

// --- ANA RENK PALETİ ---
const Color kDeepNavy = Color(0xFF0F172A);
const Color kCardNavy = Color(0xFF1E293B);
const Color kAccentCopper = Color(0xFFFB923C);

// --- TEMA AYARLARI ---
InputDecoration getKInputDecoration(BuildContext context) {
  final isDark = Theme.of(context).brightness == Brightness.dark;

  return InputDecoration(
    filled: true,
    fillColor: isDark ? kCardNavy : Colors.grey.shade100,
    labelStyle: TextStyle(color: isDark ? Colors.white54 : Colors.black54),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(15),
      borderSide: BorderSide(color: isDark ? Colors.white10 : Colors.black12),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(15),
      borderSide: const BorderSide(color: kAccentCopper, width: 2),
    ),
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
  );
}

const kButtonTextStyle = TextStyle(
  fontSize: 16,
  fontWeight: FontWeight.bold,
  letterSpacing: 1.2,
);
