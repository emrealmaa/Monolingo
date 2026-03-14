import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:convert'; // AGA: JSON çözmek için şart
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

        int total = data['toplam'] ?? 0;
        int totalCorrect = data['total_correct'] ?? 0;
        int totalWrong = data['total_wrong'] ?? 0;
        double accuracy = (totalCorrect + totalWrong) > 0
            ? (totalCorrect / (totalCorrect + totalWrong)) * 100
            : 0;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(25),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 50),
              Text(
                "GELİŞİMİN",
                style: GoogleFonts.montserrat(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: kAccentCopper,
                ),
              ),
              const SizedBox(height: 30),

              _buildStatCard(
                context,
                "Kütüphanedeki Kelime",
                "$total",
                Icons.library_books,
                isDark,
              ),
              const SizedBox(height: 15),

              _buildSinavOzet(
                context,
                totalCorrect,
                totalWrong,
                accuracy,
                isDark,
              ),

              const SizedBox(height: 30),

              _buildExpandableStages(
                context,
                data['asama_dagilimi'],
                total,
                isDark,
              ),

              const SizedBox(height: 30),

              Text(
                "SON 5 SINAV ANALİZİ",
                style: TextStyle(
                  color: isDark ? Colors.white54 : Colors.black54,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 15),

              if (sonSinavlar.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 20),
                  child: Center(
                    child: Text(
                      "Henüz sınav yapılmamış aga.",
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
                )
              else
                ...sonSinavlar
                    .map(
                      (sinav) => _buildSinavAnalizCard(context, sinav, isDark),
                    )
                    .toList(),

              const SizedBox(height: 50),
            ],
          ),
        );
      },
    );
  }

  Future<Map<String, dynamic>> _getTumVeriler() async {
    final genel = await DbHelper().getGenelIstatistikler();
    final sonSinavlar = await DbHelper().getLastFiveQuizzes();
    return {'genel': genel, 'sonSinavlar': sonSinavlar};
  }

  Widget _buildExpandableStages(
    BuildContext context,
    Map<int, int> dagilim,
    int total,
    bool isDark,
  ) {
    return Theme(
      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isDark ? Colors.white10 : Colors.black12),
        ),
        child: ExpansionTile(
          title: const Text(
            "AŞAMA DETAYLARI",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
          subtitle: Text(
            "Aşamaların kelime dağılımını gör",
            style: TextStyle(
              fontSize: 11,
              color: isDark ? Colors.white38 : Colors.black38,
            ),
          ),
          leading: const Icon(Icons.bar_chart, color: kAccentCopper),
          iconColor: kAccentCopper,
          childrenPadding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
          children: [
            const Divider(height: 1),
            const SizedBox(height: 15),
            for (int i = 0; i <= 6; i++)
              _buildStageRow(i, dagilim[i] ?? 0, total, isDark),
          ],
        ),
      ),
    );
  }

  // AGA: Bu kartı ExpansionTile yaparak yanlış kelimeleri içine gömdüm
  Widget _buildSinavAnalizCard(
    BuildContext context,
    Map<String, dynamic> sinav,
    bool isDark,
  ) {
    int dogru = sinav['correct'] ?? 0;
    int yanlis = sinav['wrong'] ?? 0;
    String seviye = sinav['level'] ?? "-";
    String tarih = sinav['date'].toString().contains('T')
        ? sinav['date'].toString().split('T')[0]
        : sinav['date'].toString();

    // Yanlış kelimeleri JSON'dan listeye çeviriyoruz
    List<dynamic> wrongWords = [];
    if (sinav['wrong_words'] != null) {
      wrongWords = jsonDecode(sinav['wrong_words']);
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: isDark ? Colors.white10 : Colors.black12),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          leading: Container(
            width: 45,
            height: 45,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: kAccentCopper.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
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
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
          subtitle: Text(
            tarih,
            style: const TextStyle(fontSize: 11, color: Colors.grey),
          ),
          trailing: Icon(
            dogru >= yanlis
                ? Icons.sentiment_satisfied_alt
                : Icons.sentiment_dissatisfied,
            color: dogru >= yanlis ? Colors.greenAccent : Colors.redAccent,
          ),
          children: [
            if (wrongWords.isNotEmpty) ...[
              const Divider(color: Colors.white10, indent: 20, endIndent: 20),
              const Padding(
                padding: EdgeInsets.only(top: 10, bottom: 5),
                child: Text(
                  "Hatalı Kelimeler",
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.redAccent,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              ...wrongWords.map(
                (w) => ListTile(
                  dense: true,
                  title: Text(
                    w['word'] ?? "",
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: Text(
                    w['meaning'] ?? "",
                    style: const TextStyle(fontSize: 12),
                  ),
                  leading: const Icon(
                    Icons.close,
                    color: Colors.redAccent,
                    size: 16,
                  ),
                ),
              ),
            ] else if (yanlis > 0)
              const Padding(
                padding: EdgeInsets.all(10),
                child: Text(
                  "Kelime detayı yok.",
                  style: TextStyle(fontSize: 11, color: Colors.grey),
                ),
              )
            else
              const Padding(
                padding: EdgeInsets.all(10),
                child: Text(
                  "Hatasız sınav, helal olsun!",
                  style: TextStyle(fontSize: 11, color: Colors.greenAccent),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildStageRow(int stage, int count, int total, bool isDark) {
    double percent = total > 0 ? count / total : 0;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                stage == 0 ? "Başlanmadı" : "Aşama $stage",
                style: const TextStyle(fontSize: 12),
              ),
              Text(
                "$count",
                style: const TextStyle(
                  color: kAccentCopper,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          ClipRRect(
            borderRadius: BorderRadius.circular(5),
            child: LinearProgressIndicator(
              value: percent,
              backgroundColor: isDark ? Colors.white10 : Colors.black12,
              color: stage == 6 ? Colors.greenAccent : kAccentCopper,
              minHeight: 5,
            ),
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
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: isDark ? Colors.white10 : Colors.black12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildMiniStat("TOPLAM DOĞRU", "$d", Colors.greenAccent),
          _buildMiniStat("TOPLAM YANLIŞ", "$y", Colors.redAccent),
          _buildMiniStat(
            "GENEL BAŞARI",
            "%${acc.toStringAsFixed(1)}",
            Colors.cyanAccent,
          ),
        ],
      ),
    );
  }

  Widget _buildMiniStat(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.white38,
            fontSize: 9,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 5),
        Text(
          value,
          style: TextStyle(
            color: color,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(
    BuildContext context,
    String title,
    String value,
    IconData icon,
    bool isDark,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: isDark ? Colors.white10 : Colors.black12),
      ),
      child: Row(
        children: [
          Icon(icon, color: kAccentCopper, size: 30),
          const SizedBox(width: 15),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  color: isDark ? Colors.white54 : Colors.black45,
                  fontSize: 13,
                ),
              ),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
