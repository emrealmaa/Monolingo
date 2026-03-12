import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as p;
import 'dart:async';
import 'package:ingilizce_ogrenme_app/models/word_model.dart';

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
    String path = p.join(databasesPath, 'hafiza_kupu_v2.db');

    return await openDatabase(
      path,
      version: 2,
      onCreate: (db, version) async {
        await db.execute(
          'CREATE TABLE Kullanicilar (id INTEGER PRIMARY KEY AUTOINCREMENT, isim TEXT, email TEXT UNIQUE, sifre TEXT, dogumTarihi TEXT)',
        );

        await db.execute(
          'CREATE TABLE Kelimeler (id INTEGER PRIMARY KEY AUTOINCREMENT, word TEXT, meaning TEXT, hint TEXT, example TEXT, example_tr TEXT, level TEXT, asama INTEGER DEFAULT 0, son_tekrar TEXT, sonraki_tekrar TEXT)',
        );

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

  // --- KULLANICI İŞLEMLERİ ---
  Future<int> kayitOl(Map<String, dynamic> user) async {
    var db = await database;
    return await db.insert('Kullanicilar', user);
  }

  Future<Map<String, dynamic>?> girisYap(String email, String sifre) async {
    var db = await database;
    List<Map<String, dynamic>> res = await db.query(
      'Kullanicilar',
      where: "email = ? AND sifre = ?",
      whereArgs: [email, sifre],
    );
    return res.isNotEmpty ? res.first : null;
  }

  Future<bool> sifreGuncelle(
    String email,
    String mevcutSifre,
    String yeniSifre,
  ) async {
    var db = await database;

    List<Map<String, dynamic>> res = await db.query(
      'Kullanicilar',
      where: "email = ? AND sifre = ?",
      whereArgs: [email, mevcutSifre],
    );

    if (res.isNotEmpty) {
      int count = await db.update(
        'Kullanicilar',
        {'sifre': yeniSifre},
        where: "email = ?",
        whereArgs: [email],
      );
      return count > 0;
    } else {
      return false;
    }
  }

  // --- OYUNLAR VE ÖĞRENME ---

  // AGA SENİN İSTEDİĞİN METOT BURADA (SINIFIN İÇİNE ALINDI VE TABLO İSMİ DÜZELDİ)
  Future<Map<String, dynamic>> getRandomWordByLevel(String level) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'Kelimeler', // Senin tablo adın 'Kelimeler'
      where: 'UPPER(level) = ?',
      whereArgs: [level.toUpperCase()],
      orderBy: 'RANDOM()',
      limit: 1,
    );

    if (maps.isNotEmpty) {
      return maps.first;
    } else {
      return {'word': 'EMPTY', 'meaning': 'Bu seviyede kelime bulunamadı'};
    }
  }

  Future<List<WordModel>> rastgeleKelimeGetir(String seviye, int limit) async {
    var db = await database;
    List<Map<String, dynamic>> maps = await db.query(
      'Kelimeler',
      where: 'UPPER(level) = ?',
      whereArgs: [seviye.toUpperCase()],
      limit: limit,
      orderBy: 'RANDOM()',
    );
    return List.generate(maps.length, (i) => WordModel.fromMap(maps[i]));
  }

  Future<List<WordModel>> ogrenilecekKelimeleriGetir(
    String seviye,
    int limit,
  ) async {
    var db = await database;
    String suAn = DateTime.now().toIso8601String();
    List<Map<String, dynamic>> maps = await db.query(
      'Kelimeler',
      where:
          'UPPER(level) = ? AND (asama = 0 OR sonraki_tekrar <= ? OR sonraki_tekrar IS NULL)',
      whereArgs: [seviye.toUpperCase(), suAn],
      limit: limit,
      orderBy: 'asama ASC',
    );
    return List.generate(maps.length, (i) => WordModel.fromMap(maps[i]));
  }

  Future<List<WordModel>> kelimeDurumlariniSenkronizeEt(
    List<WordModel> hamListe,
  ) async {
    var db = await database;
    List<WordModel> donusListesi = [];
    for (var k in hamListe) {
      var res = await db.query(
        'Kelimeler',
        where: 'word = ?',
        whereArgs: [k.word],
      );
      if (res.isNotEmpty) {
        donusListesi.add(WordModel.fromMap(res.first));
      } else {
        int id = await db.insert('Kelimeler', k.toMap());
        donusListesi.add(k.copyWith(id: id));
      }
    }
    return donusListesi;
  }

  // --- AYARLAR VE İLERLEME ---
  Future<int> ayarGuncelle(int asama, int gun) async {
    var db = await database;
    return await db.update(
      'Ayarlar',
      {'gun_sayisi': gun},
      where: 'asama = ?',
      whereArgs: [asama],
    );
  }

  Future<Map<int, int>> ayarlariGetir() async {
    var db = await database;
    List<Map<String, dynamic>> res = await db.query(
      'Ayarlar',
      orderBy: 'asama ASC',
    );
    return {
      for (var item in res) item['asama'] as int: item['gun_sayisi'] as int,
    };
  }

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
      'Kelimeler',
      {
        'asama': hedefAsama,
        'son_tekrar': simdi.toIso8601String(),
        'sonraki_tekrar': sonraki.toIso8601String(),
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // --- GELİŞMİŞ İSTATİSTİKLER ---
  Future<Map<String, dynamic>> getGenelIstatistikler() async {
    final db = await database;
    int toplam =
        Sqflite.firstIntValue(
          await db.rawQuery('SELECT COUNT(*) FROM Kelimeler'),
        ) ??
        0;
    int tamamlanan =
        Sqflite.firstIntValue(
          await db.rawQuery('SELECT COUNT(*) FROM Kelimeler WHERE asama = 6'),
        ) ??
        0;
    int devamEden =
        Sqflite.firstIntValue(
          await db.rawQuery(
            'SELECT COUNT(*) FROM Kelimeler WHERE asama > 0 AND asama < 6',
          ),
        ) ??
        0;

    List<Map<String, dynamic>> asamaDagilimiRaw = await db.rawQuery(
      'SELECT asama, COUNT(*) as adet FROM Kelimeler GROUP BY asama',
    );
    Map<int, int> asamaDagilimi = {for (int i = 0; i <= 6; i++) i: 0};
    for (var row in asamaDagilimiRaw) {
      asamaDagilimi[row['asama'] as int] = row['adet'] as int;
    }

    return {
      'toplam': toplam,
      'tamamlanan': tamamlanan,
      'devam_eden': devamEden,
      'asama_dagilimi': asamaDagilimi,
    };
  }

  Future<Map<String, dynamic>> getSeviyeIstatistigi(String seviye) async {
    final db = await database;
    String s = seviye.toUpperCase();
    int toplam =
        Sqflite.firstIntValue(
          await db.rawQuery(
            'SELECT COUNT(*) FROM Kelimeler WHERE UPPER(level) = ?',
            [s],
          ),
        ) ??
        0;
    int biten =
        Sqflite.firstIntValue(
          await db.rawQuery(
            'SELECT COUNT(*) FROM Kelimeler WHERE UPPER(level) = ? AND asama = 6',
            [s],
          ),
        ) ??
        0;
    double oran = toplam > 0 ? (biten / toplam) * 100 : 0.0;

    return {'toplam': toplam, 'biten': biten, 'yuzde': oran};
  }
}
