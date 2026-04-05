# ArdenPia — Güzellik Salonu Randevu & Yönetim Sistemi

Güzellik salonu sahipleri için randevu ve müşteri yönetim sistemi. Flutter ile geliştirilmiş, Supabase backend kullanır.

## Özellikler

- 📅 **Takvim Görünümü**: Günlük, Haftalık, Aylık görünüm. Randevular süreleriyle orantılı yükseklikte gösterilir.
- 🎨 **Durum Bazlı Renkler**: Planlanmış randevular pembe-kırmızı, tamamlanmışlar yeşil.
- 👥 **Müşteri Yönetimi (CRM)**: Arama, ekleme, düzenleme, tedavi bölgeleri, notlar.
- ✂️ **Hizmet Yönetimi**: Hizmet ekle/düzenle, varsayılan süre ve fiyat.
- 📥 **CSV Dışa Aktarma**: Müşteri ve randevu verilerini CSV olarak indirme (yedekleme).
- 📱 **SMS Kampanyaları**: Toplu SMS gönderimi (mock, entegrasyon noktası hazır).
- 🌙 **Koyu/Açık Mod**: Tema değiştirme.
- 🌍 **Türkçe Arayüz**: Tüm etiketler ve mesajlar Türkçe.

## Teknoloji

| Katman | Teknoloji |
|--------|-----------|
| Framework | Flutter 3.x |
| Backend | Supabase (PostgreSQL, Auth, Realtime) |
| State Management | Riverpod |
| Routing | GoRouter |
| Takvim | table_calendar + özel TimeGrid |

## Kurulum

### 1. Supabase Hazırlığı

1. [supabase.com](https://supabase.com) adresinden yeni bir proje oluşturun.
2. `supabase_schema.sql` dosyasındaki SQL'i **SQL Editor** üzerinden çalıştırın.
3. **Authentication > Email** seçeneğini aktif edin ve bir kullanıcı oluşturun.

### 2. Flutter Yapılandırması

```bash
# Bağımlılıkları yükleyin
flutter pub get

# Supabase bilgilerinizi girin
# lib/config/supabase_config.dart dosyasını düzenleyin
```

`lib/config/supabase_config.dart` dosyasına Supabase URL ve Anon Key bilgilerinizi girin.

### 3. Çalıştırma

```bash
# Web (yerel geliştirme — localhost'ta açılır)
flutter run -d chrome

# Web (canlı dağıtım için derleme)
flutter build web
# Çıktı: build/web/ klasörüne yazılır
# Bu klasörü bir hosting servisine (Firebase Hosting, Vercel, Netlify) yükleyin

# Android
flutter run -d <device_id>

# APK oluşturma
flutter build apk --release
```

## Proje Yapısı

```
lib/
├── main.dart                    # Uygulama girişi
├── config/                      # Yapılandırma
├── theme/                       # Tema (Açık/Koyu)
├── router/                      # GoRouter yönlendirme
├── models/                      # Veri modelleri
├── services/                    # Supabase, SMS, CSV servisleri
│   ├── supabase_service.dart    # Veritabanı işlemleri
│   ├── sms_service.dart         # SMS (mock)
│   ├── csv_export_service.dart  # CSV dışa aktarma
│   ├── csv_export_web.dart      # Web indirme
│   └── csv_export_stub.dart     # Mobil stub
├── providers/                   # Riverpod state yönetimi
├── screens/                     # Ekranlar
│   ├── login_screen.dart
│   ├── dashboard/               # Ana panel + Takvim
│   ├── appointments/            # Randevu formu
│   ├── clients/                 # Müşteri listesi & formu
│   ├── services/                # Hizmet listesi & formu
│   └── campaigns/               # SMS kampanyaları
└── widgets/                     # Yeniden kullanılabilir widgetlar
    ├── time_grid.dart           # Özel zaman ızgarası
    ├── appointment_card.dart    # Randevu kartı (durum bazlı renkler)
    ├── client_autocomplete.dart # Müşteri arama
    └── theme_toggle.dart        # Tema değiştirici
```

## Dinamik Randevu Yüksekliği Mantığı

Takvimde randevuların yüksekliği, süreleriyle doğru orantılıdır:

```
pixelHeight = (durationMinutes / 60) × hourSlotPixelHeight
topOffset   = ((startHour - 8) × 60 + startMinute) / 60 × hourSlotPixelHeight
```

- `hourSlotPixelHeight` = 100px (yapılandırılabilir)
- 10 dakikalık randevu → `(10/60) × 100 = 16.7px`
- 45 dakikalık randevu → `(45/60) × 100 = 75px`
- 60 dakikalık randevu → `(60/60) × 100 = 100px` (tam bir saat)

## CSV Dışa Aktarma

Dashboard sağ üst menüden (⋮) iki seçenek:
- **Müşterileri Dışa Aktar** — Ad, soyad, telefon, tedavi bölgeleri vb.
- **Randevuları Dışa Aktar** — Son 12 ay + gelecek 3 ay

## SMS Entegrasyonu

`lib/services/sms_service.dart` dosyasındaki `sendSms` metodunu gerçek SMS API'si ile değiştirin. Twilio ve Netgsm (Türkiye) örnekleri dosyada yorum olarak mevcuttur.

## Canlıya Alma (Deployment)

`flutter build web` çıktısını (`build/web/`) şu servislere yükleyebilirsiniz:
- **Firebase Hosting** (ücretsiz)
- **Vercel** (ücretsiz)
- **Netlify** (ücretsiz)

## Lisans

Bu proje özel kullanım içindir.
