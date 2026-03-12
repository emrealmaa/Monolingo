import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../data/db_helper.dart';
import '../models/word_model.dart';
import '../constants/constants.dart';
import '../widgets/flip_card.dart';

class TestEkrani extends StatefulWidget {
  final String seviye;
  final List<WordModel> liste;

  const TestEkrani({super.key, required this.seviye, required this.liste});

  @override
  State<TestEkrani> createState() => _TestEkraniState();
}

class _TestEkraniState extends State<TestEkrani> {
  int _idx = 0;
  bool _isHintVisible = false;
  int dogruSayisi = 0;
  int yanlisSayisi = 0;

  @override
  void initState() {
    super.initState();
    // Aga alfabetik sırayı burada bozuyoruz, her girişinde farklı gelir
    widget.liste.shuffle();
  }

  void _sonrakiKelime(bool bildiMi) async {
    final word = widget.liste[_idx];

    if (bildiMi) {
      dogruSayisi++;
      if (word.id != null) {
        await DbHelper().kelimeAsamaGuncelle(word.id!, word.asama + 1);
      }
    } else {
      yanlisSayisi++;
      if (word.id != null) {
        await DbHelper().kelimeAsamaGuncelle(word.id!, 1);
      }
    }

    if (_idx < widget.liste.length - 1) {
      setState(() {
        _idx++;
        _isHintVisible = false;
      });
    } else {
      _sonucGoster();
    }
  }

  void _sonucGoster() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).cardColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          "TEST BİTTİ !",
          textAlign: TextAlign.center,
          style: GoogleFonts.montserrat(
            color: kAccentCopper,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.emoji_events, color: kAccentCopper, size: 70),
            const SizedBox(height: 20),
            Text(
              "✅ Doğru: $dogruSayisi",
              style: const TextStyle(
                fontSize: 20,
                color: Colors.greenAccent,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              "❌ Yanlış: $yanlisSayisi",
              style: const TextStyle(
                fontSize: 20,
                color: Colors.redAccent,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text(
              "ANA SAYFAYA DÖN",
              style: TextStyle(
                color: kAccentCopper,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final word = widget.liste[_idx];
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        title: Text(
          "${widget.seviye} Seviyesi",
          style: TextStyle(color: isDark ? Colors.white : kDeepNavy),
        ),
        iconTheme: IconThemeData(color: isDark ? Colors.white : kDeepNavy),
      ),
      body: Column(
        children: [
          LinearProgressIndicator(
            value: (_idx + 1) / widget.liste.length,
            color: kAccentCopper,
            backgroundColor: isDark ? Colors.white10 : Colors.black12,
            minHeight: 6,
          ),
          const SizedBox(height: 20),
          // AŞAMA GÖSTERGESİ
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
            decoration: BoxDecoration(
              color: kAccentCopper.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              "Kelime Aşaması: ${word.asama}/6",
              style: const TextStyle(
                color: kAccentCopper,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // KART
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 30),
                  child: FlipCardWidget(
                    key: ValueKey(word.id ?? _idx),
                    word: word,
                  ),
                ),
                // İPUCU BUTONU BURADAN UÇTU AGA
              ],
            ),
          ),

          // BUTONLAR
          Padding(
            padding: const EdgeInsets.all(25),
            child: Row(
              children: [
                _buildActionButon("BİLEMEDİM", Colors.redAccent, false),
                const SizedBox(width: 15),
                _buildActionButon("BİLDİM", Colors.green, true),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButon(String label, Color color, bool success) {
    return Expanded(
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          minimumSize: const Size(0, 65),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          elevation: 5,
        ),
        onPressed: () => _sonrakiKelime(success),
        child: Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ),
    );
  }
}
