import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/constants.dart';
import '../data/db_helper.dart';

class KayitOlSayfasi extends StatefulWidget {
  const KayitOlSayfasi({super.key});

  @override
  State<KayitOlSayfasi> createState() => _KayitOlSayfasiState();
}

class _KayitOlSayfasiState extends State<KayitOlSayfasi> {
  final _isim = TextEditingController();
  final _email = TextEditingController();
  final _sifre = TextEditingController();

  @override
  Widget build(BuildContext context) {
    // Mevcut tema durumunu alıyoruz
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      // Arka plan rengini temadan çekiyoruz aga
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        // Geri dönüş okunun rengi aydınlıkta lacivert, karanlıkta bakır olsun
        iconTheme: IconThemeData(color: isDark ? kAccentCopper : kDeepNavy),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(30),
        child: Column(
          children: [
            Text(
              "YENİ HESAP",
              style: GoogleFonts.montserrat(
                fontSize: 28,
                fontWeight: FontWeight.w900,
                color: kAccentCopper,
                letterSpacing: 3,
              ),
            ),
            const SizedBox(height: 40),

            // --- GİRİŞ ALANLARI ---
            _buildTextField(
              context,
              _isim,
              "İsim Soyisim",
              Icons.person_outline,
            ),
            const SizedBox(height: 15),
            _buildTextField(context, _email, "E-posta", Icons.email_outlined),
            const SizedBox(height: 15),
            _buildTextField(
              context,
              _sifre,
              "Şifre",
              Icons.lock_outline,
              obscure: true,
            ),

            const SizedBox(height: 40),

            // --- KAYIT BUTONU ---
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 55),
                backgroundColor: kAccentCopper,
                foregroundColor:
                    Colors.white, // Buton yazısı her zaman beyaz net durur
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                elevation: 4,
              ),
              onPressed: () async {
                if (_isim.text.isEmpty ||
                    _email.text.isEmpty ||
                    _sifre.text.isEmpty) {
                  _mesajGoster("Boş yer bırakılamaz, lütfen doldurun!");
                  return;
                }

                Map<String, dynamic> yeniKullanici = {
                  'isim': _isim.text,
                  'email': _email.text,
                  'sifre': _sifre.text,
                  'dogumTarihi': DateTime.now().toIso8601String(),
                };

                try {
                  await DbHelper().kayitOl(yeniKullanici);
                  if (mounted) {
                    _mesajGoster("Kaydın tamamlandı, giriş yapabilirsin!");
                    Navigator.pop(context);
                  }
                } catch (e) {
                  if (mounted) {
                    _mesajGoster("Bu mail zaten kayıtlı veya bir hata oluştu!");
                  }
                }
              },
              child: const Text("KAYIT OL", style: kButtonTextStyle),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(
    BuildContext context, // Context ekledik ki temayı görsün
    TextEditingController controller,
    String label,
    IconData icon, {
    bool obscure = false,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return TextField(
      controller: controller,
      obscureText: obscure,
      // Yazı rengini temaya göre ayarla aga
      style: TextStyle(color: isDark ? Colors.white : kDeepNavy),
      // constants içindeki fonksiyonu kullanıyoruz
      decoration: getKInputDecoration(context).copyWith(
        labelText: label,
        prefixIcon: Icon(icon, color: kAccentCopper),
      ),
    );
  }

  void _mesajGoster(String mesaj) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mesaj),
        behavior: SnackBarBehavior.floating,
        backgroundColor:
            kDeepNavy, // Snackbar genelde koyu kalmalı ki uyarı olduğu anlaşılsın
      ),
    );
  }
}
