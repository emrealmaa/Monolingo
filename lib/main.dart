import 'package:flutter/material.dart';
import 'screens/login_screen.dart';
import 'screens/theme_notifier.dart';
import 'data/db_helper.dart';
import 'models/word_model.dart';

// --- BİLDİRİM İÇİN GEREKLİ OLANLAR BURADA AGA ---
import 'data/notification_service.dart'; // Dosya yolun hangisiyse ona göre düzelt

// --- KELİME VERİLERİ ---
import 'data/A1_kelime.dart';
import 'data/A2_kelime.dart';
import 'data/B1_kelime.dart';
import 'data/B2_kelime.dart';
import 'data/C1_kelime.dart';

void main() async {
  // 1. Flutter motorunu hazırla
  WidgetsFlutterBinding.ensureInitialized();

  // --- BİLDİRİM SERVİSİNİ BAŞLATAN KRİTİK KISIM ---
  // Servisi başlatıyoruz ve içindeki init fonksiyonunu bekliyoruz (await)
  final notificationService = NotificationService();
  await notificationService.init();
  // ----------------------------------------------

  final db = DbHelper();

  // 2. Mevcut durumu kontrol et
  var stats = await db.getGenelIstatistikler();
  print("--- MONOLINGO SİSTEM KONTROLÜ ---");
  print("Veritabanındaki Kelime Sayısı: ${stats['toplam']}");

  // 3. EĞER VERİTABANI BOŞSA HER ŞEYİ YÜKLE
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
      await db.kelimeDurumlariniSenkronizeEt(tumKelimeler);
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
      home: const LoginSayfasi(),
    );
  }
}
