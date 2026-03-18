import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:convert';
import 'dart:math';
import '../data/db_helper.dart';
import '../constants/constants.dart';

class IstatistikSekmesi extends StatelessWidget {
  const IstatistikSekmesi({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return FutureBuilder<Map<String, dynamic>>(
      future: _getTumAnalizler(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(color: kAccentCopper),
          );
        }

        if (!snapshot.hasData || snapshot.data == null) {
          return const Center(child: Text("Veriler yüklenemedi."));
        }

        final data = snapshot.data!;

        // AGA: Dolu günlerin listesini alıp toplam kaç gün basarılı olduğumuzu sayıyoruz
        final List<String> doluGunler = List<String>.from(
          data['doluGunler'] ?? [],
        );
        final int toplamBasariGunu = doluGunler.length;

        final Map<String, double> seviyeBasarilari = data['seviyeBasarilari'];
        final Map<int, List<int>> ciftAsamaVerisi = data['ciftAsamaVerisi'];
        final int gercektenOgrenilen = data['gercektenOgrenilen'];
        final int totalWords = data['toplam'];
        final List<Map<String, dynamic>> sonSinavlar =
            data['sonSinavlar'] ?? [];

        // Genel Sınav Başarı Verileri
        int tCorrect = data['total_correct'] ?? 0;
        int tWrong = data['total_wrong'] ?? 0;
        double accuracy = (tCorrect + tWrong) > 0
            ? (tCorrect / (tCorrect + tWrong)) * 100
            : 0;

        return Scaffold(
          backgroundColor: Colors.transparent,
          body: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 25),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 60),

                // AGA: İSTEDİĞİN GELİŞİMİM YAZISI VE BOŞLUK
                Text(
                  "GELİŞİMİM",
                  style: GoogleFonts.montserrat(
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                    color: isDark ? Colors.white : kDeepNavy,
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: 30),

                // 1. GÜNCELLENDİ: 1-100 ARASI GİZLİ YOL HARİTASI (ZİNCİR)
                _buildExpandableZincir(toplamBasariGunu, isDark),
                const SizedBox(height: 30),

                // 2. ANA ÖĞRENME KARTI (GERÇEK İLERLEME)
                _buildMainStatCard(totalWords, gercektenOgrenilen, isDark),
                const SizedBox(height: 30),

                // 3. SEVİYE BAZLI SÜTUN GRAFİĞİ
                _sectionTitle("SEVİYE BAZLI BAŞARI (%)", isDark),
                const SizedBox(height: 15),
                _buildLevelBarChart(seviyeBasarilari, isDark),
                const SizedBox(height: 40),

                // 4. GENEL SINAV ÖZETİ (BAŞARI YÜZDESİ)
                _sectionTitle("GENEL SINAV PERFORMANSI", isDark),
                const SizedBox(height: 10),
                _buildSinavOzet(tCorrect, tWrong, accuracy, isDark),
                const SizedBox(height: 30),

                // 5. GÜNCELLENDİ: 6 AŞAMALI ÖĞRENME SÜZGECİ (GİZLİ PENCERE - EXPANDABLE)
                _buildExpandableStages(ciftAsamaVerisi, totalWords, isDark),
                const SizedBox(height: 35),

                // 6. GÜNCELLENDİ: SON SINAV ANALİZLERİ (HATALARIN GÖRÜNDÜĞÜ KARTLAR)
                _sectionTitle(
                  "SON SINAV ANALİZLERİ (Detay için dokun)",
                  isDark,
                ),
                const SizedBox(height: 15),
                if (sonSinavlar.isEmpty)
                  _buildNoDataMessage()
                else
                  ...sonSinavlar
                      .map(
                        (sinav) =>
                            _buildSinavAnalizCard(context, sinav, isDark),
                      )
                      .toList(),

                const SizedBox(height: 100),
              ],
            ),
          ),
        );
      },
    );
  }

  // --- AGA: İSTEDİĞİN 1-100 ARASI YOL HARİTASI (ZİNCİRİ KIRMA) ---
  Widget _buildExpandableZincir(int basariGunu, bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withOpacity(0.05) : Colors.white,
        borderRadius: BorderRadius.circular(25),
        border: Border.all(
          color: isDark ? Colors.white10 : Colors.black.withOpacity(0.05),
        ),
      ),
      child: ExpansionTile(
        shape: const RoundedRectangleBorder(side: BorderSide.none),
        iconColor: kAccentCopper,
        collapsedIconColor: Colors.grey,
        title: Text(
          "ZİNCİRİ KIRMA",
          style: GoogleFonts.montserrat(
            fontSize: 16,
            fontWeight: FontWeight.w900,
            color: kAccentCopper,
          ),
        ),
        subtitle: Text(
          "100 Günlük Hedefte $basariGunu. Adımdasın",
          style: const TextStyle(fontSize: 11, color: Colors.grey),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(15, 0, 15, 20),
            child: GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 7, // Her satırda 7 gün
                mainAxisSpacing: 15,
                crossAxisSpacing: 10,
              ),
              itemCount: 100, // Toplam 100 günlük yol
              itemBuilder: (context, index) {
                int gunNo = index + 1;
                // Toplam başarı günü bu numara ve üzerindeyse 🔥 yak
                bool doluMu = gunNo <= basariGunu;

                return Stack(
                  alignment: Alignment.center,
                  clipBehavior: Clip.none,
                  children: [
                    // Zincir Halkası (Yatay Bağlantı)
                    if (gunNo % 7 != 0)
                      Positioned(
                        right: -10,
                        child: Container(
                          width: 15,
                          height: 2,
                          color: doluMu
                              ? Colors.greenAccent.withOpacity(0.5)
                              : (isDark ? Colors.white10 : Colors.black12),
                        ),
                      ),

                    // Gün Baloncuğu
                    Container(
                      width: 35,
                      height: 35,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: doluMu
                            ? Colors.orange.withOpacity(0.2)
                            : Colors.transparent,
                        border: Border.all(
                          color: doluMu
                              ? Colors.orange
                              : (isDark ? Colors.white10 : Colors.black12),
                          width: doluMu ? 2 : 1,
                        ),
                      ),
                      child: Center(
                        child: doluMu
                            ? const Text("🔥", style: TextStyle(fontSize: 12))
                            : Text(
                                "$gunNo",
                                style: const TextStyle(
                                  fontSize: 9,
                                  color: Colors.grey,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // --- ANA ÖĞRENME KARTI ---
  Widget _buildMainStatCard(int total, int learned, bool isDark) {
    double percent = total > 0 ? learned / total : 0;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [kAccentCopper, Color(0xFFE6A088)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: kAccentCopper.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Tamamen Öğrenilen / Kütüphane",
            style: TextStyle(
              color: Colors.white70,
              fontSize: 13,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "$learned / $total",
            style: const TextStyle(
              color: Colors.white,
              fontSize: 35,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 15),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: percent,
              backgroundColor: Colors.white24,
              color: Colors.white,
              minHeight: 8,
            ),
          ),
        ],
      ),
    );
  }

  // --- SEVİYE BAZLI SÜTUN GRAFİĞİ ---
  Widget _buildLevelBarChart(Map<String, double> veriler, bool isDark) {
    return Container(
      height: 200,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? Colors.white10 : Colors.black.withOpacity(0.03),
        borderRadius: BorderRadius.circular(25),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: veriler.entries.map((e) {
          return Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                "%${e.value.toInt()}",
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                width: 35,
                height: max(5, e.value * 1.2),
                decoration: BoxDecoration(
                  color: kAccentCopper,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: kAccentCopper.withOpacity(0.2),
                      blurRadius: 4,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Text(
                e.key,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }

  // --- GİZLİ PENCERELİ (EXPANDABLE) AŞAMA TABLOSU ---
  Widget _buildExpandableStages(
    Map<int, List<int>> veriler,
    int total,
    bool isDark,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withOpacity(0.05) : Colors.white,
        borderRadius: BorderRadius.circular(25),
        border: Border.all(
          color: isDark ? Colors.white10 : Colors.black.withOpacity(0.05),
        ),
      ),
      child: ExpansionTile(
        shape: const RoundedRectangleBorder(side: BorderSide.none),
        title: Text(
          "6 AŞAMALI ÖĞRENME SÜZGECİ",
          style: TextStyle(
            fontWeight: FontWeight.w900,
            fontSize: 13,
            color: isDark ? Colors.white : Colors.black87,
          ),
        ),
        subtitle: const Text(
          "Pratik ve Sınav aşamalarını gör",
          style: TextStyle(fontSize: 10, color: Colors.grey),
        ),
        leading: const Icon(Icons.analytics_outlined, color: kAccentCopper),
        iconColor: kAccentCopper,
        collapsedIconColor: Colors.grey,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
            child: Column(
              children: List.generate(6, (index) {
                int stage = index + 1;
                List<int> counts = veriler[stage] ?? [0, 0];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 15),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "$stage. Aşama",
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 10),
                      _buildProgressBarRow(
                        "PRATİK",
                        counts[0],
                        total,
                        Colors.blueAccent,
                        isDark,
                      ),
                      const SizedBox(height: 8),
                      _buildProgressBarRow(
                        "SINAV",
                        counts[1],
                        total,
                        Colors.greenAccent,
                        isDark,
                      ),
                    ],
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressBarRow(
    String label,
    int count,
    int total,
    Color color,
    bool isDark,
  ) {
    double progress = total > 0 ? count / total : 0;
    return Row(
      children: [
        SizedBox(
          width: 50,
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 8,
              fontWeight: FontWeight.w900,
              color: Colors.grey,
            ),
          ),
        ),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: isDark ? Colors.white10 : Colors.black12,
              color: color,
              minHeight: 5,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Text(
          "$count",
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w900,
            color: color,
          ),
        ),
      ],
    );
  }

  // --- SINAV ÖZETİ ---
  Widget _buildSinavOzet(int d, int y, double acc, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withOpacity(0.05)
            : Colors.black.withOpacity(0.02),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _miniStat("TOPLAM DOĞRU", "$d", Colors.greenAccent),
          _miniStat("TOPLAM YANLIŞ", "$y", Colors.redAccent),
          _miniStat(
            "ORT. BAŞARI",
            "%${acc.toStringAsFixed(1)}",
            Colors.cyanAccent,
          ),
        ],
      ),
    );
  }

  Widget _miniStat(String l, String v, Color c) {
    return Column(
      children: [
        Text(
          l,
          style: const TextStyle(
            color: Colors.grey,
            fontSize: 9,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          v,
          style: TextStyle(color: c, fontSize: 18, fontWeight: FontWeight.w900),
        ),
      ],
    );
  }

  // --- HATALARIN GÖRÜNDÜĞÜ SINAV ANALİZ KARTI ---
  Widget _buildSinavAnalizCard(
    BuildContext context,
    Map<String, dynamic> sinav,
    bool isDark,
  ) {
    int d = sinav['correct'] ?? 0;
    int y = sinav['wrong'] ?? 0;
    String tarih = sinav['date'].toString().split('T')[0];
    String seviye = sinav['level'] ?? "-";

    List<dynamic> wrongWords = [];
    if (sinav['wrong_words'] != null) {
      try {
        wrongWords = jsonDecode(sinav['wrong_words']);
      } catch (e) {
        wrongWords = [];
      }
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withOpacity(0.05) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? Colors.white10 : Colors.black.withOpacity(0.05),
        ),
      ),
      child: ExpansionTile(
        shape: const RoundedRectangleBorder(side: BorderSide.none),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: kAccentCopper.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(Icons.history_edu, color: kAccentCopper, size: 20),
        ),
        title: Text(
          "Doğru: $d | Yanlış: $y",
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
        ),
        subtitle: Text(
          "$tarih - Seviye: $seviye",
          style: const TextStyle(fontSize: 10, color: Colors.grey),
        ),
        trailing: const Icon(Icons.keyboard_arrow_down, size: 18),
        iconColor: kAccentCopper,
        children: [
          const Divider(height: 1, indent: 20, endIndent: 20),
          if (wrongWords.isEmpty)
            const Padding(
              padding: EdgeInsets.all(15),
              child: Text(
                "Hatasız Sınav! Tebrikler 🎉",
                style: TextStyle(fontSize: 12, color: Colors.greenAccent),
              ),
            )
          else
            ...wrongWords
                .map(
                  (w) => ListTile(
                    dense: true,
                    leading: const Icon(
                      Icons.close,
                      color: Colors.redAccent,
                      size: 16,
                    ),
                    title: Text(
                      w['word'] ?? "",
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                    subtitle: Text(
                      w['meaning'] ?? "",
                      style: const TextStyle(fontSize: 11),
                    ),
                  ),
                )
                .toList(),
        ],
      ),
    );
  }

  Widget _sectionTitle(String t, bool d) => Text(
    t,
    style: TextStyle(
      color: d ? Colors.white38 : Colors.black38,
      fontWeight: FontWeight.w900,
      letterSpacing: 1.2,
      fontSize: 11,
    ),
  );

  Widget _buildNoDataMessage() => const Center(
    child: Padding(
      padding: EdgeInsets.all(20),
      child: Text(
        "Analiz edilecek sınav verisi yok.",
        style: TextStyle(color: Colors.grey, fontStyle: FontStyle.italic),
      ),
    ),
  );

  Future<Map<String, dynamic>> _getTumAnalizler() async {
    final db = DbHelper();
    return await db.getGenelIstatistikler(aktifKullaniciId ?? 0);
  }
}
