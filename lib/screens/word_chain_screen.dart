import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart'
    as http; // Aga bunu kullanabilmek için terminale 'flutter pub add http' yazmış olman lazım

class WordChainScreen extends StatefulWidget {
  const WordChainScreen({super.key});

  @override
  State<WordChainScreen> createState() => _WordChainScreenState();
}

class _WordChainScreenState extends State<WordChainScreen> {
  final List<TextEditingController> _controllers = List.generate(
    5,
    (i) => TextEditingController(),
  );
  bool yukleniyor = false;
  String? olusanHikaye;
  String? gorselUrl;

  // AGA: Senin aldığın taze token burada!
  final String _hfToken = "token";

  Future<void> _hikayeSentezle() async {
    List<String> kelimeler = _controllers
        .map((c) => c.text.trim())
        .where((k) => k.isNotEmpty)
        .toList();

    if (kelimeler.length < 5) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Aga 5 kelimeyi de girmen lazım!")),
      );
      return;
    }

    setState(() {
      yukleniyor = true;
      olusanHikaye = null;
      gorselUrl = null;
    });

    try {
      final response = await http
          .post(
            Uri.parse(
              "https://api-inference.huggingface.co/models/mistralai/Mistral-7B-Instruct-v0.3",
            ),
            headers: {
              "Authorization": "Bearer $_hfToken",
              "Content-Type": "application/json",
            },
            body: jsonEncode({
              "inputs":
                  "Write a short 3-sentence English story using: ${kelimeler.join(', ')}. Then translate to Turkish.",
              "parameters": {"max_new_tokens": 300},
            }),
          )
          .timeout(const Duration(seconds: 20)); // VAKİT AŞIMI EKLEDİK

      print("Status Code: ${response.statusCode}"); // LOGLARA BAKMAK İÇİN
      print("Response Body: ${response.body}");

      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes));
        setState(() {
          olusanHikaye = data[0]['generated_text'];
          gorselUrl =
              "https://pollinations.ai/p/${kelimeler.join('_')}?width=600&height=400&model=flux";
          yukleniyor = false;
        });
      } else {
        // BURASI ÖNEMLİ: HATA KODUNU GÖRELİM
        setState(() => yukleniyor = false);
        _hataMesajiGoster(
          "Sunucu Hatası (${response.statusCode}): ${response.body}",
        );
      }
    } catch (e) {
      setState(() => yukleniyor = false);
      _hataMesajiGoster(
        "Kod Hatası: $e",
      ); // "Bağlantı patladı" yerine gerçek hatayı yazdır
    }
  }

  void _hataMesajiGoster(String hata) {
    showDialog(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text("Hata"),
        content: Text(hata),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("TAMAM"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(
        0xFF0A0E21,
      ), // kDeepNavy yerine direkt renk kodu koydum hata vermesin diye
      appBar: AppBar(
        title: const Text(
          "WORD CHAIN AI",
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            ...List.generate(5, (index) => _kelimeInput(index)),
            const SizedBox(height: 25),
            if (!yukleniyor)
              _sentezleButonu()
            else
              const CircularProgressIndicator(color: Colors.cyanAccent),
            if (olusanHikaye != null) _buildHikayeSonuc(),
          ],
        ),
      ),
    );
  }

  Widget _kelimeInput(int index) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 6),
    child: TextField(
      controller: _controllers[index],
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        hintText: "${index + 1}. Kelime",
        hintStyle: const TextStyle(color: Colors.white24),
        filled: true,
        fillColor: Colors.white.withOpacity(0.05),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
    ),
  );

  Widget _sentezleButonu() => SizedBox(
    width: double.infinity,
    height: 55,
    child: ElevatedButton(
      style: ElevatedButton.styleFrom(backgroundColor: Colors.cyanAccent),
      onPressed: _hikayeSentezle,
      child: const Text(
        "HİKAYEYİ OLUŞTUR",
        style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
      ),
    ),
  );

  Widget _buildHikayeSonuc() => Container(
    margin: const EdgeInsets.only(top: 30),
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      color: Colors.white.withOpacity(0.08),
      borderRadius: BorderRadius.circular(20),
    ),
    child: Column(
      children: [
        if (gorselUrl != null)
          ClipRRect(
            borderRadius: BorderRadius.circular(15),
            child: Image.network(gorselUrl!),
          ),
        const SizedBox(height: 20),
        Text(
          olusanHikaye ?? "",
          style: const TextStyle(color: Colors.white, fontSize: 15),
        ),
      ],
    ),
  );
}
