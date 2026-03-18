class WordModel {
  int? id;
  final String word;
  final String meaning;
  final String hint;
  final String example;
  final String example_tr;
  final String level;
  int asama;
  // AGA: İşte yeni eklediğimiz o kritik iki değişken
  int asama_alistirma;
  int asama_sinav;

  WordModel({
    this.id,
    required this.word,
    required this.meaning,
    required this.hint,
    required this.example,
    required this.example_tr,
    required this.level,
    this.asama = 0,
    this.asama_alistirma = 0, // Varsayılan 0
    this.asama_sinav = 0, // Varsayılan 0
  });

  // Ham veriyi (Map) WordModel nesnesine çevirir
  factory WordModel.fromMap(Map<String, dynamic> map) {
    return WordModel(
      id: map['id'] as int?,
      word: map['word']?.toString() ?? '',
      meaning: map['meaning']?.toString() ?? '',
      hint: map['hint']?.toString() ?? '',
      example: map['example']?.toString() ?? '',
      example_tr: map['example_tr']?.toString() ?? '',
      level: map['level']?.toString() ?? '',
      asama: (map['asama'] is int) ? map['asama'] : 0,
      // AGA: Veritabanındaki yeni kolonları modele bağlıyoruz
      asama_alistirma: (map['asama_alistirma'] is int)
          ? map['asama_alistirma']
          : 0,
      asama_sinav: (map['asama_sinav'] is int) ? map['asama_sinav'] : 0,
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
      'asama_alistirma': asama_alistirma,
      'asama_sinav': asama_sinav,
    };
  }

  // Nesneyi kopyalayıp güncellemek için (Aşama takibi için hayati)
  WordModel copyWith({
    int? id,
    int? asama,
    int? asama_alistirma,
    int? asama_sinav,
  }) {
    return WordModel(
      id: id ?? this.id,
      word: this.word,
      meaning: this.meaning,
      hint: this.hint,
      example: this.example,
      example_tr: this.example_tr,
      level: this.level,
      asama: asama ?? this.asama,
      asama_alistirma: asama_alistirma ?? this.asama_alistirma,
      asama_sinav: asama_sinav ?? this.asama_sinav,
    );
  }
}
