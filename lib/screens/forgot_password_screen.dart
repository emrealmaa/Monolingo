import 'package:flutter/material.dart';
import '../constants/constants.dart';

class ForgotPasswordScreen extends StatelessWidget {
  const ForgotPasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(foregroundColor: kDeepNavy),
      body: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.lock_reset, size: 100, color: kAccentCopper),
            const Text(
              "ŞİFRE KURTARMA",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: kAccentCopper,
              ),
            ),
            const SizedBox(height: 20),
            const TextField(
              decoration: InputDecoration(
                labelText: "E-posta",
                prefixIcon: Icon(Icons.email_outlined),
              ),
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 55),
                backgroundColor: kAccentCopper,
                foregroundColor: Colors.white,
              ),
              onPressed: () => Navigator.pop(context),
              child: const Text("GÖNDER"),
            ),
          ],
        ),
      ),
    );
  }
}
