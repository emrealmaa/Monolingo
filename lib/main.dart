import 'package:flutter/material.dart';
import 'screens/login_screen.dart';
import 'screens/theme_notifier.dart';
import 'data/db_helper.dart';
import 'models/word_model.dart';
// AGA: Bu import şart, yoksa aktifKullaniciId'yi görmez
import 'constants/constants.dart';

// --- BİLDİRİM İÇİN GEREKLİ OLANLAR BURADA AGA ---
import 'data/notification_service.dart';

// --- KELİME VERİLERİ ---
import 'data/A1_kelime.dart';
import 'data/A2_kelime.dart';
import 'data/B1_kelime.dart';
import 'data/B2_kelime.dart';
import 'data/C1_kelime.dart';

void main() async {
  // 1. Flutter motorunu hazırla
  WidgetsFlutterBinding.ensureInitialized();

  // --- BİLDİRİM SERVİSİ ---
  final notificationService = NotificationService();
  await notificationService.init();

  final db = DbHelper();

  // 2. Mevcut durumu kontrol et
  // AGA: Henüz kimse login olmadığı için varsayılan olarak '1' ID'li kullanıcıya bakıyoruz
  // Uygulama ilk kez kurulduğunda bu kontrolü yapar.
  var stats = await db.getGenelIstatistikler(1);

  print("--- MONOLINGO SİSTEM KONTROLÜ ---");
  print("Veritabanındaki Kelime Sayısı: ${stats['toplam']}");

  // 3. EĞER VERİTABANI BOŞSA (İLK KURULUM)
  if (stats['toplam'] == 0) {
    print("raflar boş, tüm seviyeler kamyonla geliyor...");

    final List<Map<String, dynamic>> tumHamVeriler = [
      ...a1RawData,
      ...a2RawData,
      ...b1RawData,
      ...b2RawData,
      ...c1RawData,
    ];

    List<WordModel> tumKelimeler = tumHamVeriler
        .map((m) => WordModel.fromMap(m))
        .toList();

    if (tumKelimeler.isNotEmpty) {
      // AGA: İlk kurulumda kelimeleri 1 numaralı kullanıcıya (veya sisteme) senkronize ediyoruz
      await db.kelimeDurumlariniSenkronizeEt(tumKelimeler, 1);
      print("İŞLEM TAMAM: ${tumKelimeler.length} kelime veritabanına çakıldı!");
    }
  }

  runApp(const KelimeUygulamasi());
}

class KelimeUygulamasi extends StatefulWidget {
  const KelimeUygulamasi({super.key});
  static _KelimeUygulamasiState? of(BuildContext context) =>
      context.findAncestorStateOfType<_KelimeUygulamasiState>();

  @override
  State<KelimeUygulamasi> createState() => _KelimeUygulamasiState();
}

class _KelimeUygulamasiState extends State<KelimeUygulamasi> {
  ThemeMode _themeMode = ThemeMode.dark;
  void changeTheme(ThemeMode themeMode) =>
      setState(() => _themeMode = themeMode);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Monolingo',
      theme: ThemeNotifier.lightTheme,
      darkTheme: ThemeNotifier.darkTheme,
      themeMode: _themeMode,
      // AGA: Giriş sayfasına yönlendiriyoruz
      home: const LoginSayfasi(),
    );
  }
}
