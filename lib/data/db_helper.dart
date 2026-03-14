import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as p;
import 'dart:async';
import 'dart:convert';
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
      version: 5, // AGA: Versiyonu 5 yaptık çünkü yeni sütun ekledik
      onCreate: (db, version) async {
        await db.execute(
          'CREATE TABLE Kullanicilar (id INTEGER PRIMARY KEY AUTOINCREMENT, isim TEXT, email TEXT UNIQUE, sifre TEXT, dogumTarihi TEXT)',
        );

        // AGA: asama_alistirma sütunu eklendi
        await db.execute(
          'CREATE TABLE Kelimeler (id INTEGER PRIMARY KEY AUTOINCREMENT, word TEXT, meaning TEXT, hint TEXT, example TEXT, example_tr TEXT, level TEXT, asama INTEGER DEFAULT 0, asama_alistirma INTEGER DEFAULT 0, son_tekrar TEXT, sonraki_tekrar TEXT)',
        );

        await db.execute(
          'CREATE TABLE Ayarlar (asama INTEGER PRIMARY KEY, gun_sayisi INTEGER)',
        );

        await db.execute(
          'CREATE TABLE quiz_results (id INTEGER PRIMARY KEY AUTOINCREMENT, level TEXT, correct INTEGER, wrong INTEGER, wrong_words TEXT, date TEXT)',
        );

        List<int> varsayilanGunler = [0, 1, 7, 30, 90, 180, 365];
        for (int i = 1; i <= 6; i++) {
          await db.insert('Ayarlar', {
            'asama': i,
            'gun_sayisi': varsayilanGunler[i],
          });
        }
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 3) {
          await db.execute(
            'CREATE TABLE quiz_results (id INTEGER PRIMARY KEY AUTOINCREMENT, level TEXT, correct INTEGER, wrong INTEGER, date TEXT)',
          );
        }
        if (oldVersion < 4) {
          await db.execute(
            'ALTER TABLE quiz_results ADD COLUMN wrong_words TEXT',
          );
        }
        // AGA: Mevcut kullanıcılar için asama_alistirma sütununu ekliyoruz
        if (oldVersion < 5) {
          await db.execute(
            'ALTER TABLE Kelimeler ADD COLUMN asama_alistirma INTEGER DEFAULT 0',
          );
        }
      },
    );
  }

  // --- KULLANICI İŞLEMLERİ --- (AYNI KALDI)
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
    }
    return false;
  }

  // --- OYUNLAR VE ÖĞRENME --- (GÜNCELLENDİ)

  Future<int> getOgrenilmisKelimeSayisi() async {
    final db = await database;
    return Sqflite.firstIntValue(
          await db.rawQuery('SELECT COUNT(*) FROM Kelimeler WHERE asama = 6'),
        ) ??
        0;
  }

  Future<Map<String, dynamic>?> getOgrenilmisRastgeleKelime() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'Kelimeler',
      where: 'asama = 6',
      orderBy: 'RANDOM()',
      limit: 1,
    );
    return maps.isNotEmpty ? maps.first : null;
  }

  Future<Map<String, dynamic>> getRandomWordByLevel(String level) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'Kelimeler',
      where: 'UPPER(level) = ?',
      whereArgs: [level.toUpperCase()],
      orderBy: 'RANDOM()',
      limit: 1,
    );
    return maps.isNotEmpty
        ? maps.first
        : {'word': 'EMPTY', 'meaning': 'Kelimeler yükleniyor...'};
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
    // AGA: Burada hem yeni kelimeleri hem de tekrar zamanı gelenleri çekiyoruz
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

  // --- AYARLAR VE İLERLEME --- (Sınav Kulvarı)
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

  // AGA: Bu metod ASIL SINAV aşamasını ve tekrar tarihini günceller
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

  // AGA: Bu yeni metod sadece ALIŞTIRMA (Bildim/Bilemedim) aşamasını günceller
  Future<int> kelimeAsamaGuncelleAlistirma(int? id, bool bildiMi) async {
    if (id == null) return -1;
    var db = await database;

    // Mevcut alıştırma aşamasını al
    List<Map<String, dynamic>> current = await db.query(
      'Kelimeler',
      columns: ['asama_alistirma'],
      where: 'id = ?',
      whereArgs: [id],
    );
    int mevcut = current.isNotEmpty
        ? (current.first['asama_alistirma'] ?? 0)
        : 0;

    int yeniAsama;
    if (bildiMi) {
      yeniAsama = mevcut < 6 ? mevcut + 1 : 6;
    } else {
      yeniAsama = 1; // Bilemezse başa döner
    }

    return await db.update(
      'Kelimeler',
      {'asama_alistirma': yeniAsama},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // --- GELİŞMİŞ İSTATİSTİKLER --- (AYNI KALDI)
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
    int baslanmadi =
        Sqflite.firstIntValue(
          await db.rawQuery('SELECT COUNT(*) FROM Kelimeler WHERE asama = 0'),
        ) ??
        0;

    List<Map<String, dynamic>> asamaDagilimiRaw = await db.rawQuery(
      'SELECT asama, COUNT(*) as adet FROM Kelimeler GROUP BY asama',
    );
    Map<int, int> asamaDagilimi = {for (int i = 0; i <= 6; i++) i: 0};
    for (var row in asamaDagilimiRaw) {
      asamaDagilimi[row['asama'] as int] = row['adet'] as int;
    }

    final List<Map<String, dynamic>> quizStats = await db.rawQuery(
      'SELECT SUM(correct) as total_correct, SUM(wrong) as total_wrong FROM quiz_results',
    );
    int totalCorrect = quizStats[0]['total_correct'] ?? 0;
    int totalWrong = quizStats[0]['total_wrong'] ?? 0;

    return {
      'toplam': toplam,
      'tamamlanan': tamamlanan,
      'devam_eden': devamEden,
      'baslanmadi': baslanmadi,
      'asama_dagilimi': asamaDagilimi,
      'total_correct': totalCorrect,
      'total_wrong': totalWrong,
    };
  }

  // --- SINAV İŞLEMLERİ (GELİŞMİŞ) ---

  Future<void> saveQuizResult(
    String level,
    int correct,
    int wrong,
    List<Map<String, String>> wrongWordsList,
  ) async {
    final db = await database;
    await db.insert('quiz_results', {
      'level': level,
      'correct': correct,
      'wrong': wrong,
      'wrong_words': jsonEncode(wrongWordsList),
      'date': DateTime.now().toIso8601String(),
    });
  }

  Future<List<Map<String, dynamic>>> getLastFiveQuizzes() async {
    final db = await database;
    return await db.query('quiz_results', orderBy: 'date DESC', limit: 5);
  }

  // AGA: Sınav ekranına sadece tarihi gelmiş kelimeleri getirir
  Future<List<Map<String, dynamic>>> getQuestionsForQuiz(String level) async {
    final db = await database;
    String suAn = DateTime.now().toIso8601String();

    // AGA: KRİTİK FİLTRE BURADA. Sadece süresi dolanlar veya hiç girilmeyenler gelir.
    final List<Map<String, dynamic>> allWords = await db.query(
      'Kelimeler',
      where:
          'UPPER(level) = ? AND (sonraki_tekrar <= ? OR sonraki_tekrar IS NULL)',
      whereArgs: [level.toUpperCase(), suAn],
    );

    if (allWords.length < 5) return [];

    List<Map<String, dynamic>> quizQuestions = [];
    for (var word in allWords) {
      String correct = word['meaning'] ?? "Bilinmiyor";
      List<String> others = allWords
          .where((w) => w['meaning'] != correct)
          .map((w) => (w['meaning'] ?? "Hata") as String)
          .toList();
      others.shuffle();

      List<String> options = [correct];
      options.addAll(others.take(3));
      options.shuffle();

      quizQuestions.add({
        'id': word['id'],
        'question': word['word'],
        'correct': correct,
        'options': options,
        'asama': word['asama'] ?? 0,
      });
    }
    quizQuestions.shuffle();
    return quizQuestions;
  }
}
