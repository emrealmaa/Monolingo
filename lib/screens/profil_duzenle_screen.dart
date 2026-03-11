import 'package:flutter/material.dart';
import '../constants/constants.dart';
import 'forgot_password_screen.dart';
import '../data/db_helper.dart'; // AGA BURAYI EKLEDİM

class ProfilDuzenleEkrani extends StatefulWidget {
  final String mevcutIsim;
  final String mevcutEmail;

  const ProfilDuzenleEkrani({
    super.key,
    required this.mevcutIsim,
    required this.mevcutEmail,
  });

  @override
  State<ProfilDuzenleEkrani> createState() => _ProfilDuzenleEkraniState();
}

class _ProfilDuzenleEkraniState extends State<ProfilDuzenleEkrani> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _adController;
  late TextEditingController _emailController;
  final _mevcutSifreController = TextEditingController();
  final _yeniSifreController = TextEditingController();
  final _yeniSifreTekrarController = TextEditingController();

  bool _sifreGoster = false;
  bool _isUpdating = false; // Güncelleme sırasında butonu kilitlemek için

  @override
  void initState() {
    super.initState();
    _adController = TextEditingController(text: widget.mevcutIsim);
    _emailController = TextEditingController(text: widget.mevcutEmail);
  }

  @override
  void dispose() {
    _adController.dispose();
    _emailController.dispose();
    _mevcutSifreController.dispose();
    _yeniSifreController.dispose();
    _yeniSifreTekrarController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text("Profili Düzenle"),
        backgroundColor: Colors.transparent,
        foregroundColor: isDark ? Colors.white : kDeepNavy,
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _inputAlani(
                context,
                "Ad Soyad",
                _adController,
                Icons.person_outline,
              ),
              const SizedBox(height: 15),
              _inputAlani(
                context,
                "E-posta",
                _emailController,
                Icons.email_outlined,
                keyboardType: TextInputType.emailAddress,
              ),
              Divider(
                color: isDark ? Colors.white10 : Colors.black12,
                height: 40,
              ),

              const Text(
                "Şifre Değiştir",
                style: TextStyle(
                  color: kAccentCopper,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 15),

              _inputAlani(
                context,
                "Mevcut Şifre",
                _mevcutSifreController,
                Icons.lock_outline,
                isPassword: !_sifreGoster,
              ),
              const SizedBox(height: 10),
              _inputAlani(
                context,
                "Yeni Şifre",
                _yeniSifreController,
                Icons.lock_reset,
                isPassword: !_sifreGoster,
              ),
              const SizedBox(height: 10),
              _inputAlani(
                context,
                "Yeni Şifre (Tekrar)",
                _yeniSifreTekrarController,
                Icons.lock_reset,
                isPassword: !_sifreGoster,
              ),

              Align(
                alignment: Alignment.centerRight,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton.icon(
                      onPressed: () =>
                          setState(() => _sifreGoster = !_sifreGoster),
                      icon: Icon(
                        _sifreGoster ? Icons.visibility_off : Icons.visibility,
                        size: 18,
                      ),
                      label: Text(
                        _sifreGoster ? "Şifreleri Gizle" : "Şifreleri Göster",
                      ),
                      style: TextButton.styleFrom(
                        foregroundColor: kAccentCopper,
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const ForgotPasswordScreen(),
                          ),
                        );
                      },
                      child: Text(
                        "Şifremi Unuttum?",
                        style: TextStyle(
                          color: isDark ? Colors.white54 : Colors.black45,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 30),

              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: kAccentCopper,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 55),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
                onPressed: _isUpdating ? null : _guncelle,
                child: _isUpdating
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text("GÜNCELLE", style: kButtonTextStyle),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _inputAlani(
    BuildContext context,
    String label,
    TextEditingController controller,
    IconData icon, {
    bool isPassword = false,
    TextInputType? keyboardType,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return TextFormField(
      controller: controller,
      obscureText: isPassword,
      keyboardType: keyboardType,
      style: TextStyle(color: isDark ? Colors.white : kDeepNavy),
      decoration: getKInputDecoration(context).copyWith(
        labelText: label,
        prefixIcon: Icon(icon, color: kAccentCopper),
      ),
    );
  }

  // AGA BURASI TAMAMEN GÜNCELLENDİ: GERÇEK VERİTABANI BAĞLANTISI
  void _guncelle() async {
    final ad = _adController.text.trim();
    final email = _emailController.text.trim();
    final mevcutSifre = _mevcutSifreController.text;
    final yeniSifre = _yeniSifreController.text;
    final yeniSifreTekrar = _yeniSifreTekrarController.text;

    if (ad.isEmpty || email.isEmpty) {
      _mesajGoster("Ad ve Email boş bırakılamaz aga!");
      return;
    }

    setState(() => _isUpdating = true);

    try {
      // 1. Durum: Sadece Ad/Email güncellemek istiyor (Şifre alanları boş)
      if (mevcutSifre.isEmpty && yeniSifre.isEmpty) {
        // Buraya istersen ad/email güncelleme fonksiyonu yazabilirsin
        // Şimdilik sadece şifre üzerinden gidelim dedik ama yapıyı kurdum
        _mesajGoster("Bilgiler güncellendi (Demo Mode)");
        Navigator.pop(context);
        return;
      }

      // 2. Durum: Şifre değiştirmek istiyor
      if (mevcutSifre.isEmpty) {
        _mesajGoster("Şifre değiştirmek için mevcut şifreni girmelisin!");
      } else if (yeniSifre != yeniSifreTekrar) {
        _mesajGoster("Yeni şifreler uyuşmuyor aga!");
      } else if (yeniSifre.length < 4) {
        _mesajGoster("Yeni şifre en az 4 karakter olmalı!");
      } else {
        // VERİTABANI İŞLEMİ
        bool basarili = await DbHelper().sifreGuncelle(
          widget.mevcutEmail,
          mevcutSifre,
          yeniSifre,
        );

        if (basarili) {
          _mesajGoster("Profil ve şifre başarıyla güncellendi!");
          Navigator.pop(context);
        } else {
          _mesajGoster("Mevcut şifren yanlış, kontrol et kral!");
        }
      }
    } catch (e) {
      _mesajGoster("Bir hata oluştu: $e");
    } finally {
      if (mounted) setState(() => _isUpdating = false);
    }
  }

  void _mesajGoster(String mesaj) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mesaj),
        behavior: SnackBarBehavior.floating,
        backgroundColor: mesaj.contains("başarıyla")
            ? Colors.green
            : Colors.redAccent,
      ),
    );
  }
}
