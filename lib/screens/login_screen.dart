import 'package:flutter/material.dart';
import '../constants/constants.dart';
import 'kayit_ol_screen.dart';
import 'forgot_password_screen.dart';
import 'main_navigation.dart';

class LoginSayfasi extends StatefulWidget {
  const LoginSayfasi({super.key});
  @override
  _LoginSayfasiState createState() => _LoginSayfasiState();
}

class _LoginSayfasiState extends State<LoginSayfasi> {
  final _email = TextEditingController();
  final _sifre = TextEditingController();

  void _girisYap() {
    if (_email.text.isEmpty || _sifre.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Aga boş alan bırakma!"),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const MainNavigation()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(30),
        child: Column(
          children: [
            const SizedBox(height: 80),
            const Icon(Icons.psychology, size: 100, color: kAccentCopper),
            const SizedBox(height: 20),
            Text(
              "MONOLINGO",
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.white
                    : kDeepNavy,
              ),
            ),
            const SizedBox(height: 40),
            TextField(
              controller: _email,
              decoration: getKInputDecoration(context).copyWith(
                labelText: "E-posta",
                prefixIcon: const Icon(Icons.email),
              ),
            ),
            const SizedBox(height: 15),
            TextField(
              controller: _sifre,
              obscureText: true,
              decoration: getKInputDecoration(context).copyWith(
                labelText: "Şifre",
                prefixIcon: const Icon(Icons.lock),
              ),
            ),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ForgotPasswordScreen(),
                  ), // const silindi
                ),
                child: const Text(
                  "Şifremi Unuttum",
                  style: TextStyle(color: kAccentCopper),
                ),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: kAccentCopper,
                  foregroundColor: Colors.white,
                ),
                onPressed: _girisYap,
                child: const Text("GİRİŞ YAP", style: kButtonTextStyle),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => KayitOlSayfasi(),
                ), // const silindi
              ),
              child: const Text("Henüz hesabın yok mu? Kayıt Ol"),
            ),
          ],
        ),
      ),
    );
  }
}
