import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:convert';
import 'dart:ui'; // Glassmorphism efekti için gerekli
import '../data/db_helper.dart';
import '../constants/constants.dart';

class IstatistikSekmesi extends StatelessWidget {
  const IstatistikSekmesi({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return FutureBuilder<Map<String, dynamic>>(
      future: _getTumVeriler(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(
            child: CircularProgressIndicator(color: kAccentCopper),
          );
        }

        final data = snapshot.data!['genel'];
        final List<Map<String, dynamic>> sonSinavlar =
            snapshot.data!['sonSinavlar'];
        final Map<int, int> alistirmaDagilimi =
            snapshot.data!['alistirmaDagilimi'];

        int total = data['toplam'] ?? 0;
        int totalCorrect = data['total_correct'] ?? 0;
        int totalWrong = data['total_wrong'] ?? 0;
        double accuracy = (totalCorrect + totalWrong) > 0
            ? (totalCorrect / (totalCorrect + totalWrong)) * 100
            : 0;

        return Scaffold(
          backgroundColor: Colors.transparent,
          body: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 25),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 50),
                _buildHeader(),
                const SizedBox(height: 30),

                // ANA İSTATİSTİK KARTI
                _buildMainStatCard(total, isDark),
                const SizedBox(height: 20),

                // ÖZET PANELİ (Doğru/Yanlış/Başarı)
                _buildSinavOzet(
                  context,
                  totalCorrect,
                  totalWrong,
                  accuracy,
                  isDark,
                ),
                const SizedBox(height: 30),

                // AŞAMA DETAYLARI (Expandable)
                _buildExpandableStages(
                  context,
                  data['asama_dagilimi'],
                  alistirmaDagilimi,
                  total,
                  isDark,
                ),
                const SizedBox(height: 35),

                _sectionTitle("SON 5 SINAV ANALİZİ", isDark),
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

                const SizedBox(height: 100), // Alt kısım ferah kalsın
              ],
            ),
          ),
        );
      },
    );
  }

  // --- UI BİLEŞENLERİ ---

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "GELİŞİMİN",
          style: GoogleFonts.montserrat(
            fontSize: 32,
            fontWeight: FontWeight.w900,
            color: kAccentCopper,
            letterSpacing: 1.5,
          ),
        ),
        Container(
          height: 4,
          width: 60,
          decoration: BoxDecoration(
            color: kAccentCopper,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
      ],
    );
  }

  Widget _buildMainStatCard(int total, bool isDark) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [kAccentCopper, kAccentCopper.withOpacity(0.7)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: kAccentCopper.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 30,
            backgroundColor: Colors.white24,
            child: Icon(Icons.library_books, color: Colors.white, size: 30),
          ),
          const SizedBox(width: 20),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Kütüphanedeki Kelime",
                style: TextStyle(color: Colors.white70, fontSize: 14),
              ),
              Text(
                "$total",
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 35,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSinavOzet(
    BuildContext context,
    int d,
    int y,
    double acc,
    bool isDark,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withOpacity(0.05)
            : Colors.black.withOpacity(0.03),
        borderRadius: BorderRadius.circular(25),
        border: Border.all(color: isDark ? Colors.white10 : Colors.black12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildMiniStat("DOĞRU", "$d", Colors.greenAccent),
          _buildVerticalDivider(isDark),
          _buildMiniStat("YANLIŞ", "$y", Colors.redAccent),
          _buildVerticalDivider(isDark),
          _buildMiniStat(
            "BAŞARI",
            "%${acc.toStringAsFixed(1)}",
            Colors.cyanAccent,
          ),
        ],
      ),
    );
  }

  Widget _buildVerticalDivider(bool isDark) {
    return Container(
      height: 30,
      width: 1,
      color: isDark ? Colors.white10 : Colors.black12,
    );
  }

  Widget _buildMiniStat(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.grey,
            fontSize: 10,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            color: color,
            fontSize: 20,
            fontWeight: FontWeight.w900,
          ),
        ),
      ],
    );
  }

  Widget _sectionTitle(String title, bool isDark) {
    return Text(
      title,
      style: TextStyle(
        color: isDark ? Colors.white38 : Colors.black38,
        fontWeight: FontWeight.w800,
        letterSpacing: 1.2,
        fontSize: 12,
      ),
    );
  }

  Widget _buildNoDataMessage() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 40),
        child: Text(
          "Henüz sınav yapılmadı,kendini test et!",
          style: TextStyle(color: Colors.grey, fontStyle: FontStyle.italic),
        ),
      ),
    );
  }

  Widget _buildExpandableStages(
    BuildContext context,
    Map<dynamic, dynamic> sinavDagilim,
    Map<int, int> alistirmaDagilim,
    int total,
    bool isDark,
  ) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(25),
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          border: Border.all(color: isDark ? Colors.white10 : Colors.black12),
          borderRadius: BorderRadius.circular(25),
        ),
        child: ExpansionTile(
          backgroundColor: Colors.transparent,
          collapsedBackgroundColor: Colors.transparent,
          leading: const Icon(Icons.analytics_outlined, color: kAccentCopper),
          title: const Text(
            "AŞAMA DETAYLARI",
            style: TextStyle(fontWeight: FontWeight.w900, fontSize: 13),
          ),
          subtitle: const Text(
            "Alıştırma vs Sınav Kıyası",
            style: TextStyle(fontSize: 11, color: Colors.grey),
          ),
          childrenPadding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
          iconColor: kAccentCopper,
          shape: const RoundedRectangleBorder(side: BorderSide.none),
          children: [
            const Divider(height: 1),
            const SizedBox(height: 20),
            Row(
              children: [
                const Expanded(flex: 2, child: SizedBox()),
                _headerLabel("ALIŞTIRMA", Colors.blueAccent),
                _headerLabel(
                  "SINAV",
                  Colors.greenAccent,
                  textAlign: TextAlign.end,
                ),
              ],
            ),
            const SizedBox(height: 15),
            for (int i = 0; i <= 6; i++)
              _buildComparisonRow(
                i,
                alistirmaDagilim[i] ?? 0,
                (sinavDagilim[i] ?? 0) as int,
                total,
                isDark,
              ),
          ],
        ),
      ),
    );
  }

  Widget _headerLabel(
    String label,
    Color color, {
    TextAlign textAlign = TextAlign.start,
  }) {
    return Expanded(
      child: Text(
        label,
        textAlign: textAlign,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w900,
          color: color,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildComparisonRow(
    int stage,
    int aCount,
    int sCount,
    int total,
    bool isDark,
  ) {
    double aVal = total > 0 ? aCount / total : 0;
    double sVal = total > 0 ? sCount / total : 0;

    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                stage == 0 ? "Yeni" : "$stage. Aşama",
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Row(
                children: [
                  Text(
                    "$aCount",
                    style: const TextStyle(
                      color: Colors.blueAccent,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Text(" / ", style: TextStyle(color: Colors.grey)),
                  Text(
                    "$sCount",
                    style: const TextStyle(
                      color: Colors.greenAccent,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(5),
            child: Stack(
              children: [
                LinearProgressIndicator(
                  value: aVal,
                  backgroundColor: isDark ? Colors.white10 : Colors.black12,
                  color: Colors.blueAccent.withOpacity(0.3),
                  minHeight: 6,
                ),
                LinearProgressIndicator(
                  value: sVal,
                  backgroundColor: Colors.transparent,
                  color: Colors.greenAccent,
                  minHeight: 6,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSinavAnalizCard(
    BuildContext context,
    Map<String, dynamic> sinav,
    bool isDark,
  ) {
    int dogru = sinav['correct'] ?? 0;
    int yanlis = sinav['wrong'] ?? 0;
    String seviye = sinav['level'] ?? "-";
    String tarih = sinav['date'].toString().split('T')[0];
    List<dynamic> wrongWords = sinav['wrong_words'] != null
        ? jsonDecode(sinav['wrong_words'])
        : [];

    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: isDark ? Colors.white10 : Colors.black12),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          leading: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: kAccentCopper.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              seviye,
              style: const TextStyle(
                color: kAccentCopper,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          title: Text(
            "Doğru: $dogru  |  Yanlış: $yanlis",
            style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13),
          ),
          subtitle: Text(
            tarih,
            style: const TextStyle(fontSize: 11, color: Colors.grey),
          ),
          trailing: Icon(
            dogru >= yanlis ? Icons.check_circle_outline : Icons.error_outline,
            color: dogru >= yanlis ? Colors.greenAccent : Colors.redAccent,
          ),
          children: [
            if (wrongWords.isNotEmpty) ...[
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Divider(height: 1),
              ),
              ...wrongWords.map(
                (w) => ListTile(
                  dense: true,
                  leading: const Icon(
                    Icons.close,
                    color: Colors.redAccent,
                    size: 14,
                  ),
                  title: Text(
                    w['word'] ?? "",
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    w['meaning'] ?? "",
                    style: const TextStyle(fontSize: 12),
                  ),
                ),
              ),
            ] else
              const Padding(
                padding: EdgeInsets.all(15),
                child: Text(
                  "Hatasız sınav, Tebrikler!",
                  style: TextStyle(color: Colors.greenAccent, fontSize: 12),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // --- VERİ ÇEKME METODU ---
  Future<Map<String, dynamic>> _getTumVeriler() async {
    final db = DbHelper();
    final genel = await db.getGenelIstatistikler();
    final sonSinavlar = await db.getLastFiveQuizzes();
    final database = await db.database;
    List<Map<String, dynamic>> res = await database.rawQuery(
      'SELECT asama_alistirma, COUNT(*) as adet FROM Kelimeler GROUP BY asama_alistirma',
    );
    Map<int, int> aDagilim = {for (int i = 0; i <= 6; i++) i: 0};
    for (var row in res) {
      aDagilim[row['asama_alistirma'] as int] = row['adet'] as int;
    }
    return {
      'genel': genel,
      'sonSinavlar': sonSinavlar,
      'alistirmaDagilimi': aDagilim,
    };
  }
}
