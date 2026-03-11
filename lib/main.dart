import 'package:flutter/material.dart';
import 'constants/constants.dart';
import 'screens/login_screen.dart';
import 'data/db_helper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final db = DbHelper();
  await db.database; // Veritabanını ayağa kaldır
  runApp(const MonolingoApp());
}

class MonolingoApp extends StatelessWidget {
  const MonolingoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Monolingo',
      themeMode: ThemeMode.system, // Sisteme göre dark/light seçer
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        colorScheme: ColorScheme.fromSeed(
          seedColor: kDeepNavy,
          primary: kDeepNavy,
        ),
        scaffoldBackgroundColor: Colors.white,
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: kDeepNavy,
        colorScheme: ColorScheme.fromSeed(
          seedColor: kDeepNavy,
          brightness: Brightness.dark,
          primary: kAccentCopper,
        ),
      ),
      home: const LoginSayfasi(),
    );
  }
}
