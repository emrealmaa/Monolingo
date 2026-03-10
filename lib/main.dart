import 'package:flutter/material.dart';

// --- GEÇİCİ CONSTANTS (Hata vermemesi için senin renklerini buraya tanımladım) ---
const kDeepNavy = Color(0xFF1A237E);
const kAccentCopper = Color(0xFFD4A373);
const kCardNavy = Color(0xFF283593);

void main() => runApp(const MonolingoApp());

class MonolingoApp extends StatelessWidget {
  const MonolingoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Monolingo',
      theme: ThemeData(
        primaryColor: kDeepNavy,
        colorScheme: ColorScheme.fromSeed(seedColor: kDeepNavy),
        useMaterial3: true,
      ),
      home: const LoginSayfasi(),
    );
  }
}

// --- 1. GİRİŞ SAYFASI
class LoginSayfasi extends StatefulWidget {
  const LoginSayfasi({super.key});

  @override
  _LoginSayfasiState createState() => _LoginSayfasiState();
}

class _LoginSayfasiState extends State<LoginSayfasi> {
  final _email = TextEditingController();
  final _sifre = TextEditingController();

  void _mesajGoster(String mesaj) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(mesaj), behavior: SnackBarBehavior.floating),
    );
  }

  void _girisYap() {
    if (_email.text.isEmpty || _sifre.text.isEmpty) {
      _mesajGoster("Aga boş alan bırakma, hoca kızar!");
    } else {
      // Başarılı giriş simülasyonu
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
            const Text(
              "MONOLINGO",
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: kDeepNavy,
              ),
            ),
            const SizedBox(height: 40),
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
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ForgotPasswordScreen(),
                  ),
                ),
                child: const Text("Şifremi Unuttum"),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: kDeepNavy,
                  foregroundColor: Colors.white,
                ),
                onPressed: _girisYap,
                child: const Text("GİRİŞ YAP"),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const KayitOlSayfasi()),
              ),
              child: const Text("Henüz hesabın yok mu? Kayıt Ol"),
            ),
          ],
        ),
      ),
    );
  }
}

// --- 2. KAYIT OL SAYFASI
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
      appBar: AppBar(title: const Text("YENİ HESAP")),
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

// --- 3. ŞİFREMİ UNUTTUM
class ForgotPasswordScreen extends StatelessWidget {
  const ForgotPasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
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

// --- 4. ANA NAVİGASYON ---
class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 0;
  final List<Widget> _pages = [
    const Center(
      child: Text(
        "ÖĞRENME SAYFASI (YAKINDA)",
        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
      ),
    ),
    const Center(child: Text("SÖZLÜK (BOŞ)")),
    const Center(child: Text("WORDLE (YAKINDA)")),
    const ProfilSekmesi(
      isim: "Misafir Kullanıcı",
      email: "misafir@monolingo.com",
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        type: BottomNavigationBarType.fixed,
        selectedItemColor: kDeepNavy,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.school), label: "Öğren"),
          BottomNavigationBarItem(icon: Icon(Icons.list), label: "Sözlük"),
          BottomNavigationBarItem(icon: Icon(Icons.games), label: "Wordle"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profil"),
        ],
      ),
    );
  }
}

// --- 5. PROFİL SEKMESİ (Senin profile.txt ve istediğin sadeleşmiş hal) ---
class ProfilSekmesi extends StatelessWidget {
  final String isim;
  final String email;
  const ProfilSekmesi({super.key, required this.isim, required this.email});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Profil")),
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
          _buildActionTile(
            context,
            "Profili Düzenle",
            "Kişisel bilgileri güncelle",
            Icons.edit,
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

  Widget _buildActionTile(
    BuildContext context,
    String title,
    String desc,
    IconData icon,
  ) {
    return ListTile(
      leading: Icon(icon, color: kAccentCopper),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text(desc),
      trailing: const Icon(Icons.chevron_right),
      onTap: () {},
    );
  }
}
