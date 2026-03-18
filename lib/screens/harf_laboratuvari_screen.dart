import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/constants.dart';
import '../data/db_helper.dart';

class HarfLaboratuvariScreen extends StatefulWidget {
  const HarfLaboratuvariScreen({super.key});

  @override
  State<HarfLaboratuvariScreen> createState() => _HarfLaboratuvariScreenState();
}

class _HarfLaboratuvariScreenState extends State<HarfLaboratuvariScreen> {
  String hedefKelime = "";
  String anlam = "";
  List<String> harfler = [];
  List<int> seciliIndeksler = [];
  String suankiKelime = "";
  bool yukleniyor = true;
  Offset? parmakPozisyonu;
  bool cevabiGoster = false; // AGA: Pas geçince cevabı göstermek için

  int puan = 0;
  int can = 3;
  List<String> topScores = [];

  @override
  void initState() {
    super.initState();
    _loadTopScores();
    _yeniKelimeGetir();
  }

  Future<void> _loadTopScores() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      topScores = prefs.getStringList('top_scores_lab') ?? ["0", "0", "0"];
    });
  }

  Future<void> _checkAndSaveScore() async {
    final prefs = await SharedPreferences.getInstance();
    List<int> scores = topScores.map((e) => int.parse(e)).toList();
    scores.add(puan);
    scores.sort((a, b) => b.compareTo(a));
    List<String> newTop3 = scores.take(3).map((e) => e.toString()).toList();
    await prefs.setStringList('top_scores_lab', newTop3);
    setState(() => topScores = newTop3);
  }

  Future<void> _yeniKelimeGetir() async {
    setState(() {
      yukleniyor = true;
      cevabiGoster = false;
    });
    final dbHelper = DbHelper();
    final kelimeVerisi = await dbHelper.getRandomWordByLevel("A1");

    setState(() {
      hedefKelime = kelimeVerisi['word'].toString().toUpperCase().trim();
      anlam = kelimeVerisi['meaning'] ?? "Gizli Kelime";
      harfler = hedefKelime.split('')..shuffle();
      seciliIndeksler.clear();
      suankiKelime = "";
      yukleniyor = false;
    });
  }

  // AGA: Pas geçince cevabı 1 saniye gösteren mantık
  void _pasGec() async {
    if (can > 0) {
      setState(() {
        can--;
        cevabiGoster = true;
        suankiKelime = hedefKelime; // Kutucukları doldur
      });

      await Future.delayed(const Duration(seconds: 1));

      if (can <= 0) {
        _oyunBittiDialog();
      } else {
        _yeniKelimeGetir();
      }
    }
  }

  void _oyunBittiDialog() {
    _checkAndSaveScore();
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).cardColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        title: Text(
          "LAB PATLADI! 🔥",
          textAlign: TextAlign.center,
          style: GoogleFonts.montserrat(
            fontWeight: FontWeight.w900,
            color: Colors.redAccent,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "Toplam Puanın:",
              style: GoogleFonts.montserrat(color: Colors.grey),
            ),
            Text(
              "$puan",
              style: GoogleFonts.montserrat(
                fontSize: 40,
                fontWeight: FontWeight.w900,
                color: kAccentCopper,
              ),
            ),
            const Divider(),
            ...topScores.map(
              (s) => Text(
                "$s Puan",
                style: GoogleFonts.montserrat(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
        actions: [
          Center(
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: kAccentCopper,
                shape: const StadiumBorder(),
              ),
              onPressed: () {
                Navigator.pop(context);
                setState(() {
                  puan = 0;
                  can = 3;
                });
                _yeniKelimeGetir();
              },
              child: const Text(
                "TEKRAR DENE",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Color textColor = isDark ? Colors.white : kDeepNavy;

    if (yukleniyor)
      return Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: const Center(
          child: CircularProgressIndicator(color: kAccentCopper),
        ),
      );

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Stack(
        children: [
          Positioned(
            top: 50,
            left: 20,
            child: IconButton(
              icon: Icon(Icons.help_outline, color: textColor, size: 28),
              onPressed: _kuralGoster,
            ),
          ),
          Positioned(
            top: 50,
            right: 20,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Row(
                  children: List.generate(
                    3,
                    (index) => Icon(
                      index < can
                          ? Icons.favorite_rounded
                          : Icons.favorite_border_rounded,
                      color: Colors.redAccent,
                      size: 24,
                    ),
                  ),
                ),
                const SizedBox(height: 5),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: kAccentCopper,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    "SCORE: $puan",
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 80),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40),
                  child: Text(
                    anlam.toUpperCase(),
                    textAlign: TextAlign.center,
                    style: GoogleFonts.montserrat(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white70 : Colors.black54,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
                const SizedBox(height: 40),
                _buildWordSlots(isDark),
                const Spacer(),
                if (can > 0 && !cevabiGoster)
                  TextButton.icon(
                    onPressed: _pasGec,
                    icon: const Icon(
                      Icons.skip_next_rounded,
                      color: Colors.grey,
                    ),
                    label: const Text(
                      "BU KELİMEYİ PAS GEÇ (-1 CAN)",
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                const SizedBox(height: 20),
                if (suankiKelime.isNotEmpty) _buildPreviewBaloon(),
                const SizedBox(height: 30),
                _buildConnectCircle(isDark),
                const SizedBox(height: 60),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPreviewBaloon() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 12),
      decoration: BoxDecoration(
        color: cevabiGoster ? Colors.redAccent : kAccentCopper,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: (cevabiGoster ? Colors.redAccent : kAccentCopper)
                .withOpacity(0.3),
            blurRadius: 15,
          ),
        ],
      ),
      child: Text(
        suankiKelime,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 22,
          fontWeight: FontWeight.bold,
          letterSpacing: 2,
        ),
      ),
    );
  }

  Widget _buildWordSlots(bool isDark) {
    return Wrap(
      spacing: 10,
      alignment: WrapAlignment.center,
      children: List.generate(hedefKelime.length, (index) {
        bool revealed = suankiKelime.length > index;
        return Container(
          width: 42,
          height: 52,
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(isDark ? 0.3 : 0.05),
                blurRadius: 10,
              ),
            ],
            border: Border.all(
              color: revealed
                  ? kAccentCopper
                  : (isDark ? Colors.white10 : Colors.black12),
            ),
          ),
          child: Center(
            child: Text(
              revealed ? suankiKelime[index] : "",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : kDeepNavy,
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildConnectCircle(bool isDark) {
    return Center(
      child: GestureDetector(
        onPanUpdate: cevabiGoster
            ? null
            : (details) {
                setState(() => parmakPozisyonu = details.localPosition);
                _harfKontrol(details.localPosition);
              },
        onPanEnd: cevabiGoster ? null : (_) => _secimiBitir(),
        child: Container(
          width: 260,
          height: 260,
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(isDark ? 0.4 : 0.05),
                blurRadius: 40,
                spreadRadius: 5,
              ),
            ],
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              CustomPaint(
                size: const Size(260, 260),
                painter: LinePainter(
                  seciliIndeksler.map((idx) {
                    double aci = (idx * 2 * pi / harfler.length) - pi / 2;
                    return Offset(130 + 90 * cos(aci), 130 + 90 * sin(aci));
                  }).toList(),
                  parmakPozisyonu,
                  kAccentCopper,
                ),
              ),
              ..._buildLetterButtons(isDark),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _buildLetterButtons(bool isDark) {
    return List.generate(harfler.length, (i) {
      double aci = (i * 2 * pi / harfler.length) - pi / 2;
      double x = 130 + 90 * cos(aci) - 25;
      double y = 130 + 90 * sin(aci) - 25;
      bool secili = seciliIndeksler.contains(i);

      return Positioned(
        left: x,
        top: y,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: secili ? kAccentCopper : Theme.of(context).cardColor,
            shape: BoxShape.circle,
            border: Border.all(
              color: secili
                  ? kAccentCopper
                  : (isDark ? Colors.white24 : Colors.black12),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: secili
                    ? kAccentCopper.withOpacity(0.3)
                    : Colors.transparent,
                blurRadius: 10,
              ),
            ],
          ),
          child: Center(
            child: Text(
              harfler[i],
              style: GoogleFonts.montserrat(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: secili
                    ? Colors.white
                    : (isDark ? Colors.white : kDeepNavy),
              ),
            ),
          ),
        ),
      );
    });
  }

  void _harfKontrol(Offset localPos) {
    for (int i = 0; i < harfler.length; i++) {
      double aci = (i * 2 * pi / harfler.length) - pi / 2;
      double x = 130 + 90 * cos(aci);
      double y = 130 + 90 * sin(aci);
      double mesafe = sqrt(pow(x - localPos.dx, 2) + pow(y - localPos.dy, 2));
      if (mesafe < 30 && !seciliIndeksler.contains(i)) {
        setState(() {
          seciliIndeksler.add(i);
          suankiKelime += harfler[i];
        });
      }
    }
  }

  void _secimiBitir() {
    if (suankiKelime == hedefKelime) {
      setState(() {
        puan += (hedefKelime.length * 10);
      });
      _yeniKelimeGetir();
    } else {
      setState(() {
        seciliIndeksler.clear();
        suankiKelime = "";
        parmakPozisyonu = null;
      });
    }
  }

  void _kuralGoster() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).cardColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
        title: Text(
          "Oyun Kuralları 🧪",
          style: GoogleFonts.montserrat(
            fontWeight: FontWeight.bold,
            color: kAccentCopper,
          ),
        ),
        content: Text(
          "• Harfleri birleştirerek gizli kelimeyi bul.\n• Bilmediğin kelimeleri PAS GEÇ butonuna basarak atlayabilirsin (-1 can).\n• Pas geçince cevap kısa süreliğine görünür.",
          style: TextStyle(
            color: Theme.of(context).brightness == Brightness.dark
                ? Colors.white70
                : Colors.black87,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              "BAŞLAYALIM!",
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
}

class LinePainter extends CustomPainter {
  final List<Offset> points;
  final Offset? fingerPos;
  final Color color;
  LinePainter(this.points, this.fingerPos, this.color);

  @override
  void paint(Canvas canvas, Size size) {
    if (points.isEmpty) return;
    final paint = Paint()
      ..color = color
      ..strokeWidth = 6.0
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    Path path = Path();
    path.moveTo(points[0].dx, points[0].dy);
    for (int i = 1; i < points.length; i++) {
      path.lineTo(points[i].dx, points[i].dy);
    }
    if (fingerPos != null) {
      path.lineTo(fingerPos!.dx, fingerPos!.dy);
    }
    canvas.drawShadow(path, color.withOpacity(0.5), 10, true);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(LinePainter oldDelegate) => true;
}
