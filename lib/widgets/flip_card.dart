import 'dart:math';
import 'package:flutter/material.dart';
import '../constants/constants.dart';
import '../models/word_model.dart';

class FlipCardWidget extends StatefulWidget {
  final WordModel word;
  const FlipCardWidget({super.key, required this.word});

  @override
  State<FlipCardWidget> createState() => _FlipCardWidgetState();
}

class _FlipCardWidgetState extends State<FlipCardWidget> {
  bool _showFront = true;
  bool _hintVisible = false; // Ampul için kontrol değişkeni

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        GestureDetector(
          onTap: () {
            setState(() {
              _showFront = !_showFront;
              _hintVisible = false; // Kart dönünce ipucunu kapat aga
            });
          },
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 600),
            transitionBuilder: (Widget child, Animation<double> animation) {
              final rotate = Tween(begin: pi, end: 0.0).animate(animation);
              return AnimatedBuilder(
                animation: rotate,
                child: child,
                builder: (context, child) {
                  final isUnder = (ValueKey(_showFront) != child!.key);
                  var tilt = ((animation.value - 0.5).abs() - 0.5) * 0.003;
                  tilt *= isUnder ? -1.0 : 1.0;
                  final value = isUnder
                      ? min(rotate.value, pi / 2)
                      : rotate.value;
                  return Transform(
                    transform: Matrix4.rotationY(value)..setEntry(3, 0, tilt),
                    alignment: Alignment.center,
                    child: child,
                  );
                },
              );
            },
            child: _showFront ? _buildFront() : _buildBack(),
          ),
        ),

        const SizedBox(height: 25),

        // --- KARTIN ALTINDAKİ AMPUL VE İPUCU ---
        if (_showFront)
          Column(
            children: [
              IconButton(
                icon: Icon(
                  Icons.lightbulb,
                  color: _hintVisible ? Colors.amber : Colors.grey.shade400,
                  size: 45,
                ),
                onPressed: () {
                  setState(() => _hintVisible = !_hintVisible);
                },
              ),
              const SizedBox(height: 10),
              // Animasyonlu ipucu gösterimi (şak diye çıkmasın)
              AnimatedOpacity(
                duration: const Duration(milliseconds: 300),
                opacity: _hintVisible ? 1.0 : 0.0,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40),
                  child: Text(
                    widget.word.hint, // WordModel'deki 'hint' alanı
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.amber,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
      ],
    );
  }

  // --- ÖN YÜZ (Sadece İngilizce Kelime) ---
  Widget _buildFront() {
    return Container(
      key: const ValueKey(true),
      height: 300,
      width: double.infinity,
      decoration: BoxDecoration(
        color: kAccentCopper,
        borderRadius: BorderRadius.circular(25),
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            "Kelimemiz:",
            style: TextStyle(color: Colors.white70, fontSize: 16),
          ),
          const SizedBox(height: 10),
          Text(
            widget.word.word,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 45,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 30),
          const Icon(Icons.touch_app, color: Colors.white54, size: 30),
        ],
      ),
    );
  }

  // --- ARKA YÜZ (Anlam + İngilizce Örnek + Türkçe Örnek) ---
  Widget _buildBack() {
    return Container(
      key: const ValueKey(false),
      height: 300,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        border: Border.all(color: kAccentCopper, width: 2),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "Türkçesi:",
              style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold),
            ),
            Text(
              widget.word.meaning,
              style: const TextStyle(
                fontSize: 28,
                color: kDeepNavy,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Divider(height: 40, thickness: 1.5),
            const Text(
              "Örnek Cümle:",
              style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            // DB'den gelen İngilizce Örnek Cümle
            Text(
              widget.word.example,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 18,
                fontStyle: FontStyle.italic,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            // HATANIN ÇÖZÜMÜ BURASI AGA: 'example_tr' olarak çağırdık
            Text(
              widget.word.example_tr,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15,
                color: Colors.blueGrey.shade600,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
