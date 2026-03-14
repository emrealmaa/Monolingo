import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_tts/flutter_tts.dart'; // AGA: Seslendirme için eklendi
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
  int dogruSayisi = 0;
  int yanlisSayisi = 0;
  final FlutterTts flutterTts = FlutterTts(); // AGA: Ses motoru hazır

  @override
  void initState() {
    super.initState();
    widget.liste.shuffle();
    _initTts();
  }

  // AGA: Seslendirme ayarları
  void _initTts() async {
    await flutterTts.setLanguage("en-US");
    await flutterTts.setPitch(1.0);
    await flutterTts.setSpeechRate(0.5);
    _speak(widget.liste[_idx].word); // İlk kelimeyi oku
  }

  Future<void> _speak(String text) async {
    await flutterTts.speak(text);
  }

  void _sonrakiKelime(bool bildiMi) async {
    final word = widget.liste[_idx];

    // AGA: Artık kelimeAsamaGuncelleAlistirma metodunu çağırıyoruz
    // Bu sayede sınav kulvarındaki asıl ilerleme (tarihler) bozulmuyor.
    if (word.id != null) {
      await DbHelper().kelimeAsamaGuncelleAlistirma(word.id!, bildiMi);
    }

    if (bildiMi) {
      dogruSayisi++;
    } else {
      yanlisSayisi++;
    }

    if (_idx < widget.liste.length - 1) {
      setState(() {
        _idx++;
      });
      _speak(widget.liste[_idx].word); // Yeni gelen kelimeyi oku
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
          "ALIŞTIRMA BİTTİ",
          textAlign: TextAlign.center,
          style: GoogleFonts.montserrat(
            color: kAccentCopper,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.psychology, color: kAccentCopper, size: 70),
            const SizedBox(height: 20),
            Text(
              "Öğrenilen: $dogruSayisi",
              style: const TextStyle(fontSize: 18, color: Colors.greenAccent),
            ),
            Text(
              "Tekrar Gereken: $yanlisSayisi",
              style: const TextStyle(fontSize: 18, color: Colors.redAccent),
            ),
            const SizedBox(height: 10),
            const Text(
              "Bu kelimeler sınav vakti geldiğinde karşına çıkacak.",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, color: Colors.grey),
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
              "DEVAM ET",
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
          "${widget.seviye} Alıştırma",
          style: TextStyle(color: isDark ? Colors.white : kDeepNavy),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.volume_up, color: kAccentCopper),
            onPressed: () => _speak(word.word), // Manuel seslendirme
          ),
        ],
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

          // AGA: Buradaki aşama artık alıştırma aşamasını (asama_alistirma) temsil ediyor
          _buildAlistirmaBadge(word.asama),

          Expanded(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30),
                child: FlipCardWidget(
                  key: ValueKey(word.id ?? _idx),
                  word: word,
                ),
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(25),
            child: Row(
              children: [
                _buildActionButon(
                  "BİLEMEDİM",
                  Colors.redAccent.withOpacity(0.8),
                  false,
                  Icons.close,
                ),
                const SizedBox(width: 15),
                _buildActionButon(
                  "BİLDİM",
                  Colors.green.withOpacity(0.8),
                  true,
                  Icons.check,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAlistirmaBadge(int asama) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.blueAccent.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        "Alıştırma Seviyesi: $asama/6",
        style: const TextStyle(
          color: Colors.blueAccent,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildActionButon(
    String label,
    Color color,
    bool success,
    IconData icon,
  ) {
    return Expanded(
      child: ElevatedButton.icon(
        icon: Icon(icon, color: Colors.white, size: 20),
        label: Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          minimumSize: const Size(0, 65),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
        ),
        onPressed: () => _sonrakiKelime(success),
      ),
    );
  }
}
