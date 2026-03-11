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
      builder: (context) => SimpleDialog(
        title: Text(
          "Günlük Hedef Belirle",
          style: GoogleFonts.montserrat(fontWeight: FontWeight.bold),
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        children: [10, 20, 30, 50, 100].map((e) {
          return SimpleDialogOption(
            onPressed: () => Navigator.pop(context, e),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Text(
                "$e Kelime",
                style: const TextStyle(fontSize: 16, color: kAccentCopper),
              ),
            ),
          );
        }).toList(),
      ),
    );

    if (secilen != null) {
      await prefs.setInt('gunlukHedef', secilen);
      setState(() => _gunlukHedef = secilen);
    }
  }

  // BURAYI SENİN SERVİSE GÖRE BAĞLADIM AGA
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

      // 1. SharedPreferences'a kaydet
      await prefs.setString('hatirlaticiSaat', formattedTime);

      // 2. Senin servisindeki hatirlaticiKur metodunu çağırıyoruz
      await NotificationService().hatirlaticiKur(1, time.hour, time.minute);

      setState(() => _hatirlaticiSaat = formattedTime);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Hatırlatıcı $formattedTime olarak güncellendi aga!"),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
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
            "🎉 Tebrikler! Günlük $_gunlukHedef kelime hedefini tamamladın kral!",
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
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: kAccentCopper))
          : SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  const SizedBox(height: 60),

                  // --- PROFİL ÜST ALAN ---
                  Center(
                    child: Stack(
                      alignment: Alignment.bottomRight,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: kAccentCopper, width: 2),
                          ),
                          child: CircleAvatar(
                            radius: 55,
                            backgroundColor: Theme.of(context).cardColor,
                            child: const Icon(
                              Icons.person,
                              size: 60,
                              color: kAccentCopper,
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ProfilDuzenleEkrani(
                                  mevcutIsim: widget.isim,
                                  mevcutEmail: widget.email,
                                ),
                              ),
                            );
                          },
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: const BoxDecoration(
                              color: kAccentCopper,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.edit,
                              size: 16,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 15),
                  Text(
                    widget.isim.toUpperCase(),
                    style: GoogleFonts.montserrat(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: isDarkMode ? Colors.white : kDeepNavy,
                    ),
                  ),
                  Text(
                    widget.email,
                    style: TextStyle(
                      color: isDarkMode ? Colors.white54 : Colors.black54,
                      fontSize: 14,
                    ),
                  ),

                  const SizedBox(height: 35),

                  _buildActionTile(
                    context,
                    "Günlük Hedef",
                    "$_tamamlananBugun / $_gunlukHedef Kelime",
                    Icons.bolt,
                    isDarkMode,
                    onTap: _hedefSec,
                    color: _tamamlananBugun >= _gunlukHedef
                        ? Colors.green
                        : kAccentCopper,
                  ),
                  _buildActionTile(
                    context,
                    "Hatırlatıcı",
                    _hatirlaticiSaat,
                    Icons.notifications_active,
                    isDarkMode,
                    onTap: _saatSec,
                  ),

                  _buildActionTile(
                    context,
                    isDarkMode ? "Karanlık Mod" : "Aydınlık Mod",
                    isDarkMode ? "Gece teması aktif" : "Gündüz teması aktif",
                    isDarkMode ? Icons.dark_mode : Icons.light_mode,
                    isDarkMode,
                    onTap: () {
                      final provider = KelimeUygulamasi.of(context);
                      provider?.changeTheme(
                        isDarkMode ? ThemeMode.light : ThemeMode.dark,
                      );
                    },
                  ),

                  const SizedBox(height: 30),
                  const Text(
                    "TEKRAR ARALIKLARI (GÜN)",
                    style: TextStyle(
                      color: kAccentCopper,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1,
                    ),
                  ),
                  const SizedBox(height: 10),

                  if (_ayarlar.isEmpty)
                    const CircularProgressIndicator(color: kAccentCopper)
                  else
                    Card(
                      color: Theme.of(context).cardColor,
                      elevation: isDarkMode ? 0 : 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                        side: BorderSide(
                          color: isDarkMode ? Colors.white10 : Colors.black12,
                        ),
                      ),
                      child: Column(
                        children: _ayarlar.entries.map((e) {
                          int min = (e.key > 1)
                              ? (_ayarlar[e.key - 1] ?? 0) + 1
                              : 1;
                          int val = (e.value < min) ? min : e.value;
                          return ListTile(
                            title: Text(
                              "${e.key}. Aşama",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: isDarkMode ? Colors.white : kDeepNavy,
                              ),
                            ),
                            subtitle: Text(
                              "Min. $min gün sonra",
                              style: TextStyle(
                                color: isDarkMode
                                    ? Colors.white54
                                    : Colors.black54,
                              ),
                            ),
                            trailing: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                              ),
                              decoration: BoxDecoration(
                                color: isDarkMode
                                    ? kDeepNavy
                                    : Colors.grey[200],
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: DropdownButton<int>(
                                value: val,
                                dropdownColor: Theme.of(context).cardColor,
                                iconEnabledColor: kAccentCopper,
                                underline: Container(),
                                items: List.generate(366 - min, (i) => i + min)
                                    .map((g) {
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
                                    })
                                    .toList(),
                                onChanged: (v) async {
                                  if (v != null) {
                                    await DbHelper().ayarGuncelle(e.key, v);
                                    _loadAllData();
                                  }
                                },
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),

                  const SizedBox(height: 30),

                  ElevatedButton.icon(
                    onPressed: () => Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const LoginSayfasi(),
                      ),
                      (route) => false,
                    ),
                    icon: const Icon(Icons.logout),
                    label: const Text("ÇIKIŞ YAP"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.redAccent.withOpacity(0.1),
                      foregroundColor: Colors.redAccent,
                      elevation: 0,
                      minimumSize: const Size(double.infinity, 60),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                        side: const BorderSide(
                          color: Colors.redAccent,
                          width: 0.5,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 50),
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
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: isDark ? Colors.white10 : Colors.black12),
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: color, size: 22),
        ),
        title: Text(
          title,
          style: TextStyle(
            color: isDark ? Colors.white : kDeepNavy,
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(
          desc,
          style: TextStyle(
            color: isDark ? Colors.white54 : Colors.black45,
            fontSize: 12,
          ),
        ),
        trailing: Icon(
          Icons.arrow_forward_ios,
          size: 14,
          color: isDark ? Colors.white24 : Colors.black26,
        ),
        onTap: onTap,
      ),
    );
  }
}
