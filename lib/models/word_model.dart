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

  factory WordModel.fromMap(Map<String, dynamic> map) {
    return WordModel(
      // DbHelper'daki yeni kolon isimlerine göre okuyoruz
      id: map['WordID'] as int?,
      word: map['EngWordName']?.toString() ?? '',
      meaning: map['TurWordName']?.toString() ?? '',
      hint:
          map['hint']?.toString() ?? '', // Hint senin DB'de küçük harf kalmıştı
      example: map['example']?.toString() ?? '',
      example_tr: map['example_tr']?.toString() ?? '',
      level: map['Level']?.toString() ?? '',
      asama: map['Asama'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'WordID': id,
      'EngWordName': word,
      'TurWordName': meaning,
      'hint': hint,
      'example': example,
      'example_tr': example_tr,
      'Level': level,
      'Asama': asama,
    };
  }
}
