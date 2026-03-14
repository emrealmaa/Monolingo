import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter_tts/flutter_tts.dart'; // AGA: Sesli okuma için şart
import '../models/quiz_settings.dart';
import '../data/db_helper.dart';

class QuizScreen extends StatefulWidget {
  final QuizSettings settings;
  const QuizScreen({super.key, required this.settings});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  int currentQuestionIndex = 0;
  int correctAnswers = 0;
  int wrongAnswers = 0;
  List<Map<String, dynamic>> questions = [];
  bool isLoading = true;
  Timer? _timer;
  int _remainingTime = 0;
  List<int?> userAnswers = [];

  // AGA: Ses motoru tanımlandı
  final FlutterTts _flutterTts = FlutterTts();

  List<Map<String, String>> yanlisKelimeler = [];

  @override
  void initState() {
    super.initState();
    _initQuiz();
  }

  // AGA: Seslendirme fonksiyonu (İskeleti bozmadan araya eklendi)
  Future<void> _speak(String text) async {
    await _flutterTts.setLanguage("en-US");
    await _flutterTts.setPitch(1.0);
    await _flutterTts.setSpeechRate(0.5); // Hızı orta şeker
    await _flutterTts.speak(text);
  }

  Future<void> _initQuiz() async {
    final dbData = await DbHelper().getQuestionsForQuiz(widget.settings.level);

    if (dbData.isEmpty) {
      if (mounted) {
        _showErrorMessage("Bu seviyede yeterli kelime yok !");
      }
      return;
    }

    setState(() {
      questions = (dbData..shuffle())
          .take(widget.settings.questionCount)
          .toList();
      userAnswers = List.filled(questions.length, null);
      isLoading = false;
      if (widget.settings.isTimed) {
        _remainingTime = widget.settings.duration;
        _startTimer();
      }
    });

    // AGA: İlk soru yüklenince oku
    if (questions.isNotEmpty) {
      _speak(questions[0]['question']);
    }
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingTime > 0) {
        if (mounted) setState(() => _remainingTime--);
      } else {
        _timer?.cancel();
        _finishQuiz();
      }
    });
  }

  void _answerQuestion(int optionIndex) {
    if (userAnswers[currentQuestionIndex] != null) return;

    setState(() {
      userAnswers[currentQuestionIndex] = optionIndex;

      if (optionIndex != -1) {
        String dogruCevap = questions[currentQuestionIndex]['correct'];
        String secilenCevap =
            questions[currentQuestionIndex]['options'][optionIndex];

        if (secilenCevap == dogruCevap) {
          correctAnswers++;
        } else {
          wrongAnswers++;
          yanlisKelimeler.add({
            'word': questions[currentQuestionIndex]['question'],
            'meaning': dogruCevap,
          });
        }
      }
    });

    int delay = widget.settings.showFeedback ? 1000 : 50;

    if (currentQuestionIndex < questions.length - 1) {
      Future.delayed(Duration(milliseconds: delay), () {
        if (mounted) {
          setState(() => currentQuestionIndex++);
          // AGA: Soru değişince yeni kelimeyi oku
          _speak(questions[currentQuestionIndex]['question']);
        }
      });
    } else {
      Future.delayed(Duration(milliseconds: delay), () => _finishQuiz());
    }
  }

  Future<void> _finishQuiz() async {
    _timer?.cancel();

    await DbHelper().saveQuizResult(
      widget.settings.level,
      correctAnswers,
      wrongAnswers,
      yanlisKelimeler,
    );

    for (int i = 0; i < questions.length; i++) {
      int? answerIndex = userAnswers[i];
      int wordId = questions[i]['id'];
      int mevcutAsama = questions[i]['asama'] ?? 0;

      if (answerIndex != null && answerIndex != -1) {
        String dogruCevap = questions[i]['correct'];
        String secilenCevap = questions[i]['options'][answerIndex];

        if (secilenCevap == dogruCevap) {
          await DbHelper().kelimeAsamaGuncelle(wordId, mevcutAsama + 1);
        } else {
          await DbHelper().kelimeAsamaGuncelle(wordId, 1);
        }
      } else {
        await DbHelper().kelimeAsamaGuncelle(wordId, 1);
      }
    }

    if (!mounted) return;
    _showResultDialog();
  }

  // --- UI METODLARI (DEĞİŞMEDİ) ---

  void _showResultDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (c) => AlertDialog(
        backgroundColor: const Color(0xFF1D1E33),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          "SINAV ANALİZİ",
          style: TextStyle(
            color: Colors.cyanAccent,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _resultRow("Doğru Sayısı", "$correctAnswers", Colors.greenAccent),
            _resultRow("Yanlış Sayısı", "$wrongAnswers", Colors.redAccent),
            _resultRow(
              "Boş Bırakılan",
              "${questions.length - (correctAnswers + wrongAnswers)}",
              Colors.white54,
            ),
            const Divider(color: Colors.white10, height: 30),
            Text(
              "Başarı Oranı: %${((correctAnswers / questions.length) * 100).toStringAsFixed(1)}",
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        actions: [
          Center(
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.cyanAccent,
                minimumSize: const Size(200, 50),
              ),
              onPressed: () {
                Navigator.pop(context);
                Navigator.pop(context);
              },
              child: const Text(
                "ANA SAYFAYA DÖN",
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }

  Widget _buildOptionButton(int index) {
    var currentQ = questions[currentQuestionIndex];
    int? selectedIndex = userAnswers[currentQuestionIndex];
    bool isAnswered = selectedIndex != null;

    Color btnColor = Colors.white.withOpacity(0.05);
    Color borderColor = Colors.white10;

    if (isAnswered) {
      if (widget.settings.showFeedback) {
        bool isCorrect = currentQ['options'][index] == currentQ['correct'];
        bool isSelected = selectedIndex == index;
        if (isCorrect) {
          btnColor = Colors.green.withOpacity(0.2);
          borderColor = Colors.greenAccent;
        } else if (isSelected) {
          btnColor = Colors.red.withOpacity(0.2);
          borderColor = Colors.redAccent;
        }
      } else if (selectedIndex == index) {
        btnColor = Colors.cyanAccent.withOpacity(0.1);
        borderColor = Colors.cyanAccent;
      }
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 20),
          backgroundColor: btnColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
            side: BorderSide(color: borderColor, width: isAnswered ? 2.5 : 1),
          ),
        ),
        onPressed: () => _answerQuestion(index),
        child: Row(
          children: [
            const SizedBox(width: 20),
            CircleAvatar(
              radius: 16,
              backgroundColor: isAnswered ? borderColor : Colors.white12,
              child: Text(
                String.fromCharCode(65 + index),
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Text(
                currentQ['options'][index],
                style: const TextStyle(color: Colors.white, fontSize: 17),
              ),
            ),
            if (widget.settings.showFeedback &&
                isAnswered &&
                currentQ['options'][index] == currentQ['correct'])
              const Icon(Icons.check_circle, color: Colors.greenAccent),
            if (widget.settings.showFeedback &&
                isAnswered &&
                selectedIndex == index &&
                currentQ['options'][index] != currentQ['correct'])
              const Icon(Icons.cancel, color: Colors.redAccent),
            const SizedBox(width: 15),
          ],
        ),
      ),
    );
  }

  Widget _resultRow(String label, String value, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(color: Colors.white70, fontSize: 15),
          ),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
        ],
      ),
    );
  }

  void _showErrorMessage(String msg) {
    showDialog(
      context: context,
      builder: (c) => AlertDialog(
        backgroundColor: const Color(0xFF1D1E33),
        content: Text(msg, style: const TextStyle(color: Colors.white)),
        actions: [
          TextButton(
            onPressed: () => {Navigator.pop(c), Navigator.pop(context)},
            child: const Text(
              "TAMAM",
              style: TextStyle(color: Colors.cyanAccent),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    _flutterTts.stop(); // AGA: Ekran kapanınca ses de sussun
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        backgroundColor: Color(0xFF0A0E21),
        body: Center(
          child: CircularProgressIndicator(color: Colors.cyanAccent),
        ),
      );
    }

    var currentQ = questions[currentQuestionIndex];

    return Scaffold(
      backgroundColor: const Color(0xFF0A0E21),
      appBar: AppBar(
        title: Text(
          "${widget.settings.level} Seviye Sınavı",
          style: const TextStyle(fontSize: 18),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          if (widget.settings.isTimed)
            Container(
              margin: const EdgeInsets.all(10),
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: _remainingTime < 10
                    ? Colors.red.withOpacity(0.2)
                    : Colors.white10,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: _remainingTime < 10 ? Colors.red : Colors.white24,
                ),
              ),
              child: Center(
                child: Text(
                  "⏱️ $_remainingTime",
                  style: TextStyle(
                    color: _remainingTime < 10
                        ? Colors.red
                        : Colors.orangeAccent,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
        ],
      ),
      body: Column(
        children: [
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: LinearProgressIndicator(
              value: (currentQuestionIndex + 1) / questions.length,
              backgroundColor: Colors.white10,
              color: Colors.cyanAccent,
            ),
          ),
          const SizedBox(height: 30),
          Text(
            "SORU ${currentQuestionIndex + 1} / ${questions.length}",
            style: const TextStyle(
              color: Colors.white38,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 25),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30.0),
            child: Text(
              currentQ['question'],
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 40),
          Expanded(
            child: ListView.builder(
              itemCount: (currentQ['options'] as List).length,
              padding: const EdgeInsets.symmetric(horizontal: 25),
              itemBuilder: (context, index) => _buildOptionButton(index),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 40, top: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                if (widget.settings.allowSkip)
                  IconButton(
                    onPressed: currentQuestionIndex > 0
                        ? () {
                            setState(() => currentQuestionIndex--);
                            _speak(
                              questions[currentQuestionIndex]['question'],
                            ); // Geri gelince de oku
                          }
                        : null,
                    icon: const Icon(
                      Icons.arrow_back_ios_new,
                      color: Colors.white24,
                    ),
                  ),
                GestureDetector(
                  onTap: () => _answerQuestion(-1),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 40,
                      vertical: 15,
                    ),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Colors.orangeAccent.withOpacity(0.5),
                      ),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: const Text(
                      "BOŞ BIRAK",
                      style: TextStyle(
                        color: Colors.orangeAccent,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                if (widget.settings.allowSkip)
                  IconButton(
                    onPressed: currentQuestionIndex < questions.length - 1
                        ? () {
                            setState(() => currentQuestionIndex++);
                            _speak(
                              questions[currentQuestionIndex]['question'],
                            ); // İleri gidince oku
                          }
                        : null,
                    icon: const Icon(
                      Icons.arrow_forward_ios,
                      color: Colors.white24,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
