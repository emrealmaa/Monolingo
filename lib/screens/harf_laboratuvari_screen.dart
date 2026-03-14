import 'dart:math';
import 'package:flutter/material.dart';
import '../constants/constants.dart';
import '../data/db_helper.dart';

class HarfLaboratuvariScreen extends StatefulWidget {
  const HarfLaboratuvariScreen({super.key});

  @override
  State<HarfLaboratuvariScreen> createState() => _HarfLaboratuvariScreenState();
}

class _HarfLaboratuvariScreenState extends State<HarfLaboratuvariScreen> {
  String? seciliZorluk;
  String? seciliSeviye;
  bool oyunBasladi = false;
  bool yukleniyor = false;

  String hedefKelime = "";
  String anlam = "";
  List<String> acilanHarfler = [];

  double oyuncuCan = 100;
  double botCan = 100;
  bool siraSende = true;

  Future<void> _savasBaslat() async {
    setState(() => yukleniyor = true);
    final dbHelper = DbHelper();
    final kelimeVerisi = await dbHelper.getRandomWordByLevel(
      seciliSeviye ?? "A1",
    );

    setState(() {
      hedefKelime = kelimeVerisi['word'].toString().toUpperCase().trim();
      anlam = kelimeVerisi['meaning'] ?? "Gizli Formül";
      acilanHarfler = [];
      oyuncuCan = 100;
      botCan = 100;
      siraSende = true;
      yukleniyor = false;
    });
  }

  void _hamleYap(String harf) {
    if (!siraSende ||
        acilanHarfler.contains(harf) ||
        oyuncuCan <= 0 ||
        botCan <= 0)
      return;

    setState(() {
      acilanHarfler.add(harf);
      if (hedefKelime.contains(harf)) {
        int adet = hedefKelime.split(harf).length - 1;
        botCan = (botCan - (adet * 12)).clamp(0, 100);
      } else {
        oyuncuCan = (oyuncuCan - 15).clamp(0, 100);
      }
      siraSende = false;
    });

    if (botCan > 0 && oyuncuCan > 0) {
      _botunSaldirisi();
    } else {
      _oyunSonu(botCan <= 0);
    }
  }

  void _botunSaldirisi() async {
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;

    int iq = seciliZorluk == "Zor" ? 85 : (seciliZorluk == "Orta" ? 55 : 25);
    String secim = "";

    if (Random().nextInt(100) < iq) {
      for (var c in hedefKelime.split('')) {
        if (!acilanHarfler.contains(c)) {
          secim = c;
          break;
        }
      }
    }

    if (secim == "") {
      secim = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"[Random().nextInt(26)];
    }

    setState(() {
      if (!acilanHarfler.contains(secim)) {
        acilanHarfler.add(secim);
        if (hedefKelime.contains(secim)) {
          int adet = hedefKelime.split(secim).length - 1;
          oyuncuCan = (oyuncuCan - (adet * 12)).clamp(0, 100);
        } else {
          botCan = (botCan - 15).clamp(0, 100);
        }
      }
      siraSende = true;
    });

    if (oyuncuCan <= 0 || botCan <= 0) _oyunSonu(botCan <= 0);
  }

