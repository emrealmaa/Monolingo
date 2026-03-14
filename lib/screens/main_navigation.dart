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
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: PageView(
        controller: _pc,
        onPageChanged: (i) => setState(() => _curr = i),
        children: [
          const OgrenmeSekmesi(),
          const OyunLobiSekmesi(),
          const IstatistikSekmesi(),
          ProfilSekmesi(isim: widget.isim, email: widget.email),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _curr,
        type: BottomNavigationBarType.fixed,
        backgroundColor: Theme.of(context).cardColor,
        selectedItemColor: kAccentCopper,
        unselectedItemColor: isDark ? Colors.white38 : Colors.black38,
        onTap: (i) => _pc.jumpToPage(i),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.auto_stories),
            label: "Öğren",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.videogame_asset),
            label: "Oyun",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart),
            label: "İstatistik",
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profil"),
        ],
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
  // AGA: final yerine normal tanımlayalım ki state karışmasın
  List<String> _levels = ['A1', 'A2', 'B1', 'B2', 'C1'];
  Set<String> _selectedLevels = {'A1', 'A2', 'B1', 'B2', 'C1'};

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // EĞER HALA NULL GÖRÜYORSA BURASI SİGORTA:
    if (_levels == null || _selectedLevels == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.psychology, size: 80, color: kAccentCopper),
            const SizedBox(height: 20),
            Text(
              "KELİME MERKEZİ",
              style: GoogleFonts.montserrat(
                fontSize: 26,
                fontWeight: FontWeight.w900,
                color: isDark ? Colors.white : kDeepNavy,
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: 30),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              alignment: WrapAlignment.center,
              children: _levels.map((level) {
                // BURASI HATA VEREN YERDİ, contains öncesi null kontrolü ekledim
                final isSelected = _selectedLevels.contains(level);
                return FilterChip(
                  label: Text(level),
                  selected: isSelected,
                  selectedColor: kAccentCopper,
                  checkmarkColor: isDark ? kDeepNavy : Colors.white,
                  showCheckmark: false,
                  labelStyle: TextStyle(
                    color: isSelected
                        ? (isDark ? kDeepNavy : Colors.white)
                        : (isDark ? Colors.white : kDeepNavy),
                    fontWeight: FontWeight.bold,
                  ),
                  backgroundColor: Theme.of(context).cardColor,
                  side: BorderSide(
                    color: isDark ? Colors.white10 : Colors.black12,
                  ),
                  onSelected: (bool selected) {
                    setState(() {
                      if (selected) {
                        _selectedLevels.add(level);
                      } else if (_selectedLevels.length > 1) {
                        _selectedLevels.remove(level);
                      }
                    });
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 50),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: kAccentCopper,
                foregroundColor: isDark ? kDeepNavy : Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 40,
                  vertical: 18,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              icon: const Icon(Icons.style, size: 26),
              label: const Text(
                "OYUN KATALOĞUNU AÇ",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => OyunSecimSayfasi(
                      seciliSeviyeler: _selectedLevels.toList(),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

// --- OYUN SEÇİM SAYFASI (KATALOG) ---
class OyunSecimSayfasi extends StatelessWidget {
  final List<String> seciliSeviyeler;
  const OyunSecimSayfasi({super.key, required this.seciliSeviyeler});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text("OYUN KATALOĞU"),
        backgroundColor: Theme.of(context).cardColor,
        foregroundColor: isDark ? Colors.white : kDeepNavy,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            _oyunKarti(
              context,
              baslik: "ZAMANA KARŞI AV",
              altBaslik: "Harfleri hızlıca diz, süreyi dondur!",
              ikon: Icons.timer_outlined,
              renk: kAccentCopper,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        ZamanaKarsiOyunEkrani(seciliSeviyeler: seciliSeviyeler),
                  ),
                );
              },
            ),
            const SizedBox(height: 20),
            _oyunKarti(
              context,
              baslik: "WORDLE UNLIMITED",
              altBaslik: "Günlük sınır yok, istediğin kadar Wordle oyna!",
              ikon: Icons.flash_on,
              renk: Colors.blueAccent,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        WordleUnlimitedScreen(seciliSeviyeler: seciliSeviyeler),
                  ),
                );
              },
            ),
            const SizedBox(height: 20),
            _oyunKarti(
              context,
              baslik: "HARF LABORATUVARI",
              altBaslik: "Eksik harfleri tamamlayarak ilerle.",
              ikon: Icons.biotech,
              renk: Colors.greenAccent,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const HarfLaboratuvariScreen(),
                  ),
                );
              },
            ),
            const SizedBox(height: 20),
            _oyunKarti(
              context,
              baslik: "WORD CHAIN AI",
              altBaslik: "5 kelimeyle yapay zeka hikayeni ve resmini çizsin!",
              ikon: Icons.auto_awesome,
              renk: Colors.purpleAccent,
              onTap: () {
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
      ),
    );
  }

  Widget _oyunKarti(
    BuildContext context, {
    required String baslik,
    required String altBaslik,
    required IconData ikon,
    required Color renk,
    required VoidCallback onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isDark ? renk.withOpacity(0.3) : renk.withOpacity(0.1),
          ),
        ),
        child: Row(
          children: [
            Icon(ikon, size: 40, color: renk),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    baslik,
                    style: TextStyle(
                      color: isDark ? Colors.white : kDeepNavy,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    altBaslik,
                    style: TextStyle(
                      color: isDark ? Colors.white54 : Colors.black54,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: isDark ? Colors.white24 : Colors.black26,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }
}
