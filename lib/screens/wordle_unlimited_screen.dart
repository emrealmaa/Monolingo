import 'package:flutter/material.dart';
import '../constants/constants.dart';
import '../data/db_helper.dart';

class WordleUnlimitedScreen extends StatefulWidget {
  final List<String> seciliSeviyeler;
  const WordleUnlimitedScreen({super.key, required this.seciliSeviyeler});

  @override
  State<WordleUnlimitedScreen> createState() => _WordleUnlimitedScreenState();
}

class _WordleUnlimitedScreenState extends State<WordleUnlimitedScreen>
    with SingleTickerProviderStateMixin {
  String hedefKelime = "";
  String anlam = "";
  String mevcutSeviye = "";
  List<String> tahminler = [];
  int mevcutSatir = 0;
  String mevcutGiris = "";
  bool yukleniyor = true;
  bool oyunBitti = false;

  int can = 3;
  int toplamPuan = 0;
  int bilinenKelimeSayisi = 0;
  bool harfJokeriKullanildi = false;
  bool anlamJokeriKullanildi = false;
  bool anlamGosterilsin = false;
  int toplamHak = 5;

  // Animasyon için
  late AnimationController _shakeController;

  @override
  void initState() {
    super.initState();
    _shakeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _yeniOyunHazirla();
  }

  Future<void> _yeniOyunHazirla() async {
    setState(() => yukleniyor = true);
    final dbHelper = DbHelper();
    mevcutSeviye = (widget.seciliSeviyeler.toList()..shuffle()).first;
    final kelimeVerisi = await dbHelper.getRandomWordByLevel(mevcutSeviye);

    setState(() {
      hedefKelime = kelimeVerisi['word'].toString().toUpperCase();
      anlam = kelimeVerisi['meaning'] ?? "Anlam bulunamadı";
      toplamHak = hedefKelime.length <= 3
          ? 3
          : (hedefKelime.length <= 5 ? 5 : 7);
      tahminler = List.generate(toplamHak, (index) => "");
      mevcutSatir = 0;
      mevcutGiris = "";
      harfJokeriKullanildi = false;
      anlamJokeriKullanildi = false;
      anlamGosterilsin = false;
      oyunBitti = false;
      yukleniyor = false;
    });
  }

  void _cezaUygula() {
    _shakeController.forward(from: 0); // Puan tablosunu sars
    setState(() {
      toplamPuan = (toplamPuan - 5).clamp(0, 999999);
    });
  }

  void _harfJokeri() {
    if (oyunBitti ||
        harfJokeriKullanildi ||
        mevcutGiris.length >= hedefKelime.length)
      return;
    _cezaUygula();
    setState(() {
      harfJokeriKullanildi = true;
      mevcutGiris += hedefKelime[mevcutGiris.length];
    });
  }

  void _anlamJokeri() {
    if (mevcutSatir < 3 || anlamJokeriKullanildi) return;
    _cezaUygula();
    setState(() {
      anlamJokeriKullanildi = true;
      anlamGosterilsin = true;
    });
  }

  void _onayla() {
    if (mevcutGiris.length == hedefKelime.length && !oyunBitti) {
      setState(() {
        tahminler[mevcutSatir] = mevcutGiris;
        if (mevcutGiris == hedefKelime) {
          bilinenKelimeSayisi++;
          _puanHesapla();
          _yeniOyunHazirla();
        } else if (mevcutSatir == toplamHak - 1) {
          can--;
          if (can <= 0) {
            _finalOzetEkrani();
          } else {
            _yeniOyunHazirla(); // Canı varsa yeni kelimeye geç
          }
        } else {
          mevcutSatir++;
          mevcutGiris = "";
        }
      });
    }
  }

  void _puanHesapla() {
    int baz = (mevcutSeviye == "C1")
        ? 50
        : (mevcutSeviye.startsWith('B') ? 30 : 15);
    toplamPuan += (baz * (toplamHak - mevcutSatir));
  }

  // ÖZET EKRANI AGA (SONUÇ TABLOSU)
  void _finalOzetEkrani() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (c) => AlertDialog(
        backgroundColor: kDeepNavy,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: kAccentCopper),
        ),
        title: const Center(
          child: Text(
            "OYUN SONU",
            style: TextStyle(color: kAccentCopper, fontWeight: FontWeight.bold),
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _ozetSatiri("Toplam Puan", "$toplamPuan"),
            _ozetSatiri("Bilinen Kelime", "$bilinenKelimeSayisi"),
            const Divider(color: Colors.white24),
            const Text(
              "Harika bir iş çıkardın aga!",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white70, fontSize: 12),
            ),
          ],
        ),
        actions: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey.shade800,
                ),
                onPressed: () {
                  Navigator.pop(c);
                  Navigator.pop(context);
                },
                child: const Text("ANA SAYFA"),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: kAccentCopper),
                onPressed: () {
                  Navigator.pop(c);
                  setState(() {
                    can = 3;
                    toplamPuan = 0;
                    bilinenKelimeSayisi = 0;
                  });
                  _yeniOyunHazirla();
                },
                child: const Text("TEKRAR OYNA"),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _ozetSatiri(String baslik, String deger) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(baslik, style: const TextStyle(color: Colors.white)),
          Text(
            deger,
            style: const TextStyle(
              color: kAccentCopper,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (yukleniyor)
      return const Scaffold(
        backgroundColor: kDeepNavy,
        body: Center(child: CircularProgressIndicator(color: kAccentCopper)),
      );

    return Scaffold(
      backgroundColor: kDeepNavy,
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: AnimatedBuilder(
          animation: _shakeController,
          builder: (context, child) {
            final double offset = (0.5 - _shakeController.value).abs() * 20;
            return Container(
              padding: EdgeInsets.only(
                left: _shakeController.isAnimating ? offset : 0,
              ),
              child: Text(
                "PUAN: $toplamPuan",
                style: TextStyle(
                  color: _shakeController.isAnimating
                      ? Colors.red
                      : Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            );
          },
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.abc,
              color: harfJokeriKullanildi ? Colors.grey : Colors.orangeAccent,
            ),
            onPressed: harfJokeriKullanildi ? null : _harfJokeri,
          ),
          IconButton(
            icon: Icon(
              Icons.lightbulb,
              color: (mevcutSatir >= 3 && !anlamJokeriKullanildi)
                  ? Colors.yellowAccent
                  : Colors.grey,
            ),
            onPressed: (mevcutSatir >= 3 && !anlamJokeriKullanildi)
                ? _anlamJokeri
                : null,
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                3,
                (i) => Icon(
                  Icons.favorite,
                  color: i < can ? Colors.red : Colors.grey,
                  size: 25,
                ),
              ),
            ),
          ),
          if (anlamGosterilsin)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                "💡 $anlam",
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: kAccentCopper,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
          Expanded(
            child: Center(
              child: Container(
                constraints: const BoxConstraints(maxWidth: 400),
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: hedefKelime.length,
                    mainAxisSpacing: 8,
                    crossAxisSpacing: 8,
                  ),
                  itemCount: toplamHak * hedefKelime.length,
                  itemBuilder: (context, index) {
                    int satir = index ~/ hedefKelime.length;
                    int sutun = index % hedefKelime.length;
                    String harf = "";
                    if (satir == mevcutSatir && sutun < mevcutGiris.length)
                      harf = mevcutGiris[sutun];
                    if (satir < mevcutSatir) harf = tahminler[satir][sutun];

                    return Container(
                      decoration: BoxDecoration(
                        color: _getRenk(satir, sutun),
                        border: Border.all(
                          color:
                              (satir == mevcutSatir &&
                                  sutun == mevcutGiris.length)
                              ? kAccentCopper
                              : Colors.white12,
                          width: 2,
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Center(
                        child: FittedBox(
                          child: Text(
                            harf,
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
          _buildKlavye(),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  // Önceki klavye ve renk metodları aynı kalıyor...
  Color _getRenk(int satir, int sutun) {
    if (satir >= mevcutSatir) return Colors.transparent;
    String harf = tahminler[satir][sutun];
    if (hedefKelime[sutun] == harf) return Colors.green;
    if (hedefKelime.contains(harf)) return Colors.orange;
    return Colors.grey.shade800;
  }

  Widget _buildKlavye() {
    final harfler = ["QWERTYUIOP", "ASDFGHJKL", "ZXCVBNM"];
    return Column(
      children: [
        for (var s in harfler)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 3),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: s.split('').map((h) => _klavyeTusu(h)).toList(),
            ),
          ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _klavyeTusu(
              "SİL",
              genis: 65,
              aksiyon: _sil,
              renk: Colors.redAccent.withOpacity(0.6),
            ),
            _klavyeTusu(
              "OK",
              genis: 65,
              aksiyon: _onayla,
              renk: Colors.greenAccent.withOpacity(0.6),
            ),
          ],
        ),
      ],
    );
  }

  Widget _klavyeTusu(
    String harf, {
    double genis = 33,
    VoidCallback? aksiyon,
    Color? renk,
  }) {
    return GestureDetector(
      onTap:
          aksiyon ??
          () {
            if (mevcutGiris.length < hedefKelime.length)
              setState(() => mevcutGiris += harf);
          },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 2),
        width: genis,
        height: 48,
        decoration: BoxDecoration(
          color: renk ?? Colors.grey.shade800,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Center(
          child: Text(
            harf,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
          ),
        ),
      ),
    );
  }

  void _sil() {
    if (mevcutGiris.isNotEmpty)
      setState(
        () => mevcutGiris = mevcutGiris.substring(0, mevcutGiris.length - 1),
      );
  }

  @override
  void dispose() {
    _shakeController.dispose();
    super.dispose();
  }
}