  void _oyunSonu(bool kazandin) {
    showGeneralDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black87,
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, a1, a2) => Scaffold(
        backgroundColor: Colors.transparent,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                kazandin ? "FINISH HIM!" : "WASTED",
                style: TextStyle(
                  color: kazandin ? Colors.greenAccent : Colors.red,
                  fontSize: 50,
                  fontWeight: FontWeight.w900,
                  fontStyle: FontStyle.italic,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                kazandin
                    ? "Botu laboratuvara gömdün."
                    : "Bot seni kimyasallarla eritti.",
                style: const TextStyle(color: Colors.white, fontSize: 18),
              ),
              const SizedBox(height: 40),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: kAccentCopper,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 40,
                    vertical: 15,
                  ),
                ),
                onPressed: () {
                  Navigator.pop(context);
                  _savasBaslat();
                },
                child: const Text(
                  "TEKRAR DÜELLO",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!oyunBasladi) return _girisEkrani();
    if (yukleniyor)
      return const Scaffold(
        backgroundColor: Color(0xFF0A0A0A),
        body: Center(child: CircularProgressIndicator(color: Colors.red)),
      );

    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      body: SafeArea(
        child: Column(
          children: [
            _buildMortalBar(),
            const SizedBox(height: 40),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                anlam,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white60,
                  fontSize: 16,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
            const SizedBox(height: 20),
            _buildKelimeHatti(),
            const Spacer(),
            _buildKlavye(),
          ],
        ),
      ),
    );
  }

  Widget _buildMortalBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 20),
      child: Row(
        children: [
          Expanded(child: _healthBar(oyuncuCan, "YOU", true)),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 10),
            child: Text(
              "VS",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w900,
                fontSize: 20,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
          Expanded(child: _healthBar(botCan, "BOT", false)),
        ],
      ),
    );
  }

  Widget _healthBar(double can, String isim, bool left) {
    return Column(
      crossAxisAlignment: left
          ? CrossAxisAlignment.start
          : CrossAxisAlignment.end,
      children: [
        Text(
          isim,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        const SizedBox(height: 5),
        Stack(
          children: [
            Container(
              height: 15,
              decoration: BoxDecoration(
                color: Colors.grey.shade900,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            AnimatedContainer(
              duration: const Duration(milliseconds: 500),
              height: 15,
              width: (MediaQuery.of(context).size.width * 0.38) * (can / 100),
              decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    color: left
                        ? Colors.orangeAccent.withOpacity(0.5)
                        : Colors.red.withOpacity(0.5),
                    blurRadius: 10,
                  ),
                ],
                gradient: LinearGradient(
                  colors: left
                      ? [Colors.yellow, Colors.orange]
                      : [Colors.red, const Color(0xFF8B0000)],
                ),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildKelimeHatti() {
    return Wrap(
      spacing: 8,
      runSpacing: 10,
      alignment: WrapAlignment.center,
      children: hedefKelime
          .split('')
          .map(
            (c) => Container(
              width: 32,
              height: 45,
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: acilanHarfler.contains(c)
                        ? Colors.greenAccent
                        : Colors.white24,
                    width: 3,
                  ),
                ),
              ),
              child: Center(
                child: Text(
                  acilanHarfler.contains(c) ? c : "",
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          )
          .toList(),
    );
  }

  Widget _buildKlavye() {
    return Container(
      padding: const EdgeInsets.all(10),
      color: Colors.black,
      child: Wrap(
        alignment: WrapAlignment.center,
        children: "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
            .split('')
            .map(
              (h) => GestureDetector(
                onTap: () => _hamleYap(h),
                child: Container(
                  margin: const EdgeInsets.all(2),
                  width: 36,
                  height: 45,
                  decoration: BoxDecoration(
                    color: acilanHarfler.contains(h)
                        ? Colors.black
                        : const Color(0xFF1A1A1A),
                    border: Border.all(
                      color: acilanHarfler.contains(h)
                          ? Colors.white10
                          : Colors.white24,
                    ),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Center(
                    child: Text(
                      h,
                      style: TextStyle(
                        color: acilanHarfler.contains(h)
                            ? Colors.white24
                            : Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            )
            .toList(),
      ),
    );
  }

  Widget _girisEkrani() {
    return Scaffold(
      backgroundColor: const Color(0xFF050505),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(25.0),
          child: Column(
            children: [
              const SizedBox(height: 60),
              const Icon(Icons.flash_on, size: 80, color: Colors.yellowAccent),
              const Text(
                "LAB DUEL",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 36,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 4,
                ),
              ),
              const Text(
                "CHOOSE YOUR FATE",
                style: TextStyle(color: Colors.white54, fontSize: 14),
              ),
              const SizedBox(height: 50),
              const Text(
                "KELİME SEVİYESİ",
                style: TextStyle(
                  color: kAccentCopper,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 10,
                children: ["A1", "A2", "B1", "B2", "C1"]
                    .map(
                      (s) => ChoiceChip(
                        label: Text(s),
                        selected: seciliSeviye == s,
                        onSelected: (v) => setState(() => seciliSeviye = s),
                        selectedColor: Colors.yellowAccent,
                        labelStyle: TextStyle(
                          color: seciliSeviye == s
                              ? Colors.black
                              : Colors.white,
                        ),
                        backgroundColor: Colors.white10,
                      ),
                    )
                    .toList(),
              ),
              const SizedBox(height: 30),
              const Text(
                "BOT ZORLUĞU",
                style: TextStyle(
                  color: kAccentCopper,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              _zorlukSecenek("Kolay", Colors.green),
              _zorlukSecenek("Orta", Colors.orange),
              _zorlukSecenek("Zor", Colors.red),
              const SizedBox(height: 40),
              if (seciliSeviye != null && seciliZorluk != null)
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black,
                    minimumSize: const Size(double.infinity, 60),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: () {
                    setState(() => oyunBasladi = true);
                    _savasBaslat();
                  },
                  child: const Text(
                    "SAVAŞA BAŞLA",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _zorlukSecenek(String z, Color r) {
    return RadioListTile(
      title: Text(
        z,
        style: TextStyle(color: r, fontWeight: FontWeight.bold),
      ),
      value: z,
      groupValue: seciliZorluk,
      onChanged: (v) => setState(() => seciliZorluk = v as String),
      activeColor: r,
    );
  }
}
