import 'package:flutter/material.dart';
import '../constants/constants.dart';
import 'login_screen.dart';

class ProfilSekmesi extends StatelessWidget {
  final String isim;
  final String email;
  const ProfilSekmesi({super.key, required this.isim, required this.email});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Profil"), foregroundColor: kDeepNavy),
      body: Column(
        children: [
          const SizedBox(height: 30),
          const Center(
            child: CircleAvatar(
              radius: 60,
              child: Icon(Icons.person, size: 70),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            isim,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: kDeepNavy,
            ),
          ),
          Text(email, style: const TextStyle(color: Colors.grey)),
          const SizedBox(height: 30),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.edit, color: kAccentCopper),
            title: const Text("Profili Düzenle"),
            onTap: () {},
          ),
          const Spacer(),
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: ListTile(
              tileColor: Colors.red.withOpacity(0.1),
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text(
                "Çıkış Yap",
                style: TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
              onTap: () => Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const LoginSayfasi()),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
