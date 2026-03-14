# 🦉 Monolingo - İngilizce Kelime Öğrenme Asistanı

Monolingo, kullanıcıların İngilizce kelime dağarcığını kalıcı olarak geliştirmeleri için tasarlanmış, akıllı tekrar sistemine sahip modern bir mobil uygulamadır.

## 🚀 Proje Durumu: Geliştirme Aşaması (v0.5)

Uygulama, temel iskeletten çıkıp dinamik bir yapıya kavuşmuştur. Veritabanı entegrasyonu tamamlanmış ve kullanıcı deneyimi optimize edilmiştir.

### ✅ Mevcut Tamamlanan Özellikler

* **Akıllı Veritabanı (SQLite):** `DbHelper` ile kelime ekleme, silme ve aşamalı tekrar sistemi (Spaced Repetition) altyapısı kuruldu.
* **Gelişmiş Profil & Ayarlar:** * Günlük kelime hedefi belirleme.
    * Kişiselleştirilebilir hatırlatıcı (Bildirim) saatleri.
    * Aydınlık/Karanlık mod desteği.
* **Modern Navigasyon:** Sayfalar arası geçişler premium animasyonlarla (`Curves.easeInOut`) güçlendirildi.
* **Aşamalı Öğrenme Mantığı:** Kelimelerin öğrenilme durumuna göre (1-5 aşama) tekrar aralıklarını manuel belirleme imkanı.
* **Kullanıcı Yönetimi:** Giriş yap, Kayıt ol ve Profil düzenleme ekranları tam işlevsel hale getirildi.

### 🛠️ Devam Eden Çalışmalar (Roadmap)

- [ ] **Wordle Oyun Entegrasyonu:** Günlük kelime tahmin oyunu modülü üzerinde çalışılıyor.
- [ ] **İstatistik Sayfası:** Kullanıcının haftalık/aylık gelişim grafikleri.
- [ ] **Cloud Sync:** Kullanıcı verilerinin Firebase ile bulutta yedeklenmesi.

## 🛠️ Teknik Detaylar

* **Framework:** Flutter
* **Veritabanı:** SQFlite
* **Local Storage:** SharedPreferences (Ayarlar için)
* **State Management:** Provider / InheritedWidget

---
*Geliştirici: Emre ALMA* 🚀
