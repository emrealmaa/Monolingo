import 'package:flutter/material.dart';
import '../constants/constants.dart';

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
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "YENİ HESAP",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        foregroundColor: kDeepNavy,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(30),
        child: Column(
          children: [
            TextField(
              controller: _isim,
              decoration: const InputDecoration(
                labelText: "Ad Soyad",
                prefixIcon: Icon(Icons.person),
              ),
            ),
            const SizedBox(height: 15),
            TextField(
              controller: _email,
              decoration: const InputDecoration(
                labelText: "E-posta",
                prefixIcon: Icon(Icons.email),
              ),
            ),
            const SizedBox(height: 15),
            TextField(
              controller: _sifre,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: "Şifre",
                prefixIcon: Icon(Icons.lock),
              ),
            ),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: kAccentCopper,
                  foregroundColor: Colors.white,
                ),
                onPressed: () {
                  if (_isim.text.isEmpty || _email.text.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Bütün bilgileri doldur kral!"),
                      ),
                    );
                  } else {
                    Navigator.pop(context);
                  }
                },
                child: const Text("KAYIT OL"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
