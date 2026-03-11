import 'dart:async';
import 'package:flutter/material.dart';
import '../constants/constants.dart';
import '../models/word_model.dart';
import '../data/db_helper.dart';

class ZamanaKarsiOyunEkrani extends StatefulWidget {
  final List<String> seciliSeviyeler;
  const ZamanaKarsiOyunEkrani({super.key, required this.seciliSeviyeler});

  @override
  State<ZamanaKarsiOyunEkrani> createState() => _ZamanaKarsiOyunEkraniState();
}

class _ZamanaKarsiOyunEkraniState extends State<ZamanaKarsiOyunEkrani>
    with TickerProviderStateMixin {
  List<WordModel> _oyunKelimeleri = [];
  int _currentIdx = 0;
  List<String> _karisikHarfler = [];
  List<String> _userAnswer = [];
  int _sure = 60;
  Timer? _timer;
  int _puan = 0;
  int _combo = 0;
  bool _isLoading = true;

  late AnimationController _shakeController;
  late AnimationController _scoreAnimationController;
  late Animation<double> _scoreAnimation;

  @override
  void initState() {
    super.initState();
    _shakeController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _scoreAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _scoreAnimation =
        Tween<double>(begin: 1.0, end: 1.3).animate(
          CurvedAnimation(
            parent: _scoreAnimationController,
            curve: Curves.easeOut,
          ),
        )..addStatusListener((status) {
          if (status == AnimationStatus.completed)
            _scoreAnimationController.reverse();
        });

    _oyunuYukle();
  }

  void _oyunuYukle() async {
    String hedefSeviye = widget.seciliSeviyeler.isNotEmpty
        ? widget.seciliSeviyeler.first
        : "A1";

    var kelimeler = await DbHelper().rastgeleKelimeGetir(hedefSeviye, 50);

    setState(() {
      _oyunKelimeleri = kelimeler;
      _oyunKelimeleri.shuffle();

      if (_oyunKelimeleri.isNotEmpty) {
        _kelimeyiHazirla();
        _startTimer();
      }
      _isLoading = false;
    });
  }

  void _kelimeyiHazirla() {
    if (_oyunKelimeleri.isEmpty) return;
    String kelime = _oyunKelimeleri[_currentIdx].word.toUpperCase().trim();
    _karisikHarfler = kelime.split('')..shuffle();
    _userAnswer = [];
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (mounted) {
        if (_sure > 0) {
          setState(() => _sure--);
        } else {
          _oyunuBitir();
        }
      }
    });
  }

  // AGA BURASI YENİ: Pas geçme mantığı
  void _pasGec() {
    if (_oyunKelimeleri.isEmpty) return;

    setState(() {
      _combo = 0; // Kombo sıfırlanır
      _puan = (_puan >= 10) ? _puan - 10 : 0; // 10 puan ceza
      _sure = (_sure >= 5) ? _sure - 5 : 0; // 5 saniye ceza
      _shakeController.forward(from: 0); // Ekran sallanır (ceza hissi)
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          "PAS GEÇİLDİ! (-10 Puan / -5 Sn)",
          textAlign: TextAlign.center,
        ),
        duration: Duration(milliseconds: 800),
        backgroundColor: Colors.orange,
        behavior: SnackBarBehavior.floating,
      ),
    );

    _sonrakiKelime();
  }

  void _harfEkle(int index) {
    setState(() {
      _userAnswer.add(_karisikHarfler[index]);
      _karisikHarfler.removeAt(index);
    });

    if (_karisikHarfler.isEmpty) {
      _kontrolEt();
    }
  }

  void _harfGeriAl() {
    if (_userAnswer.isNotEmpty) {
      setState(() {
        String sonHarf = _userAnswer.removeLast();
        _karisikHarfler.add(sonHarf);
      });
    }
  }

  void _kontrolEt() {
    String tamCevap = _userAnswer.join('').trim().toUpperCase();
    String dogruCevap = _oyunKelimeleri[_currentIdx].word.trim().toUpperCase();

    if (tamCevap == dogruCevap) {
      _combo++;
      _scoreAnimationController.forward(from: 0);
      _puan += 10 + (_combo > 3 ? 5 : 0);
      _komboMesajiGoster();
      _sonrakiKelime();
    } else {
      _combo = 0;
      _shakeController.forward(from: 0);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("YANLIŞ! Tekrar dene.", textAlign: TextAlign.center),
          duration: Duration(milliseconds: 500),
          behavior: SnackBarBehavior.floating,
          margin: EdgeInsets.only(bottom: 200, left: 100, right: 100),
        ),
      );
      _kelimeyiHazirla();
    }
  }

  void _komboMesajiGoster() {
    String? mesaj;
    if (_combo == 3)
      mesaj = "🔥 HARİKA!";
    else if (_combo == 5)
      mesaj = "⚡ MUHTEŞEM!";
    else if (_combo >= 10)
      mesaj = "🏆 KRALSIN!";

    if (mesaj != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            mesaj,
            textAlign: TextAlign.center,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          backgroundColor: kAccentCopper,
          duration: const Duration(milliseconds: 700),
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.only(bottom: 150, left: 100, right: 100),
        ),
      );
    }
  }

  void _sonrakiKelime() {
    if (_currentIdx < _oyunKelimeleri.length - 1) {
      setState(() {
        _currentIdx++;
        _kelimeyiHazirla();
        // Eğer pas değil de doğru bildiyse ödül saniyesi zaten kontrolEt içinde veya burada verilebilir.
        // Ama pas geçince ödül vermiyoruz.
      });
    } else {
      _oyunuBitir();
    }
  }

  void _oyunuBitir() {
    _timer?.cancel();
    if (!mounted) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).cardColor,
        title: const Text(
          "SÜRE BİTTİ!",
          style: TextStyle(color: kAccentCopper, fontWeight: FontWeight.bold),
        ),
        content: Text(
          "Toplam Puanın: $_puan\nMax Kombo: $_combo",
          style: const TextStyle(fontSize: 18),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text("TAMAM", style: TextStyle(color: kAccentCopper)),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    _shakeController.dispose();
    _scoreAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final Animation<double> offsetAnimation =
        Tween<double>(
            begin: 0.0,
            end: 15.0,
          ).chain(CurveTween(curve: Curves.elasticIn)).animate(_shakeController)
          ..addStatusListener((status) {
            if (status == AnimationStatus.completed) _shakeController.reverse();
          });

    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator(color: kAccentCopper)),
      );
    }

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: BackButton(color: isDark ? Colors.white : kDeepNavy),
        title: Column(
          children: [
            ScaleTransition(
              scale: _scoreAnimation,
              child: Text(
                "PUAN: $_puan",
                style: const TextStyle(
                  color: kAccentCopper,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ),
            if (_combo > 1)
              Text(
                "COMBO: $_combo",
                style: const TextStyle(color: Colors.orange, fontSize: 12),
              ),
          ],
        ),
        centerTitle: true,
        // AGA BURASI YENİ: AppBar'a Pas Butonu ekledim
        actions: [
          TextButton.icon(
            onPressed: _pasGec,
            icon: const Icon(Icons.skip_next, color: Colors.orange),
            label: const Text(
              "PAS",
              style: TextStyle(
                color: Colors.orange,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      body: AnimatedBuilder(
        animation: offsetAnimation,
        builder: (context, child) {
          return Padding(
            padding: EdgeInsets.symmetric(
              horizontal: 20 + offsetAnimation.value,
            ),
            child: Column(
              children: [
                const SizedBox(height: 10),
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: LinearProgressIndicator(
                    value: _sure / 60,
                    minHeight: 15,
                    color: _sure < 15 ? Colors.red : kAccentCopper,
                    backgroundColor: isDark ? Colors.white10 : Colors.black12,
                  ),
                ),
                const SizedBox(height: 40),
                Text(
                  _oyunKelimeleri[_currentIdx].meaning.toUpperCase(),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: isDark ? Colors.white : kDeepNavy,
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 30),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  alignment: WrapAlignment.center,
                  children: _userAnswer
                      .map((h) => _harfKutusu(h, true))
                      .toList(),
                ),
                const Spacer(),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      child: Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        alignment: WrapAlignment.center,
                        children: List.generate(_karisikHarfler.length, (i) {
                          return GestureDetector(
                            onTap: () => _harfEkle(i),
                            child: _harfKutusu(_karisikHarfler[i], false),
                          );
                        }),
                      ),
                    ),
                    IconButton(
                      onPressed: _harfGeriAl,
                      icon: const Icon(
                        Icons.backspace_outlined,
                        color: Colors.redAccent,
                        size: 35,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 60),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _harfKutusu(String harf, bool isAnswer) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      width: 45,
      height: 50,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: isAnswer ? kAccentCopper : Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          if (!isAnswer)
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
        ],
        border: Border.all(
          color: isAnswer
              ? kAccentCopper
              : (isDark ? Colors.white10 : Colors.black12),
          width: 1.5,
        ),
      ),
      child: Text(
        harf,
        style: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.bold,
          color: isAnswer
              ? (isDark ? kDeepNavy : Colors.white)
              : (isDark ? Colors.white : kDeepNavy),
        ),
      ),
    );
  }
}
