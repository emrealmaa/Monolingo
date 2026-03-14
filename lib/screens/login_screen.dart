import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../data/db_helper.dart';
import 'kayit_ol_screen.dart';
import 'forgot_password_screen.dart';
import '../constants/constants.dart';
import 'main_navigation.dart';

class LoginSayfasi extends StatefulWidget {
  const LoginSayfasi({super.key});

  @override
  _LoginSayfasiState createState() => _LoginSayfasiState();
}

class _LoginSayfasiState extends State<LoginSayfasi> {
  final _email = TextEditingController();
  final _sifre = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _email.dispose();
    _sifre.dispose();
    super.dispose();
  }

  void _mesajGoster(String mesaj) {
    if (!mounted) return;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          mesaj,
          style: TextStyle(color: isDark ? Colors.white : Colors.white),
        ),
        backgroundColor: isDark
            ? kCardNavy
            : kDeepNavy, // Aydınlıkta da koyu snackbar daha iyi okunur
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // ... (Giriş işlemi aynı kalıyor, bir değişiklik yok kral)
  Future<void> _loginIslemi() async {
    final email = _email.text.trim();
    final sifre = _sifre.text.trim();
    if (email.isEmpty || sifre.isEmpty) {
      _mesajGoster("Alanları boş bırakma!");
      return;
    }
    setState(() => _isLoading = true);
    try {
      final user = await DbHelper().girisYap(email, sifre);
      if (user != null && mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => MainNavigationScreen(
              isim: user['isim'] ?? "Gezgin",
              email: user['email'] ?? "",
            ),
          ),
        );
      } else {
        _mesajGoster("E-posta veya şifre hatalı, kontrol etmelisin.");
      }
    } catch (e) {
      _mesajGoster("Bir hata oluştu.");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      // AKILLI ARKA PLAN
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(30),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildLogo(isDark),
                const SizedBox(height: 25),
                Text(
                  "MONOLINGO",
                  style: GoogleFonts.montserrat(
                    fontSize: 32,
                    fontWeight: FontWeight.w900,
                    color: kAccentCopper,
                    letterSpacing: 4,
                  ),
                ),
                const SizedBox(height: 40),

                // INPUTLAR - context gönderiyoruz artık
                _buildTextField(
                  context,
                  _email,
                  "E-posta",
                  Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 15),
                _buildTextField(
                  context,
                  _sifre,
                  "Şifre",
                  Icons.lock_outline,
                  isObscure: true,
                ),

                const SizedBox(height: 35),

                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 55),
                    backgroundColor: kAccentCopper,
                    // Yazı rengi aydınlık modda beyaz kalsın, bakır üstünde beyaz iyi durur
                    foregroundColor: Colors.white,
                    elevation: 5,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  onPressed: _isLoading ? null : _loginIslemi,
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 3,
                          ),
                        )
                      : const Text("GİRİŞ YAP", style: kButtonTextStyle),
                ),

                const SizedBox(height: 20),

                TextButton(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const KayitOlSayfasi(),
                    ),
                  ),
                  child: const Text(
                    "Hesabın yok mu? Kayıt Ol",
                    style: TextStyle(
                      color: kAccentCopper,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

                TextButton(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ForgotPasswordScreen(),
                    ),
                  ),
                  child: Text(
                    "Şifremi unuttum, yardım et!",
                    style: TextStyle(
                      color: isDark ? Colors.white24 : Colors.black26,
                      fontSize: 13,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLogo(bool isDark) {
    return Container(
      width: 120,
      height: 120,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: kAccentCopper.withOpacity(isDark ? 0.2 : 0.1),
            blurRadius: 25,
            spreadRadius: 5,
          ),
        ],
      ),
      child: ClipOval(
        child: Image.asset(
          'assets/data/images/logo.png',
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) =>
              const Icon(Icons.psychology, size: 80, color: kAccentCopper),
        ),
      ),
    );
  }

  Widget _buildTextField(
    BuildContext context,
    TextEditingController controller,
    String label,
    IconData icon, {
    bool isObscure = false,
    TextInputType keyboardType = TextInputType.text,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return TextField(
      controller: controller,
      obscureText: isObscure,
      keyboardType: keyboardType,
      // Yazı rengi moda göre değişmeli yoksa aydınlıkta beyaz üstüne beyaz yazar
      style: TextStyle(color: isDark ? Colors.white : kDeepNavy),
      // constants içindeki yeni fonksiyonu çağırdık kral
      decoration: getKInputDecoration(context).copyWith(
        labelText: label,
        prefixIcon: Icon(icon, color: kAccentCopper),
      ),
    );
  }
}
