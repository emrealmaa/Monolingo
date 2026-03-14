class QuizSettings {
  String level; // A1, A2, B1...
  int duration; // Saniye cinsinden sınav süresi
  bool isTimed; // Süre aktif mi?
  bool shuffleOptions; // Şıklar karıştırılsın mı?
  bool allowSkip; // Boş bırakma/atlama izni var mı?
  int difficulty; // 1-5 arası zorluk

  // AGA: Yeni eklediğimiz özellikler burada
  int questionCount; // Sınavda sorulacak toplam soru sayısı
  bool showFeedback; // Anlık doğru/yanlış geri bildirimi gösterilsin mi?

  QuizSettings({
    this.level = 'A1',
    this.duration = 60,
    this.isTimed = true,
    this.shuffleOptions = true,
    this.allowSkip = true,
    this.difficulty = 3,
    // Yeni alanlar için default değerler
    this.questionCount = 20,
    this.showFeedback = true,
  });
}
