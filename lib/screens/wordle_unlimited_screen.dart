import 'dart:math';
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
  int harfJokeriHakki = 3;
  bool anlamGosterilsin = false;
  int toplamHak = 5;

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

  String _temizle(String metin) {
    return metin.replaceAll('i', 'I').replaceAll('İ', 'I').toUpperCase().trim();
  }

  Future<void> _yeniOyunHazirla() async {
    setState(() => yukleniyor = true);
    final dbHelper = DbHelper();
    mevcutSeviye = (widget.seciliSeviyeler.toList()..shuffle()).first;
    final kelimeVerisi = await dbHelper.getRandomWordByLevel(mevcutSeviye);

    setState(() {
      hedefKelime = _temizle(kelimeVerisi['word'].toString());
      anlam = kelimeVerisi['meaning'] ?? "Anlam bulunamadı";
      toplamHak = hedefKelime.length <= 3
          ? 3
          : (hedefKelime.length <= 5 ? 5 : 7);
      tahminler = List.generate(toplamHak, (index) => "");
      mevcutSatir = 0;
      mevcutGiris = "";
      harfJokeriHakki = 3;
      anlamGosterilsin = false;
      oyunBitti = false;
      yukleniyor = false;
    });
  }

  // --- SADECE 1 TANE RASTGELE HARF VEREN GÜNCEL JOKER ---
  void _rastgeleHarfAc() {
    if (harfJokeriHakki <= 0 || oyunBitti) return;

    // Henüz doğru bilinmemiş (boş olan veya yanlış harf olan) yerleri bul
    List<int> eksikIndexler = [];
    for (int i = 0; i < hedefKelime.length; i++) {
      if (i >= mevcutGiris.length || mevcutGiris[i] != hedefKelime[i]) {
        eksikIndexler.add(i);
      }
    }

    if (eksikIndexler.isNotEmpty) {
      // Rastgele bir tanesini seç
      int secilenIndex = eksikIndexler[Random().nextInt(eksikIndexler.length)];

      _cezaUygula();

      setState(() {
        harfJokeriHakki--;

        // Mevcut girişi harf harf listeye çevirip sadece o indexi güncelliyoruz
        List<String> tempGiris = List.generate(hedefKelime.length, (index) {
          if (index < mevcutGiris.length) return mevcutGiris[index];
          return " "; // Boşluk bırakıyoruz ki index kaymasın
        });

        tempGiris[secilenIndex] = hedefKelime[secilenIndex];

        // Tekrar String'e çevir ama sondaki boşlukları temizle
        mevcutGiris = tempGiris.join('').trimRight();
      });
    }
  }

  // --- AKILLI RENK ALGORİTMASI ---
  Color _getRenk(int satir, int sutun) {
    if (satir >= mevcutSatir) return Colors.transparent;
    String tahmin = tahminler[satir];
    String harf = tahmin[sutun];
    if (hedefKelime[sutun] == harf) return Colors.green;

    int hedeftekiToplam = 0;
    for (int i = 0; i < hedefKelime.length; i++) {
      if (hedefKelime[i] == harf) hedeftekiToplam++;
    }

    int oncedenSayilan = 0;
    for (int i = 0; i < tahmin.length; i++) {
      if (tahmin[i] == harf) {
        if (i <= sutun) oncedenSayilan++;
      }
    }

    if (hedefKelime.contains(harf) && oncedenSayilan <= hedeftekiToplam) {
      return Colors.orange;
    }
    return Colors.grey.shade800;
  }

  void _kurallarDialog() {
    showDialog(
      context: context,
      builder: (c) => AlertDialog(
        backgroundColor: kDeepNavy,
        title: const Text(
          "Oyun Kuralları",
          style: TextStyle(color: kAccentCopper),
        ),
        content: const Text(
          "1. Hedef kelimeyi tahmin et.\n"
          "2. Yeşil: Harf doğru yerde.\n"
          "3. Turuncu: Harf var ama yeri yanlış.\n"
          "4. Joker her basışta sadece 1 rastgele harf açar.",
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(c),
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }

  void _cezaUygula() {
    _shakeController.forward(from: 0);
    setState(
      () => toplamPuan = (toplamPuan - 15).clamp(0, 999999),
    ); // Joker cezası 15 olsun, kıymetli kalsın
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
          can <= 0 ? _finalOzetEkrani() : _yeniOyunHazirla();
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
          ],
        ),
        actions: [
          TextButton(
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
        leading: IconButton(
          icon: const Icon(Icons.info_outline, color: Colors.white),
          onPressed: _kurallarDialog,
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          "PUAN: $toplamPuan",
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          Stack(
            alignment: Alignment.center,
            children: [
              IconButton(
                icon: const Icon(
                  Icons.lightbulb,
                  color: Colors.amber,
                  size: 30,
                ),
                onPressed: _rastgeleHarfAc,
              ),
              Positioned(
                right: 8,
                top: 8,
                child: CircleAvatar(
                  radius: 8,
                  backgroundColor: Colors.red,
                  child: Text(
                    "$harfJokeriHakki",
                    style: const TextStyle(fontSize: 10, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          Row(
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
          const SizedBox(height: 10),
          GestureDetector(
            onTap: () => setState(() => anlamGosterilsin = !anlamGosterilsin),
            child: Container(
              padding: const EdgeInsets.all(8),
              margin: const EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                color: Colors.white10,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                anlamGosterilsin ? "💡 $anlam" : "Anlam İpucu (Dokun)",
                style: const TextStyle(color: kAccentCopper, fontSize: 12),
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
                        child: Text(
                          harf,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
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

  Widget _buildKlavye() {
    final harfler = ["QWERTYUIOP", "ASDFGHJKL", "ZXCVBNM"];
    return Column(
      children: [
        for (var s in harfler)
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: s.split('').map((h) => _klavyeTusu(h)).toList(),
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
        margin: const EdgeInsets.all(2),
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
