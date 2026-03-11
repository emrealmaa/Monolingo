import 'package:flutter/material.dart';
import '../constants/constants.dart';
import 'profile_screen.dart'; // Bunu birazdan oluşturacağız

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const Center(
      child: Text(
        "ÖĞRENME SAYFASI (YAKINDA)",
        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
      ),
    ),
    const Center(child: Text("SÖZLÜK (BOŞ)")),
    const Center(child: Text("WORDLE (YAKINDA)")),
    const ProfilSekmesi(
      isim: "Misafir Kullanıcı",
      email: "misafir@monolingo.com",
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        type: BottomNavigationBarType.fixed,
        selectedItemColor: kDeepNavy,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.school), label: "Öğren"),
          BottomNavigationBarItem(icon: Icon(Icons.list), label: "Oyun"),
          BottomNavigationBarItem(icon: Icon(Icons.games), label: "İstatistik"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profil"),
        ],
      ),
    );
  }
}
