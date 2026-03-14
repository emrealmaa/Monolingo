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
  // --- DEĞİŞKENLER ---
  String _lev = 'A1';
  double _learningCount = 10;

  // Sınav Ayarları
  bool _isTimed = true;
  double _quizDuration = 60;
  double _quizQuestionCount = 20;
  bool _showInstantFeedback = true;

  // --- METODLAR ---

  void _mesajGoster(String mesaj) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mesaj),
        backgroundColor: Theme.of(context).cardColor,
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
        _mesajGoster("Şu an çalışacak kelimen yok, dinlenme zamanı!");
      }
    } catch (e) {
      if (mounted) Navigator.pop(context);
      _mesajGoster("Bir hata oluştu: $e");
    }
  }

  void _sinaviBaslat() {
    // Sınav ayarlarını modele paketliyoruz
    QuizSettings settings = QuizSettings();
    settings.level = _lev;
    settings.isTimed = _isTimed;
    settings.duration = _quizDuration.toInt();
    // Not: QuizSettings modelinde bu alanların tanımlı olduğundan emin ol aga
    settings.questionCount = _quizQuestionCount.toInt();
    settings.showFeedback = _showInstantFeedback;

    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => QuizScreen(settings: settings)),
    );
  }

  // --- ARAYÜZ ---

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(30),
      child: Column(
        children: [
          const SizedBox(height: 40),
          const Icon(Icons.explore_outlined, size: 70, color: kAccentCopper),
          Text(
            "MONOLINGO",
            style: GoogleFonts.montserrat(
              fontSize: 30,
              fontWeight: FontWeight.w900,
              color: kAccentCopper,
              letterSpacing: 5,
            ),
          ),
          const SizedBox(height: 30),

          // --- SEVİYE SEÇİMİ (GENEL) ---
          _sectionTitle("KATEGORİ SEÇİMİ", Icons.layers_outlined, isDark),
          _customDropdown(isDark),

          const SizedBox(height: 25),
          const Divider(color: Colors.white10, thickness: 1),
          const SizedBox(height: 25),

          // --- ÖĞRENME MODU ---
          _sectionTitle(
            "ÖĞRENME AYARLARI",
            Icons.auto_stories_outlined,
            isDark,
          ),
          _customSlider(
            value: _learningCount,
            min: 5,
            max: 100,
            onChanged: (v) => setState(() => _learningCount = v),
            label: "Hedef: ${_learningCount.toInt()} Kelime",
            isDark: isDark,
            activeColor: kAccentCopper,
          ),
          const SizedBox(height: 10),
          _actionButton(
            "YOLCULUĞA BAŞLA",
            _yolculugaBasla,
            isDark,
            kAccentCopper,
          ),

          const SizedBox(height: 30),
          const Divider(color: Colors.white10, thickness: 1),
          const SizedBox(height: 25),

          // --- SINAV MODU ---
          _sectionTitle("SINAV AYARLARI", Icons.quiz_outlined, isDark),

          // Soru Sayısı Slider
          _customSlider(
            value: _quizQuestionCount,
            min: 5,
            max: 50,
            onChanged: (v) => setState(() => _quizQuestionCount = v),
            label: "Sınav Soru Sayısı: ${_quizQuestionCount.toInt()}",
            isDark: isDark,
            activeColor: Colors.orangeAccent,
          ),

          // Anlık Bildirim Switch
          _customSwitch(
            title: "Anlık Geri Bildirim",
            subtitle: "Doğru/Yanlış anında gözüksün",
            value: _showInstantFeedback,
            onChanged: (v) => setState(() => _showInstantFeedback = v),
            isDark: isDark,
          ),

          // Süre Switch
          _customSwitch(
            title: "Süreli Sınav",
            subtitle: "Zamana karşı yarış",
            value: _isTimed,
            onChanged: (v) => setState(() => _isTimed = v),
            isDark: isDark,
          ),

          if (_isTimed)
            _customSlider(
              value: _quizDuration,
              min: 30,
              max: 300,
              onChanged: (v) => setState(() => _quizDuration = v),
              label: "Süre: ${_quizDuration.toInt()} Saniye",
              isDark: isDark,
              activeColor: Colors.redAccent,
            ),

          const SizedBox(height: 20),
          _actionButton(
            "SINAVI BAŞLAT",
            _sinaviBaslat,
            isDark,
            Colors.orangeAccent,
          ),
          const SizedBox(height: 50),
        ],
      ),
    );
  }

  // --- YARDIMCI BİLEŞENLER ---

  Widget _sectionTitle(String title, IconData icon, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 18, color: kAccentCopper),
          const SizedBox(width: 10),
          Text(
            title,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.5,
              color: isDark ? Colors.white54 : Colors.black45,
            ),
          ),
        ],
      ),
    );
  }

  Widget _customDropdown(bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: isDark ? Colors.white10 : Colors.black12),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _lev,
          isExpanded: true,
          dropdownColor: Theme.of(context).cardColor,
          items: ['A1', 'A2', 'B1', 'B2', 'C1']
              .map(
                (s) => DropdownMenuItem(
                  value: s,
                  child: Text(
                    s,
                    style: TextStyle(color: isDark ? Colors.white : kDeepNavy),
                  ),
                ),
              )
              .toList(),
          onChanged: (v) => setState(() => _lev = v!),
        ),
      ),
    );
  }

  Widget _customSlider({
    required double value,
    required double min,
    required double max,
    required Function(double) onChanged,
    required String label,
    required bool isDark,
    required Color activeColor,
  }) {
    return Column(
      children: [
        Slider(
          value: value,
          min: min,
          max: max,
          divisions: (max - min).toInt(),
          activeColor: activeColor,
          inactiveColor: isDark ? Colors.white10 : Colors.black12,
          onChanged: onChanged,
        ),
        Text(
          label,
          style: TextStyle(
            color: isDark ? Colors.white70 : Colors.black54,
            fontWeight: FontWeight.w500,
            fontSize: 13,
          ),
        ),
        const SizedBox(height: 15),
      ],
    );
  }

  Widget _customSwitch({
    required String title,
    required String subtitle,
    required bool value,
    required Function(bool) onChanged,
    required bool isDark,
  }) {
    return SwitchListTile(
      title: Text(
        title,
        style: TextStyle(
          color: isDark ? Colors.white : kDeepNavy,
          fontSize: 15,
          fontWeight: FontWeight.bold,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: const TextStyle(fontSize: 12, color: Colors.white38),
      ),
      value: value,
      activeColor: Colors.orangeAccent,
      onChanged: onChanged,
    );
  }

  Widget _actionButton(
    String title,
    VoidCallback onPressed,
    bool isDark,
    Color color,
  ) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: isDark ? kDeepNavy : Colors.white,
        minimumSize: const Size(double.infinity, 60),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        elevation: 0,
      ),
      onPressed: onPressed,
      child: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 16,
          letterSpacing: 1.2,
        ),
      ),
    );
  }
}
