import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/constants.dart';
import 'learning.dart';
import 'statistics.dart';
import 'profile.dart';
import 'zamana_karsi_oyun.dart';
import 'wordle_unlimited_screen.dart';
import 'harf_laboratuvari_screen.dart';
import 'word_chain_screen.dart';

class MainNavigationScreen extends StatefulWidget {
  final String isim;
  final String email;

  const MainNavigationScreen({
    super.key,
    required this.isim,
    required this.email,
  });

  @override
  _MainNavigationScreenState createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  late PageController _pc;
  int _curr = 0;

  @override
  void initState() {
    super.initState();
    _pc = PageController();
  }

  @override
  void dispose() {
    _pc.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      extendBody: true, // Navigasyonun arkasından içerik süzülsün
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: PageView(
        controller: _pc,
        onPageChanged: (i) => setState(() => _curr = i),
        physics: const BouncingScrollPhysics(),
        children: [
          const OgrenmeSekmesi(),
          const OyunLobiSekmesi(),
          const IstatistikSekmesi(),
          ProfilSekmesi(isim: widget.isim, email: widget.email),
        ],
      ),
      bottomNavigationBar: _buildModernNavBar(isDark),
    );
  }

  Widget _buildModernNavBar(bool isDark) {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 25),
      height: 75,
      decoration: BoxDecoration(
        color: isDark
            ? Colors.black.withOpacity(0.6)
            : Colors.white.withOpacity(0.8),
        borderRadius: BorderRadius.circular(35),
        border: Border.all(color: isDark ? Colors.white10 : Colors.black12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 30,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(35),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _navItem(Icons.auto_stories_rounded, "Öğren", 0),
              _navItem(Icons.sports_esports_rounded, "Oyun", 1),
              _navItem(Icons.analytics_rounded, "Analiz", 2),
              _navItem(Icons.person_rounded, "Profil", 3),
            ],
          ),
        ),
      ),
    );
  }

  Widget _navItem(IconData icon, String label, int index) {
    bool selected = _curr == index;
    return GestureDetector(
      onTap: () {
        _pc.animateToPage(
          index,
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeInOut, // Hata veren yer burasıydı, düzelttim aga.
        );
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: selected
              ? kAccentCopper.withAlpha(38) // withOpacity yerine daha güvenli
              : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: selected ? kAccentCopper : Colors.grey.withAlpha(180),
              size: 26,
            ),
            if (selected)
              Text(
                label,
                style: const TextStyle(
                  color: kAccentCopper,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// --- OYUN LOBİ SEKMESİ ---
class OyunLobiSekmesi extends StatefulWidget {
  const OyunLobiSekmesi({super.key});

  @override
  State<OyunLobiSekmesi> createState() => _OyunLobiSekmesiState();
}

class _OyunLobiSekmesiState extends State<OyunLobiSekmesi> {
  final List<String> _levels = ['A1', 'A2', 'B1', 'B2', 'C1'];
  final Set<String> _selectedLevels = {'A1', 'A2', 'B1', 'B2', 'C1'};

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SafeArea(
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "SELAM ,",
              style: GoogleFonts.montserrat(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.grey,
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              "Hangi seviyeyi çalışıoruz bu gün?",
              style: GoogleFonts.montserrat(
                fontSize: 28,
                fontWeight: FontWeight.w900,
                color: isDark ? Colors.white : kDeepNavy,
              ),
            ),
            const SizedBox(height: 30),

            // SEVİYE SEÇİCİ (Chip Tasarımı)
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              child: Row(
                children: _levels.map((level) {
                  final isSelected = _selectedLevels.contains(level);
                  return Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          if (isSelected && _selectedLevels.length > 1) {
                            _selectedLevels.remove(level);
                          } else {
                            _selectedLevels.add(level);
                          }
                        });
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 28,
                          vertical: 14,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? kAccentCopper
                              : (isDark
                                    ? Colors.white.withOpacity(0.05)
                                    : Colors.black.withOpacity(0.05)),
                          borderRadius: BorderRadius.circular(18),
                          boxShadow: isSelected
                              ? [
                                  BoxShadow(
                                    color: kAccentCopper.withOpacity(0.4),
                                    blurRadius: 12,
                                    offset: const Offset(0, 6),
                                  ),
                                ]
                              : [],
                        ),
                        child: Text(
                          level,
                          style: TextStyle(
                            color: isSelected
                                ? Colors.white
                                : (isDark ? Colors.white70 : kDeepNavy),
                            fontWeight: FontWeight.w900,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),

            const SizedBox(height: 40),

            // ANA AKSİYON KARTI
            _buildMainDashboardCard(context),

            const SizedBox(height: 25),

            // TİP KARTI
            Container(
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                color: isDark
                    ? Colors.white.withOpacity(0.04)
                    : Colors.black.withOpacity(0.03),
                borderRadius: BorderRadius.circular(28),
                border: Border.all(
                  color: isDark ? Colors.white10 : Colors.black12,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.amber.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.tips_and_updates_rounded,
                      color: Colors.amber,
                    ),
                  ),
                  const SizedBox(width: 18),
                  const Expanded(
                    child: Text(
                      "Oyunlar seçtiğin seviyelerden rastgele kelimeler getirir. Kendini zorla!",
                      style: TextStyle(
                        fontSize: 13,
                        height: 1.4,
                        color: Colors.grey,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 120),
          ],
        ),
      ),
    );
  }

  Widget _buildMainDashboardCard(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) =>
              OyunSecimSayfasi(seciliSeviyeler: _selectedLevels.toList()),
        ),
      ),
      child: Container(
        height: 240,
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(35),
          gradient: const LinearGradient(
            colors: [kAccentCopper, Color(0xFFE08E79)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: kAccentCopper.withOpacity(0.4),
              blurRadius: 25,
              offset: const Offset(0, 15),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(35),
          child: Stack(
            children: [
              Positioned(
                right: -30,
                top: -30,
                child: Icon(
                  Icons.rocket_launch_rounded,
                  size: 220,
                  color: Colors.white.withOpacity(0.12),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(35),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    const Text(
                      "OYUN\nKATALOĞU",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 32,
                        fontWeight: FontWeight.w900,
                        height: 1.1,
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      "Hız ve zeka odaklı modlar",
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 30,
                        vertical: 15,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: const Text(
                        "MACERAYA BAŞLA",
                        style: TextStyle(
                          color: kAccentCopper,
                          fontWeight: FontWeight.w900,
                          fontSize: 13,
                          letterSpacing: 1,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// --- OYUN KATALOĞU (MODERN GRID) ---
class OyunSecimSayfasi extends StatelessWidget {
  final List<String> seciliSeviyeler;
  const OyunSecimSayfasi({super.key, required this.seciliSeviyeler});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          "MODUNU SEÇ",
          style: GoogleFonts.montserrat(
            fontWeight: FontWeight.w900,
            fontSize: 16,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: GridView.count(
        padding: const EdgeInsets.all(25),
        crossAxisCount: 2,
        mainAxisSpacing: 20,
        crossAxisSpacing: 20,
        childAspectRatio: 0.82,
        physics: const BouncingScrollPhysics(),
        children: [
          _modernGameCard(
            context,
            "ZAMANA KARŞI",
            Icons.timer_outlined,
            kAccentCopper,
            () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      ZamanaKarsiOyunEkrani(seciliSeviyeler: seciliSeviyeler),
                ),
              );
            },
          ),
          _modernGameCard(
            context,
            "WORDLE",
            Icons.grid_on_rounded,
            Colors.blueAccent,
            () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      WordleUnlimitedScreen(seciliSeviyeler: seciliSeviyeler),
                ),
              );
            },
          ),
          _modernGameCard(
            context,
            "HARF LAB",
            Icons.biotech_rounded,
            Colors.greenAccent,
            () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const HarfLaboratuvariScreen(),
                ),
              );
            },
          ),
          _modernGameCard(
            context,
            "CHAIN AI",
            Icons.auto_awesome_rounded,
            Colors.purpleAccent,
            () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const WordChainScreen(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _modernGameCard(
    BuildContext context,
    String title,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? color.withOpacity(0.08) : color.withOpacity(0.05),
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: color.withOpacity(0.2), width: 1.5),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: color.withOpacity(0.1),
                    blurRadius: 15,
                    spreadRadius: 1,
                  ),
                ],
              ),
              child: Icon(icon, size: 40, color: color),
            ),
            const SizedBox(height: 20),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: isDark ? Colors.white : kDeepNavy,
                fontWeight: FontWeight.w900,
                fontSize: 14,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
