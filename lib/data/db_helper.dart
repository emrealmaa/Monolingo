import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as p;
import 'dart:async';
import '../models/word_model.dart'; // Import yolunu düzelttik

class DbHelper {
  static final DbHelper _instance = DbHelper._internal();
  static Database? _database;

  factory DbHelper() => _instance;
  DbHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDb();
    return _database!;
  }

  Future<Database> _initDb() async {
    String databasesPath = await getDatabasesPath();
    String path = p.join(
      databasesPath,
      'monolingo_v1.db',
    ); // DB adını güncelledik

    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        // --- 1. STORY: KULLANICILAR (Hocanın istediği isimler) ---
        await db.execute(
          'CREATE TABLE Users (UserID INTEGER PRIMARY KEY AUTOINCREMENT, UserName TEXT, Password TEXT, Email TEXT UNIQUE)',
        );

        // --- 2. STORY: KELİMELER (Hocanın istediği yapı + bizim algoritma) ---
        await db.execute(
          'CREATE TABLE Words (WordID INTEGER PRIMARY KEY AUTOINCREMENT, EngWordName TEXT, TurWordName TEXT, Picture TEXT, Level TEXT, Asama INTEGER DEFAULT 0, SonTekrar TEXT, SonrakiTekrar TEXT)',
        );

        // --- WORD SAMPLES (Cümle örnekleri için ayrı tablo - Hoca bunu istemişti) ---
        await db.execute(
          'CREATE TABLE WordSamples (WordSamplesID INTEGER PRIMARY KEY AUTOINCREMENT, WordID INTEGER, Sample TEXT, SampleTr TEXT)',
        );

        // --- 3. STORY: ALGORİTMA AYARLARI (6 Sefer Tekrar) ---
        await db.execute(
          'CREATE TABLE Ayarlar (asama INTEGER PRIMARY KEY, gun_sayisi INTEGER)',
        );

        List<int> varsayilanGunler = [0, 1, 7, 30, 90, 180, 365];
        for (int i = 1; i <= 6; i++) {
          await db.insert('Ayarlar', {
            'asama': i,
            'gun_sayisi': varsayilanGunler[i],
          });
        }
      },
    );
  }

  // --- KULLANICI İŞLEMLERİ (Revize Edildi) ---
  Future<int> kayitOl(Map<String, dynamic> user) async {
    var db = await database;
    // user Map'i içindeki keyleri UserName, Password, Email olarak göndermelisin
    return await db.insert('Users', user);
  }

  Future<Map<String, dynamic>?> girisYap(String email, String sifre) async {
    var db = await database;
    List<Map<String, dynamic>> res = await db.query(
      'Users',
      where: "Email = ? AND Password = ?",
      whereArgs: [email, sifre],
    );
    return res.isNotEmpty ? res.first : null;
  }

  // --- ÖĞRENME VE SINAV MODÜLÜ ---
  Future<List<WordModel>> ogrenilecekKelimeleriGetir(
    String seviye,
    int limit,
  ) async {
    var db = await database;
    String suAn = DateTime.now().toIso8601String();
    List<Map<String, dynamic>> maps = await db.query(
      'Words',
      where:
          'UPPER(Level) = ? AND (Asama = 0 OR SonrakiTekrar <= ? OR SonrakiTekrar IS NULL)',
      whereArgs: [seviye.toUpperCase(), suAn],
      limit: limit,
      orderBy: 'Asama ASC',
    );
    return List.generate(maps.length, (i) => WordModel.fromMap(maps[i]));
  }

  // --- 6 SEFER TEKRAR ALGORİTMASI (En Önemli Kısım) ---
  Future<int> kelimeAsamaGuncelle(int? id, int yeniAsama) async {
    if (id == null) return -1;
    var db = await database;
    int hedefAsama = yeniAsama > 6 ? 6 : (yeniAsama < 1 ? 1 : yeniAsama);

    List<Map<String, dynamic>> ayar = await db.query(
      'Ayarlar',
      where: 'asama = ?',
      whereArgs: [hedefAsama],
    );
    int eklenecekGun = ayar.isNotEmpty ? ayar.first['gun_sayisi'] as int : 1;

    DateTime simdi = DateTime.now();
    DateTime sonraki = simdi.add(Duration(days: eklenecekGun));

    return await db.update(
      'Words',
      {
        'Asama': hedefAsama,
        'SonTekrar': simdi.toIso8601String(),
        'SonrakiTekrar': sonraki.toIso8601String(),
      },
      where: 'WordID = ?',
      whereArgs: [id],
    );
  }

  // --- İSTATİSTİKLER ---
  Future<Map<String, dynamic>> getGenelIstatistikler() async {
    final db = await database;
    int toplam =
        Sqflite.firstIntValue(
          await db.rawQuery('SELECT COUNT(*) FROM Words'),
        ) ??
        0;
    int tamamlanan =
        Sqflite.firstIntValue(
          await db.rawQuery('SELECT COUNT(*) FROM Words WHERE Asama = 6'),
        ) ??
        0;

    return {'toplam': toplam, 'tamamlanan': tamamlanan};
  }
}
