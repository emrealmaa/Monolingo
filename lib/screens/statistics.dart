import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../data/db_helper.dart';
import '../constants.dart';

class IstatistikSekmesi extends StatelessWidget {
  const IstatistikSekmesi({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return FutureBuilder<Map<String, dynamic>>(
      future: DbHelper().getGenelIstatistikler(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(
            child: CircularProgressIndicator(color: kAccentCopper),
          );
        }

        final data = snapshot.data!;
        int total = data['toplam'] ?? 0;
        // DbHelper'dan gelen Map'i alıyoruz
        final Map<int, int> asamaDagilimi =
            data['asama_dagilimi'] as Map<int, int>;

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
                "Toplam Kelime",
                "$total",
                Icons.library_books,
                isDark,
              ),
              const SizedBox(height: 15),
              Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      context,
                      "Öğrenilen",
                      "${data['tamamlanan']}",
                      Icons.check_circle,
                      isDark,
                      color: Colors.greenAccent,
                    ),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: _buildStatCard(
                      context,
                      "Devam Eden",
                      "${data['devam_eden']}",
                      Icons.loop,
                      isDark,
                      color: Colors.orangeAccent,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 40),

              Text(
                "AŞAMA DETAYLARI",
                style: TextStyle(
                  color: isDark
                      ? Colors.white.withOpacity(0.5)
                      : Colors.black54,
                  letterSpacing: 1.2,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),

              // Döngü burada devreye giriyor
              for (int i = 1; i <= 6; i++)
                _buildStageProgress(
                  context,
                  i,
                  asamaDagilimi[i] ?? 0, // Map'ten doğru veriyi çekiyoruz
                  total,
                  isDark,
                ),

              const SizedBox(height: 30),
              // Küçük bir motivasyon notu
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: kAccentCopper.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Text(
                  "💡 Unutma aga, 6. aşamaya gelen kelimeler artık kalıcı hafızandadır!",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: kAccentCopper,
                    fontStyle: FontStyle.italic,
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatCard(
    BuildContext context,
    String title,
    String value,
    IconData icon,
    bool isDark, {
    Color color = kAccentCopper,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: isDark ? Colors.white10 : Colors.black12),
        boxShadow: [
          if (!isDark)
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
        ],
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 30),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: isDark ? Colors.white54 : Colors.black45,
                    fontSize: 14,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  value,
                  style: TextStyle(
                    color: isDark ? Colors.white : kDeepNavy,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStageProgress(
    BuildContext context,
    int stage,
    int count,
    int total,
    bool isDark,
  ) {
    double percent = total > 0 ? count / total : 0;
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Aşama $stage",
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white70 : Colors.black87,
                ),
              ),
              Text(
                "$count Kelime",
                style: const TextStyle(
                  color: kAccentCopper,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            // Barlar daha yumuşak görünsün
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: percent,
              backgroundColor: isDark ? Colors.white10 : Colors.black12,
              color: kAccentCopper,
              minHeight: 10,
            ),
          ),
        ],
      ),
    );
  }
}
