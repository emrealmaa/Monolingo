import 'dart:math';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:google_fonts/google_fonts.dart';
import '../constants/constants.dart';

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
  String? hikayeEN, hikayeTR, gorselUrl;

  Future<void> _aiDongusu() async {
    List<String> kelimeler = _controllers
        .map((c) => c.text.trim())
        .where((k) => k.isNotEmpty)
        .toList();

    if (kelimeler.length < 2) {
      _mesajGoster("En az 2 kelime girmen lazım aga!");
      return;
    }

    setState(() {
      yukleniyor = true;
      hikayeEN = null;
      hikayeTR = null;
      gorselUrl = null;
    });

    try {
      // 1. ADIM: METİN MOTORU
      final pMetin = Uri.encodeComponent(
        "Generate a 2-sentence story using: ${kelimeler.join(', ')}. "
        "Format: English: [story] Turkish: [translation]. No JSON, no extra text.",
      );

      final res = await http
          .get(
            Uri.parse(
              "https://text.pollinations.ai/$pMetin?model=openai&cache=false",
            ),
          )
          .timeout(const Duration(seconds: 25));

      if (res.statusCode == 200) {
        String raw = utf8.decode(res.bodyBytes);

        // DeepSeek ve JSON temizleme
        raw = raw.replaceAll(RegExp(r'<think>[\s\S]*?<\/think>'), '').trim();
        if (raw.contains('"content":')) {
          try {
            raw = jsonDecode(raw)['content'] ?? raw;
          } catch (e) {}
        }

        var parts = raw.split(
          RegExp(r'Turkish:|Türkçe:', caseSensitive: false),
        );
        String tempEN = parts[0]
            .replaceAll(RegExp(r'English:', caseSensitive: false), "")
            .split('}')
            .last
            .trim();
        String tempTR = parts.length > 1
            ? parts[1].trim()
            : "Çeviri yapılamadı.";

        // 2. ADIM: GÖRSEL MOTORU (İSABETLİ)
        String objects = kelimeler.join(' and ');
        String dynamicPrompt =
            "A masterpiece cinematic wide shot of $objects together in one highly detailed environment, "
            "vibrant colors, sharp focus, 8k resolution, digital art style, unreal engine 5.";

        int randomSeed = Random().nextInt(5000000);
        String timestamp = DateTime.now().millisecondsSinceEpoch.toString();

        // ANA PLAN: Pollinations (Zenginleştirilmiş Prompt)
        String primaryUrl =
            "https://image.pollinations.ai/prompt/${Uri.encodeComponent(dynamicPrompt)}?width=1024&height=768&seed=$randomSeed&nologo=true&model=flux&t=$timestamp";

        setState(() {
          hikayeEN = tempEN;
          hikayeTR = tempTR;
          gorselUrl = primaryUrl;
          yukleniyor = false;
        });
      }
    } catch (e) {
      // AGA: Eğer 25 saniye içinde cevap gelmezse (Timeout) burası çalışır
      setState(() => yukleniyor = false);
      _mesajGoster("AI sunucusu uykuda, tekrar dene!");
    }
  }

  void _mesajGoster(String m) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(m),
        backgroundColor: kAccentCopper,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kDeepNavy,
      appBar: AppBar(
        title: Text(
          "MONOLINGO AI",
          style: GoogleFonts.montserrat(
            fontWeight: FontWeight.w900,
            color: kAccentCopper,
          ),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(25),
        child: Column(
          children: [
            ...List.generate(
              5,
              (i) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: TextField(
                  controller: _controllers[i],
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: "Kelime ${i + 1}",
                    hintStyle: const TextStyle(color: Colors.white24),
                    filled: true,
                    fillColor: Colors.white10,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 25),
            if (yukleniyor)
              const Column(
                children: [
                  CircularProgressIndicator(color: kAccentCopper),
                  SizedBox(height: 10),
                  Text(
                    "AI dünyayı çiziyor...",
                    style: TextStyle(color: Colors.white54, fontSize: 12),
                  ),
                ],
              )
            else
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kAccentCopper,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  onPressed: _aiDongusu,
                  child: const Text(
                    "HİKAYEYİ VE GÖRSELİ PATLAT",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            if (hikayeEN != null) ...[
              const SizedBox(height: 35),
              if (gorselUrl != null)
                ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Image.network(
                    gorselUrl!,
                    key: ValueKey(gorselUrl),
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, progress) {
                      if (progress == null) return child;
                      // Resim sunucudan gelene kadar % değerini takip etmez (Pollinations desteklemez),
                      // o yüzden loading çarkı döner.
                      return Container(
                        height: 250,
                        width: double.infinity,
                        color: Colors.white10,
                        child: const Center(
                          child: CircularProgressIndicator(
                            color: kAccentCopper,
                          ),
                        ),
                      );
                    },
                    errorBuilder: (context, error, stackTrace) {
                      // AGA: Pollinations resmi "Internal Server Error" verirse veya yüklenemezse
                      // anında LoremFlickr üzerinden girdiğin ilk kelimeyle alakalı bir fotoğraf getirir.
                      String ilkKelime = _controllers[0].text.trim().isEmpty
                          ? "nature"
                          : _controllers[0].text.trim();
                      return Image.network(
                        "https://loremflickr.com/1080/720/$ilkKelime",
                        fit: BoxFit.cover,
                        height: 250,
                        width: double.infinity,
                      );
                    },
                  ),
                ),
              const SizedBox(height: 20),
              _buildBox("English Story", hikayeEN!),
              _buildBox("Türkçe Çeviri", hikayeTR!),
              const SizedBox(height: 100),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildBox(String t, String c) {
    return Container(
      margin: const EdgeInsets.only(top: 15),
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            t,
            style: const TextStyle(
              fontWeight: FontWeight.w900,
              color: kDeepNavy,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            c,
            style: const TextStyle(
              color: Colors.black87,
              fontSize: 16,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}
