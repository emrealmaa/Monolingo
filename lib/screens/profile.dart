import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/db_helper.dart';
import '../constants/constants.dart';
import 'login_screen.dart';
import '../main.dart';
import 'profil_duzenle_screen.dart';
import '../data/notification_service.dart';

class ProfilSekmesi extends StatefulWidget {
  final String isim;
  final String email;

  const ProfilSekmesi({super.key, required this.isim, required this.email});

  @override
  State<ProfilSekmesi> createState() => _ProfilSekmesiState();
}

class _ProfilSekmesiState extends State<ProfilSekmesi> {
  Map<int, int> _ayarlar = {};
  bool _isLoading = true;
  int _tamamlananBugun = 0;
  int _gunlukHedef = 20;
  String _hatirlaticiSaat = "20:00";

  @override
  void initState() {
    super.initState();
    _loadAllData();
  }

  _loadAllData() async {
    final prefs = await SharedPreferences.getInstance();
    var a = await DbHelper().ayarlariGetir();
    var stats = await DbHelper().getGenelIstatistikler();

    if (mounted) {
      setState(() {
        _ayarlar = a;
        _tamamlananBugun = stats['tamamlanan'] ?? 0;
        _gunlukHedef = prefs.getInt('gunlukHedef') ?? 20;
        _hatirlaticiSaat = prefs.getString('hatirlaticiSaat') ?? "20:00";
        _isLoading = false;
      });

      if (_tamamlananBugun >= _gunlukHedef) {
        _hedefTamamlandiBildirimi();
      }
    }
  }

  void _hedefSec() async {
    final prefs = await SharedPreferences.getInstance();
    int? secilen = await showDialog<int>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).cardColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
        title: Text(
          "GÜNLÜK HEDEF",
          textAlign: TextAlign.center,
          style: GoogleFonts.montserrat(
            fontWeight: FontWeight.w900,
            fontSize: 18,
            color: kAccentCopper,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [10, 20, 30, 50, 100].map((e) {
            return ListTile(
              title: Text(
                "$e Kelime",
                textAlign: TextAlign.center,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              onTap: () => Navigator.pop(context, e),
            );
          }).toList(),
        ),
      ),
    );

