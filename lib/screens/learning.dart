import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../data/db_helper.dart';
import '../models/word_model.dart';
import '../data/kelime_servisi.dart';
import '../constants/constants.dart';
import 'test_screen.dart';

class OgrenmeSekmesi extends StatefulWidget {
  const OgrenmeSekmesi({super.key});

  @override
  State<OgrenmeSekmesi> createState() => _OgrenmeSekmesiState();
}

class _OgrenmeSekmesiState extends State<OgrenmeSekmesi> {
  String _lev = 'A1';
  double _count = 10;

  void _mesajGoster(String mesaj) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mesaj),
        // MODA GÖRE DEĞİŞEN SNACKBAR
        backgroundColor: Theme.of(context).cardColor,
      ),
    );
  }

  Future<void> _yolculugaBasla() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) =>
          const Center(child: CircularProgressIndicator(color: kAccentCopper)),
    );

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
        _count.toInt(),
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

  @override
  Widget build(BuildContext context) {
    // 1. ADIM: MODU KONTROL ET
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(30),
      child: Column(
        children: [
          const SizedBox(height: 60),
          const Icon(Icons.explore_outlined, size: 80, color: kAccentCopper),
          Text(
            "MONOLINGO",
            style: GoogleFonts.montserrat(
              fontSize: 32,
              fontWeight: FontWeight.w900,
              color: kAccentCopper,
              letterSpacing: 5,
            ),
          ),
          const SizedBox(height: 40),

          // --- SEVİYE SEÇİMİ ---
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            decoration: BoxDecoration(
              // 2. ADIM: KART RENGİ ARTIK AKILLI
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(15),
              border: Border.all(
                color: isDark ? Colors.white10 : Colors.black12,
              ),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _lev,
                isExpanded: true,
                // 3. ADIM: DROPDOWN LİSTESİ MODA GÖRE
                dropdownColor: Theme.of(context).cardColor,
                items: ['A1', 'A2', 'B1', 'B2', 'C1']
                    .map(
                      (s) => DropdownMenuItem(
                        value: s,
                        child: Text(
                          s,
                          // 4. ADIM: YAZI RENGİ MODA GÖRE
                          style: TextStyle(
                            color: isDark ? Colors.white : kDeepNavy,
                          ),
                        ),
                      ),
                    )
                    .toList(),
                onChanged: (v) => setState(() => _lev = v!),
              ),
            ),
          ),

          const SizedBox(height: 20),

          // --- KELİME SAYISI ---
          Slider(
            value: _count,
            min: 5,
            max: 100,
            divisions: 19,
            activeColor: kAccentCopper,
            inactiveColor: isDark ? Colors.white10 : Colors.black12,
            label: _count.toInt().toString(),
            onChanged: (v) => setState(() => _count = v),
          ),
          Text(
            "Hedef: ${_count.toInt()} Kelime",
            style: TextStyle(
              // 5. ADIM: ALT YAZI RENGİ
              color: isDark ? Colors.white70 : Colors.black54,
              fontWeight: FontWeight.w500,
            ),
          ),

          const SizedBox(height: 40),

          // --- BAŞLAT BUTONU ---
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: kAccentCopper,
              // 6. ADIM: BUTON ÜSTÜ YAZI RENGİ
              foregroundColor: isDark ? kDeepNavy : Colors.white,
              minimumSize: const Size(double.infinity, 65),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            onPressed: _yolculugaBasla,
            child: const Text(
              "YOLCULUĞA BAŞLA",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                letterSpacing: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
