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
      version: 8, // AGA: Versiyonu 8 yaptık (Kullanıcı bazlı sisteme geçiş)
      onCreate: (db, version) async {
        await db.execute(
          'CREATE TABLE Kullanicilar (id INTEGER PRIMARY KEY AUTOINCREMENT, isim TEXT, email TEXT UNIQUE, sifre TEXT, dogumTarihi TEXT, streak INTEGER DEFAULT 0, son_giris TEXT)',
        );

        // AGA: Kelimeler tablosuna her kelimenin kime ait olduğunu bilen kullanici_id eklendi
        await db.execute(
          'CREATE TABLE Kelimeler (id INTEGER PRIMARY KEY AUTOINCREMENT, kullanici_id INTEGER, word TEXT, meaning TEXT, hint TEXT, example TEXT, example_tr TEXT, level TEXT, asama INTEGER DEFAULT 0, asama_alistirma INTEGER DEFAULT 0, asama_sinav INTEGER DEFAULT 0, son_tekrar TEXT, sonraki_tekrar TEXT)',
        );

        await db.execute(
          'CREATE TABLE Ayarlar (asama INTEGER PRIMARY KEY, gun_sayisi INTEGER)',
        );

        // AGA: Sınav sonuçlarına kullanici_id eklendi
        await db.execute(
          'CREATE TABLE quiz_results (id INTEGER PRIMARY KEY AUTOINCREMENT, kullanici_id INTEGER, level TEXT, correct INTEGER, wrong INTEGER, wrong_words TEXT, date TEXT)',
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
        if (oldVersion < 5) {
          await db.execute(
            'ALTER TABLE Kelimeler ADD COLUMN asama_alistirma INTEGER DEFAULT 0',
          );
        }
        if (oldVersion < 6) {
          await db.execute(
            'ALTER TABLE Kelimeler ADD COLUMN asama_sinav INTEGER DEFAULT 0',
          );
        }
        if (oldVersion < 7) {
          await db.execute(
            'ALTER TABLE Kullanicilar ADD COLUMN streak INTEGER DEFAULT 0',
          );
          await db.execute(
            'ALTER TABLE Kullanicilar ADD COLUMN son_giris TEXT',
          );
        }
        // AGA: Versiyon 8 Güncellemesi (Mevcut tabloları bozmadan kolon ekleme)
        if (oldVersion < 8) {
          try {
            await db.execute(
              'ALTER TABLE Kelimeler ADD COLUMN kullanici_id INTEGER DEFAULT 1',
            );
          } catch (e) {}
          try {
            await db.execute(
              'ALTER TABLE quiz_results ADD COLUMN kullanici_id INTEGER DEFAULT 1',
            );
          } catch (e) {}
        }
      },
    );
  }

  // --- STREAK (ZİNCİRİ KIRMA) MANTIĞI ---
  Future<void> updateStreak(int userId) async {
    var db = await database;
    var user = await db.query(
      'Kullanicilar',
      where: 'id = ?',
      whereArgs: [userId],
    );
    if (user.isEmpty) return;

    int currentStreak = (user.first['streak'] as int?) ?? 0;
    String? lastLoginStr = user.first['son_giris'] as String?;
    DateTime now = DateTime.now();
    DateTime today = DateTime(now.year, now.month, now.day);

    if (lastLoginStr != null) {
      DateTime lastLogin = DateTime.parse(lastLoginStr);
      DateTime lastLoginDate = DateTime(
        lastLogin.year,
        lastLogin.month,
        lastLogin.day,
      );
      int diff = today.difference(lastLoginDate).inDays;

      if (diff == 1)
        currentStreak++;
      else if (diff > 1)
        currentStreak = 1;
    } else {
      currentStreak = 1;
    }

    await db.update(
      'Kullanicilar',
      {'streak': currentStreak, 'son_giris': now.toIso8601String()},
      where: 'id = ?',
      whereArgs: [userId],
    );
  }

  // --- KULLANICI İŞLEMLERİ ---
  // Kayıt olunca oluşan yeni ID'yi döndürüyoruz ki hafızaya alabilelim
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
    if (res.isNotEmpty) {
      await updateStreak(res.first['id']);
      return res.first;
    }
    return null;
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

  // --- OYUNLAR VE ÖĞRENME ---
  // Artık sadece aktif kullanıcıya ait öğrenilmiş kelimeleri sayar
  Future<int> getOgrenilmisKelimeSayisi(int userId) async {
    final db = await database;
    return Sqflite.firstIntValue(
          await db.rawQuery(
            'SELECT COUNT(*) FROM Kelimeler WHERE kullanici_id = ? AND asama_alistirma >= 5 AND asama_sinav >= 5',
            [userId],
          ),
        ) ??
        0;
  }

  Future<Map<String, dynamic>?> getOgrenilmisRastgeleKelime(int userId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'Kelimeler',
      where: 'kullanici_id = ? AND asama_alistirma >= 5 AND asama_sinav >= 5',
      whereArgs: [userId],
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

  // Kullanıcı bazlı öğrenilecek kelimeleri getirir
  Future<List<WordModel>> ogrenilecekKelimeleriGetir(
    int userId,
    String seviye,
    int limit,
  ) async {
    var db = await database;
    String suAn = DateTime.now().toIso8601String();
    List<Map<String, dynamic>> maps = await db.query(
      'Kelimeler',
      where:
          'kullanici_id = ? AND UPPER(level) = ? AND asama_alistirma < 6 AND (sonraki_tekrar <= ? OR sonraki_tekrar IS NULL)',
      whereArgs: [userId, seviye.toUpperCase(), suAn],
      limit: limit,
      orderBy: 'RANDOM()',
    );
    return List.generate(maps.length, (i) => WordModel.fromMap(maps[i]));
  }

  Future<List<WordModel>> kelimeDurumlariniSenkronizeEt(
    List<WordModel> hamListe,
    int userId,
  ) async {
    var db = await database;
    List<WordModel> donusListesi = [];
    for (var k in hamListe) {
      var res = await db.query(
        'Kelimeler',
        where: 'word = ? AND kullanici_id = ?',
        whereArgs: [k.word, userId],
      );
      if (res.isNotEmpty) {
        donusListesi.add(WordModel.fromMap(res.first));
      } else {
        // Yeni kelimeyi bu kullanıcıya özel ekle
        Map<String, dynamic> wordMap = k.toMap();
        wordMap['kullanici_id'] = userId;
        int id = await db.insert('Kelimeler', wordMap);
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

  // --- GÜNCELLENEN İSTATİSTİK MOTORU (DİNAMİK TARİHLİ VE KULLANICI BAZLI) ---
  Future<Map<String, dynamic>> getGenelIstatistikler(int userId) async {
    final db = await database;

    // 1. Sadece bu kullanıcıya ait aktivite tarihlerini alıyoruz
    var aktiviteRes = await db.rawQuery(
      "SELECT DISTINCT date(date) as gun FROM quiz_results WHERE kullanici_id = ?",
      [userId],
    );
    List<String> doluGunler = aktiviteRes
        .map((e) => e['gun'] as String)
        .toList();

    // 2. SEVİYE BAZLI BAŞARI (Kullanıcıya özel)
    Map<String, double> seviyeBasarilari = {};
    for (var s in ["A1", "A2", "B1", "B2", "C1"]) {
      // Bu seviyede yapılan tüm sınavların toplam doğru ve yanlışını çekiyoruz
      var res = await db.rawQuery(
        'SELECT SUM(correct) as toplamDogru, SUM(wrong) as toplamYanlis '
        'FROM quiz_results '
        'WHERE kullanici_id = ? AND UPPER(level) = ?',
        [userId, s.toUpperCase()],
      );

      int d = (res.first['toplamDogru'] as int?) ?? 0;
      int y = (res.first['toplamYanlis'] as int?) ?? 0;

      int toplamSoru = d + y;

      // Eğer hiç soru çözülmemişse %0, çözülmüşse net başarı yüzdesi
      seviyeBasarilari[s] = toplamSoru > 0 ? (d / toplamSoru) * 100 : 0;
    }

    // 3. ÇİFT BAR VERİSİ (Stage 1-6 Tablosu - Kullanıcıya özel)
    Map<int, List<int>> ciftAsama = {};
    for (int i = 1; i <= 6; i++) {
      int pCount =
          Sqflite.firstIntValue(
            await db.rawQuery(
              'SELECT COUNT(*) FROM Kelimeler WHERE kullanici_id = ? AND asama_alistirma = ?',
              [userId, i],
            ),
          ) ??
          0;
      int sCount =
          Sqflite.firstIntValue(
            await db.rawQuery(
              'SELECT COUNT(*) FROM Kelimeler WHERE kullanici_id = ? AND asama_sinav = ?',
              [userId, i],
            ),
          ) ??
          0;
      ciftAsama[i] = [pCount, sCount];
    }

    // 4. GENEL TOPLAMLAR (Kullanıcıya özel)
    int toplam =
        Sqflite.firstIntValue(
          await db.rawQuery(
            'SELECT COUNT(*) FROM Kelimeler WHERE kullanici_id = ?',
            [userId],
          ),
        ) ??
        0;
    int learned =
        Sqflite.firstIntValue(
          await db.rawQuery(
            'SELECT COUNT(*) FROM Kelimeler WHERE kullanici_id = ? AND asama_alistirma >= 5 AND asama_sinav >= 5',
            [userId],
          ),
        ) ??
        0;

    final quizStats = await db.rawQuery(
      'SELECT SUM(correct) as tc, SUM(wrong) as tw FROM quiz_results WHERE kullanici_id = ?',
      [userId],
    );
    final sonSinavlar = await db.query(
      'quiz_results',
      where: 'kullanici_id = ?',
      whereArgs: [userId],
      orderBy: 'date DESC',
      limit: 5,
    );

    // Kullanıcının streak verisini çek
    var userRes = await db.query(
      'Kullanicilar',
      where: 'id = ?',
      whereArgs: [userId],
    );
    int streak = userRes.isNotEmpty
        ? (userRes.first['streak'] as int? ?? 0)
        : 0;

    return {
      'doluGunler': doluGunler,
      'streak': streak,
      'seviyeBasarilari': seviyeBasarilari,
      'ciftAsamaVerisi': ciftAsama,
      'toplam': toplam,
      'gercektenOgrenilen': learned,
      'total_correct': quizStats[0]['tc'] ?? 0,
      'total_wrong': quizStats[0]['tw'] ?? 0,
      'sonSinavlar': sonSinavlar,
    };
  }

  // --- AŞAMA GÜNCELLEME METOTLARI ---
  Future<int> kelimeAsamaGuncelleSinav(int? id, bool bildiMi) async {
    if (id == null) return -1;
    var db = await database;
    if (bildiMi) {
      return await db.rawUpdate(
        'UPDATE Kelimeler SET asama_sinav = CASE WHEN asama_sinav < 6 THEN asama_sinav + 1 ELSE 6 END WHERE id = ?',
        [id],
      );
    } else {
      return await db.update(
        'Kelimeler',
        {'asama_sinav': 0},
        where: 'id = ?',
        whereArgs: [id],
      );
    }
  }

  Future<int> kelimeAsamaGuncelleAlistirma(int? id, bool bildiMi) async {
    if (id == null) return -1;
    var db = await database;
    if (bildiMi) {
      return await db.rawUpdate(
        'UPDATE Kelimeler SET asama_alistirma = CASE WHEN asama_alistirma < 6 THEN asama_alistirma + 1 ELSE 6 END WHERE id = ?',
        [id],
      );
    } else {
      return await db.update(
        'Kelimeler',
        {'asama_alistirma': 0},
        where: 'id = ?',
        whereArgs: [id],
      );
    }
  }

  // --- SINAV İŞLEMLERİ ---
  Future<void> saveQuizResult(
    int userId, // AGA: Artık kullanıcıyı biliyoruz
    String level,
    int correct,
    int wrong,
    List<Map<String, String>> wrongWordsList,
  ) async {
    final db = await database;
    await db.insert('quiz_results', {
      'kullanici_id': userId,
      'level': level,
      'correct': correct,
      'wrong': wrong,
      'wrong_words': jsonEncode(wrongWordsList),
      'date': DateTime.now().toIso8601String(),
    });
  }

  Future<List<Map<String, dynamic>>> getLastFiveQuizzes(int userId) async {
    final db = await database;
    return await db.query(
      'quiz_results',
      where: 'kullanici_id = ?',
      whereArgs: [userId],
      orderBy: 'date DESC',
      limit: 5,
    );
  }

  Future<List<Map<String, dynamic>>> getQuestionsForQuiz(
    int userId,
    String level,
  ) async {
    final db = await database;
    String suAn = DateTime.now().toIso8601String();
    final List<Map<String, dynamic>> allWords = await db.query(
      'Kelimeler',
      where:
          'kullanici_id = ? AND UPPER(level) = ? AND asama_sinav < 6 AND (sonraki_tekrar <= ? OR sonraki_tekrar IS NULL)',
      whereArgs: [userId, level.toUpperCase(), suAn],
      orderBy: 'RANDOM()',
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
        'asama': word['asama_sinav'] ?? 0,
      });
    }
    quizQuestions.shuffle();
    return quizQuestions;
  } // ← getQuestionsForQuiz'in kapanışı (535. satır, bu zaten var)

  // Demo mod için - tüm kelimelerden rastgele 1 tane getirir
  Future<Map<String, dynamic>?> getDemoRastgeleKelime() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'Kelimeler',
      orderBy: 'RANDOM()',
      limit: 1,
    );
    return maps.isNotEmpty ? maps.first : null;
  }
} // ← class DbHelper kapanışı
