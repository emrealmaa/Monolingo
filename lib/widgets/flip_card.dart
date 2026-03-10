import 'dart:math';
import 'package:flutter/material.dart';
import '../constants.dart';
import '../models/word_model.dart';

class FlipCardWidget extends StatefulWidget {
  final WordModel word;
  const FlipCardWidget({super.key, required this.word});

  @override
  State<FlipCardWidget> createState() => _FlipCardWidgetState();
}

class _FlipCardWidgetState extends State<FlipCardWidget> {
  bool _showFront = true; // Kartın ön yüzü mü açık?

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => setState(() => _showFront = !_showFront),
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 600),
        transitionBuilder: (Widget child, Animation<double> animation) {
          // Kartın dönme animasyonu (Y ekseninde 180 derece)
          final rotate = Tween(begin: pi, end: 0.0).animate(animation);
          return AnimatedBuilder(
            animation: rotate,
            child: child,
            builder: (context, child) {
              final isUnder = (ValueKey(_showFront) != child!.key);
              var tilt = ((animation.value - 0.5).abs() - 0.5) * 0.003;
              tilt *= isUnder ? -1.0 : 1.0;
              final value = isUnder ? min(rotate.value, pi / 2) : rotate.value;
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
    );
  }

  // --- KARTIN ÖN YÜZÜ (Kelime ve Anlamı) ---
  Widget _buildFront() {
    return Container(
      key: const ValueKey(true),
      height: 300,
      width: double.infinity,
      decoration: BoxDecoration(
        color: kAccentCopper,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
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
          Text(
            "Kelimemiz:",
            style: TextStyle(color: Colors.white70, fontSize: 16),
          ),
          const SizedBox(height: 10),
          Text(
            widget.word.word,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 40,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          const Icon(Icons.touch_app, color: Colors.white54, size: 30),
          const Text(
            "Çevirmek için tıkla",
            style: TextStyle(color: Colors.white54, fontSize: 12),
          ),
        ],
      ),
    );
  }

  // --- KARTIN ARKA YÜZÜ (Örnek ve İpucu) ---
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
                fontSize: 24,
                color: kDeepNavy,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Divider(height: 30),
            const Text(
              "Örnek Cümle:",
              style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold),
            ),
            Text(
              widget.word.example ?? "Örnek eklenmemiş.",
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16, fontStyle: FontStyle.italic),
            ),
            const SizedBox(height: 15),
            if (widget.word.hint != null)
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.amber.shade100,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  "💡 İpucu: ${widget.word.hint}",
                  style: const TextStyle(color: Colors.black87),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
