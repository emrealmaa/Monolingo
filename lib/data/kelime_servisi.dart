import '../models/word_model.dart';
import 'A1_kelime.dart';
import 'A2_kelime.dart';
import 'B1_kelime.dart';
import 'B2_kelime.dart';
import 'C1_kelime.dart';

class KelimeServisi {
  // --- DÜZELTME BURADA: Dönüş tipi List<WordModel> yapıldı ---
  static List<WordModel> getKelimelerByLevel(String seviye) {
    List<Map<String, dynamic>> rawData;

    switch (seviye.toUpperCase()) {
      case 'A1':
        rawData = a1RawData;
        break;
      case 'A2':
        rawData = a2RawData;
        break;
      case 'B1':
        rawData = b1RawData;
        break;
      case 'B2':
        rawData = b2RawData;
        break;
      case 'C1':
        rawData = c1RawData;
        break;
      default:
        rawData = [];
    }

    // Ham Map verisini WordModel listesine çevirip döndürüyoruz aga
    return rawData.map((e) => WordModel.fromMap(e)).toList();
  }

  // Diğer fonksiyonu da buna göre güncelleyelim
  static List<WordModel> seviyeyeGoreGetir(String seviye) {
    return getKelimelerByLevel(seviye);
  }
}
