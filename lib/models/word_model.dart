class WordModel {
  int? id;
  final String word;
  final String meaning;
  final String hint;
  final String example;
  final String example_tr;
  final String level;
  int asama;

  WordModel({
    this.id,
    required this.word,
    required this.meaning,
    required this.hint,
    required this.example,
    required this.example_tr,
    required this.level,
    this.asama = 0,
  });

  // Ham veriyi (Map) WordModel nesnesine çevirir
  // Buradaki key isimleri (örn: 'example_tr') JSON dosyanla birebir aynı olmalı
  factory WordModel.fromMap(Map<String, dynamic> map) {
    return WordModel(
      id: map['id'] as int?,
      word: map['word']?.toString() ?? '',
      meaning: map['meaning']?.toString() ?? '',
      hint: map['hint']?.toString() ?? '',
      example: map['example']?.toString() ?? '',
      example_tr:
          map['example_tr']?.toString() ?? '', // JSON'daki example_tr'yi okur
      level: map['level']?.toString() ?? '',
      asama: (map['asama'] is int) ? map['asama'] : 0, // Tip kontrolü ekledik
    );
  }

  // Modeli tekrar Map formatına çevirir (Veritabanı işlemleri için)
  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'word': word,
      'meaning': meaning,
      'hint': hint,
      'example': example,
      'example_tr': example_tr,
      'level': level,
      'asama': asama,
    };
  }

  // Nesneyi kopyalayıp güncellemek için (Özellikle 'asama' artırırken lazım olur)
  WordModel copyWith({int? id, int? asama}) {
    return WordModel(
      id: id ?? this.id,
      word: this.word,
      meaning: this.meaning,
      hint: this.hint,
      example: this.example,
      example_tr: this.example_tr,
      level: this.level,
      asama: asama ?? this.asama,
    );
  }
}
