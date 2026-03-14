import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../data/db_helper.dart';
import '../models/word_model.dart';
import '../data/kelime_servisi.dart';
import '../constants/constants.dart';
import 'test_screen.dart';
import 'quiz_screen.dart';
import '../models/quiz_settings.dart';

class OgrenmeSekmesi extends StatefulWidget {
  const OgrenmeSekmesi({super.key});

  @override
  State<OgrenmeSekmesi> createState() => _OgrenmeSekmesiState();
}

class _OgrenmeSekmesiState extends State<OgrenmeSekmesi> {
  String _lev = 'A1';
  double _learningCount = 10;
  bool _isTimed = true;
  double _quizDuration = 60;
  double _quizQuestionCount = 20;
  bool _showInstantFeedback = true;

  // --- LOGIC KISMI (DEĞİŞMEDİ) ---
  void _mesajGoster(String mesaj) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mesaj),
        backgroundColor: kDeepNavy,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _yukleniyorGoster() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) =>
          const Center(child: CircularProgressIndicator(color: kAccentCopper)),
    );
  }

  Future<void> _yolculugaBasla() async {
    _yukleniyorGoster();
    try {
      List<WordModel> hamListe = KelimeServisi.getKelimelerByLevel(_lev);
      if (hamListe.isEmpty) {
        if (mounted) Navigator.pop(context);
        _mesajGoster("Bu seviyede kelime bulunamadı!");
        return;
      }
      await DbHelper().kelimeDurumlariniSenkronizeEt(hamListe);
      var vaktigelmisListe = await DbHelper().ogrenilecekKelimeleriGetir(
        _lev,
        _learningCount.toInt(),
      );
      if (mounted) Navigator.pop(context);

      if (vaktigelmisListe.isNotEmpty) {
        vaktigelmisListe.shuffle();
        if (mounted) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  TestEkrani(seviye: _lev, liste: vaktigelmisListe),
            ),
          );
        }
      } else {
        _mesajGoster("Şu an çalışacak kelime yok, dinlen!");
      }
    } catch (e) {
      if (mounted) Navigator.pop(context);
      _mesajGoster("Hata: $e");
    }
  }

  void _sinaviBaslat() {
    QuizSettings settings = QuizSettings();
    settings.level = _lev;
    settings.isTimed = _isTimed;
    settings.duration = _quizDuration.toInt();
    settings.questionCount = _quizQuestionCount.toInt();
    settings.showFeedback = _showInstantFeedback;

    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => QuizScreen(settings: settings)),
    );
  }

  // --- GÖRSEL TASARIM ---
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 70),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          const SizedBox(height: 40),

          _sectionLabel("SEVİYE SEÇİMİ"),
          _buildLevelSelector(isDark),

          const SizedBox(height: 30),

          // ÖĞRENME KARTI
          _buildGlassCard(
            title: "ÖĞRENME MODU",
            subtitle: "Yeni kelimeler keşfet ve ezberle",
            icon: Icons.auto_stories,
            accentColor: kAccentCopper,
            child: Column(
              children: [
                _customSlider(
                  value: _learningCount,
                  min: 5,
                  max: 100,
                  label: "${_learningCount.toInt()} Kelime Hedefi",
                  activeColor: kAccentCopper,
                  onChanged: (v) => setState(() => _learningCount = v),
                ),
                _mainActionButton(
                  "YOLCULUĞA BAŞLA",
                  kAccentCopper,
                  _yolculugaBasla,
                ),
              ],
            ),
          ),

          const SizedBox(height: 25),

          // SINAV KARTI
          _buildGlassCard(
            title: "SINAV MERKEZİ",
            subtitle: "Kendini test et ve seviyeni gör",
            icon: Icons.psychology,
            accentColor: Colors.orangeAccent,
            child: Column(
              children: [
                _customSlider(
                  value: _quizQuestionCount,
                  min: 5,
                  max: 50,
                  label: "${_quizQuestionCount.toInt()} Soru Hazır",
                  activeColor: Colors.orangeAccent,
                  onChanged: (v) => setState(() => _quizQuestionCount = v),
                ),
                _buildQuickSwitch(
                  "Anlık Geri Bildirim",
                  _showInstantFeedback,
                  (v) => setState(() => _showInstantFeedback = v),
                ),
                _buildQuickSwitch(
                  "Süreli Sınav",
                  _isTimed,
                  (v) => setState(() => _isTimed = v),
                ),
                if (_isTimed)
                  _customSlider(
                    value: _quizDuration,
                    min: 30,
                    max: 300,
                    label: "${_quizDuration.toInt()} Saniye Süre",
                    activeColor: Colors.redAccent,
                    onChanged: (v) => setState(() => _quizDuration = v),
                  ),
                const SizedBox(height: 10),
                _mainActionButton(
                  "SINAVI BAŞLAT",
                  Colors.orangeAccent,
                  _sinaviBaslat,
                ),
              ],
            ),
          ),
          const SizedBox(height: 80), // Nav bar boşluğu
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Monolingo",
          style: GoogleFonts.montserrat(
            color: kAccentCopper,
            fontWeight: FontWeight.w900,
            fontSize: 38,
            letterSpacing: 2,
          ),
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            Icon(
              Icons.auto_awesome,
              size: 16,
              color: kAccentCopper.withOpacity(0.8),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                "Bugün yeni bir kelime, yarın yeni bir dünya .",
                style: GoogleFonts.poppins(
                  color: Colors.grey[500],
                  fontSize: 14,
                  fontStyle: FontStyle.italic,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _sectionLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(left: 5, bottom: 10),
      child: Text(
        label,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          letterSpacing: 1.5,
          fontSize: 12,
          color: Colors.grey,
        ),
      ),
    );
  }

  Widget _buildLevelSelector(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withOpacity(0.05)
            : Colors.black.withOpacity(0.05),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: ['A1', 'A2', 'B1', 'B2', 'C1'].map((level) {
          bool isSelected = _lev == level;
          return GestureDetector(
            onTap: () => setState(() => _lev = level),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(
                color: isSelected ? kAccentCopper : Colors.transparent,
                borderRadius: BorderRadius.circular(15),
              ),
              child: Text(
                level,
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.grey,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildGlassCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color accentColor,
    required Widget child,
  }) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(30),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.all(25),
          decoration: BoxDecoration(
            color: accentColor.withOpacity(0.05),
            borderRadius: BorderRadius.circular(30),
            border: Border.all(color: accentColor.withOpacity(0.2)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(icon, color: accentColor, size: 28),
                  const SizedBox(width: 15),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontWeight: FontWeight.w900,
                          fontSize: 18,
                        ),
                      ),
                      Text(
                        subtitle,
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 15),
                child: Divider(color: Colors.white10),
              ),
              child,
            ],
          ),
        ),
      ),
    );
  }

  Widget _customSlider({
    required double value,
    required double min,
    required double max,
    required String label,
    required Color activeColor,
    required Function(double) onChanged,
  }) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
            ),
            Text(
              value.toInt().toString(),
              style: TextStyle(color: activeColor, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        Slider(
          value: value,
          min: min,
          max: max,
          activeColor: activeColor,
          inactiveColor: activeColor.withOpacity(0.1),
          onChanged: onChanged,
        ),
      ],
    );
  }

  Widget _buildQuickSwitch(String title, bool value, Function(bool) onChanged) {
    return SwitchListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(title, style: const TextStyle(fontSize: 14)),
      value: value,
      activeColor: Colors.orangeAccent,
      onChanged: onChanged,
    );
  }

  Widget _mainActionButton(String title, Color color, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 55),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          elevation: 5,
          shadowColor: color.withOpacity(0.4),
        ),
        onPressed: onTap,
        child: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.w900,
            letterSpacing: 1.5,
          ),
        ),
      ),
    );
  }
}