    if (secilen != null) {
      await prefs.setInt('gunlukHedef', secilen);
      setState(() => _gunlukHedef = secilen);
    }
  }

  void _saatSec() async {
    final prefs = await SharedPreferences.getInstance();
    TimeOfDay? time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(
        hour: int.parse(_hatirlaticiSaat.split(":")[0]),
        minute: int.parse(_hatirlaticiSaat.split(":")[1]),
      ),
    );

    if (time != null) {
      final String formattedTime =
          "${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}";

      await prefs.setString('hatirlaticiSaat', formattedTime);
      await NotificationService().hatirlaticiKur(1, time.hour, time.minute);

      setState(() => _hatirlaticiSaat = formattedTime);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Hatırlatıcı $formattedTime olarak güncellendi !"),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    }
  }

  void _hedefTamamlandiBildirimi() {
    Future.delayed(const Duration(milliseconds: 500), () {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "🎉 Günlük $_gunlukHedef kelime hedefini tamamladın , tebrikler!",
          ),
          backgroundColor: kAccentCopper,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 4),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: kAccentCopper))
          : SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 25),
              child: Column(
                children: [
                  const SizedBox(height: 70),

                  // --- PROFİL ÜST ALAN ---
                  Center(
                    child: Stack(
                      alignment: Alignment.bottomRight,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: kAccentCopper.withOpacity(0.3),
                              width: 3,
                            ),
                          ),
                          child: CircleAvatar(
                            radius: 60,
                            backgroundColor: isDark
                                ? Colors.white.withOpacity(0.05)
                                : Colors.black.withOpacity(0.05),
                            child: const Icon(
                              Icons.person_rounded,
                              size: 70,
                              color: kAccentCopper,
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ProfilDuzenleEkrani(
                                mevcutIsim: widget.isim,
                                mevcutEmail: widget.email,
                              ),
                            ),
                          ),
                          child: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: const BoxDecoration(
                              color: kAccentCopper,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.edit_rounded,
                              size: 18,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    widget.isim.toUpperCase(),
                    style: GoogleFonts.montserrat(
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                      color: isDark ? Colors.white : kDeepNavy,
                      letterSpacing: 1,
                    ),
                  ),
                  Text(
                    widget.email,
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),

                  const SizedBox(height: 40),

                  // --- AYARLAR LİSTESİ ---
                  _buildActionTile(
                    context,
                    "Günlük Hedef",
                    "$_tamamlananBugun / $_gunlukHedef Kelime",
                    Icons.auto_awesome_rounded,
                    isDark,
                    onTap: _hedefSec,
                    color: _tamamlananBugun >= _gunlukHedef
                        ? Colors.green
                        : kAccentCopper,
                  ),
                  _buildActionTile(
                    context,
                    "Hatırlatıcı",
                    "Her gün $_hatirlaticiSaat",
                    Icons.notifications_active_rounded,
                    isDark,
                    onTap: _saatSec,
                  ),
                  _buildActionTile(
                    context,
                    isDark ? "Karanlık Mod" : "Aydınlık Mod",
                    isDark ? "Gece teması aktif" : "Gündüz teması aktif",
                    isDark ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
                    isDark,
                    onTap: () {
                      final provider = KelimeUygulamasi.of(context);
                      provider?.changeTheme(
                        isDark ? ThemeMode.light : ThemeMode.dark,
                      );
                    },
                  ),

                  const SizedBox(height: 35),

                  // TEKRAR ARALIKLARI BAŞLIĞI
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "  TEKRAR ARALIKLARI (GÜN)",
                      style: GoogleFonts.montserrat(
                        color: kAccentCopper,
                        fontSize: 12,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.5,
                      ),
                    ),
                  ),
                  const SizedBox(height: 15),

                  if (_ayarlar.isNotEmpty)
                    Container(
                      decoration: BoxDecoration(
                        color: isDark
                            ? Colors.white.withOpacity(0.03)
                            : Colors.black.withOpacity(0.02),
                        borderRadius: BorderRadius.circular(30),
                        border: Border.all(
                          color: isDark ? Colors.white10 : Colors.black12,
                        ),
                      ),
                      child: Column(
                        children: _ayarlar.entries.map((e) {
                          int min = (e.key > 1)
                              ? (_ayarlar[e.key - 1] ?? 0) + 1
                              : 1;
                          int val = (e.value < min) ? min : e.value;
                          return Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            child: ListTile(
                              title: Text(
                                "${e.key}. Aşama",
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              subtitle: Text(
                                "Minimum $min gün sonra",
                                style: const TextStyle(fontSize: 12),
                              ),
                              trailing: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                ),
                                decoration: BoxDecoration(
                                  color: isDark ? Colors.black26 : Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: kAccentCopper.withOpacity(0.2),
                                  ),
                                ),
                                child: DropdownButton<int>(
                                  value: val,
                                  underline: const SizedBox(),
                                  icon: const Icon(
                                    Icons.keyboard_arrow_down,
                                    color: kAccentCopper,
                                  ),
                                  dropdownColor: Theme.of(context).cardColor,
                                  items:
                                      List.generate(
                                        366 - min,
                                        (i) => i + min,
                                      ).map((g) {
                                        return DropdownMenuItem(
                                          value: g,
                                          child: Text(
                                            "$g Gün",
                                            style: const TextStyle(
                                              color: kAccentCopper,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        );
                                      }).toList(),
                                  onChanged: (v) async {
                                    if (v != null) {
                                      await DbHelper().ayarGuncelle(e.key, v);
                                      _loadAllData();
                                    }
                                  },
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),

                  const SizedBox(height: 40),

                  // ÇIKIŞ BUTONU
                  ElevatedButton.icon(
                    onPressed: () => Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const LoginSayfasi(),
                      ),
                      (route) => false,
                    ),
                    icon: const Icon(Icons.logout_rounded),
                    label: const Text(
                      "GÜVENLİ ÇIKIŞ",
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.redAccent.withOpacity(0.1),
                      foregroundColor: Colors.redAccent,
                      elevation: 0,
                      minimumSize: const Size(double.infinity, 65),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(22),
                        side: const BorderSide(
                          color: Colors.redAccent,
                          width: 0.5,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 120),
                ],
              ),
            ),
    );
  }

  Widget _buildActionTile(
    BuildContext context,
    String title,
    String desc,
    IconData icon,
    bool isDark, {
    Color color = kAccentCopper,
    VoidCallback? onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.0 : 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: isDark ? Colors.white10 : Colors.black.withOpacity(0.05),
        ),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(15),
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 15),
        ),
        subtitle: Text(
          desc,
          style: TextStyle(
            color: Colors.grey,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
        trailing: const Icon(Icons.chevron_right_rounded, color: Colors.grey),
        onTap: onTap,
      ),
    );
  }
}
