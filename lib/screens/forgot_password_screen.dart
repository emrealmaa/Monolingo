import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants.dart';

class ForgotPasswordScreen extends StatelessWidget {
  const ForgotPasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final emailController = TextEditingController();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      // Arka planı temadan çekiyoruz
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: isDark ? kAccentCopper : kDeepNavy),
      ),
      body: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.lock_reset, size: 100, color: kAccentCopper),
            const SizedBox(height: 20),
            Text(
              "ŞİFRE KURTARMA",
              style: GoogleFonts.montserrat(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: kAccentCopper,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              "E-posta adresini yaz, sana bir kurtarma linki gönderelim (çalışıyormuş gibi yaparız).",
              textAlign: TextAlign.center,
              // Yazı rengini moda göre ayarlıyoruz
              style: TextStyle(color: isDark ? Colors.white70 : Colors.black87),
            ),
            const SizedBox(height: 30),
            TextField(
              controller: emailController,
              // Yazı rengi aydınlıkta lacivert, karanlıkta beyaz
              style: TextStyle(color: isDark ? Colors.white : kDeepNavy),
              // constants.dart'taki akıllı dekorasyonu kullanıyoruz kral
              decoration: getKInputDecoration(context).copyWith(
                labelText: "E-posta",
                prefixIcon: const Icon(
                  Icons.email_outlined,
                  color: kAccentCopper,
                ),
              ),
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 55),
                backgroundColor: kAccentCopper,
                foregroundColor:
                    Colors.white, // Bakır üstüne beyaz her zaman net
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                elevation: 4,
              ),
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Link gönderildi (şaka yaptık)"),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
                Navigator.pop(context);
              },
              child: const Text("GÖNDER", style: kButtonTextStyle),
            ),
          ],
        ),
      ),
    );
  }
}
