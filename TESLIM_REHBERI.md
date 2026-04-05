# ArdenPia — Müşteriye Teslim Rehberi

Bu rehber, uygulamayı güzellik salonu sahibine teslim etmek için gereken tüm adımları içerir.  
**Müşterinin Flutter, kod editörü veya herhangi bir geliştirici aracı kurmasına GEREK YOKTUR.**

---

## 📋 Teslim Öncesi Hazırlık (Sen Yapacaksın)

### 1. Supabase Projesini Hazırla

Salon sahibi için zaten oluşturulmuş olmalı. Kontrol listesi:

- [ ] [supabase.com](https://supabase.com) → Proje oluşturuldu
- [ ] `supabase_schema.sql` SQL Editor'de çalıştırıldı
- [ ] Authentication > Email Sign-in aktif
- [ ] Salon sahibi için kullanıcı oluşturuldu (e-posta + şifre)
- [ ] `lib/config/supabase_config.dart` → URL ve Anon Key doğru girildi

### 2. Login Bilgilerini Belirle

Supabase Dashboard → Authentication → Users → **Add User**

```
E-posta: sahibi@ardenpia.com   (salon sahibinin istediği e-posta)
Şifre:   GüçlüBirŞifre123!     (en az 8 karakter)
```

> ⚠️ Bu bilgileri salon sahibine ilet. Şifreyi sonradan kendisi değiştiremez
> (uygulamaya şifre değiştirme eklemedik, ama istenirse eklenebilir).

---

## 📱 Android APK Teslimi

### 3. APK Oluştur (Sen Yapacaksın)

```bash
cd /Users/furkankorkmaz/Desktop/ardenpia
flutter build apk --release
```

Çıktı dosyası:
```
build/app/outputs/flutter-apk/app-release.apk
```

### 4. APK'yı Salon Sahibine İlet

Bu dosyayı salon sahibine gönder (WhatsApp, Google Drive, WeTransfer vb.):

**Salon sahibine söyleyeceklerin:**
1. Telefona "bilinmeyen kaynaklardan yüklemeye izin ver" ayarını aç
   - Ayarlar → Güvenlik → Bilinmeyen Kaynaklar → Aç
2. APK dosyasını indir ve kur
3. Uygulamayı aç, verdiğim e-posta ve şifre ile giriş yap

> 💡 Google Play Store'a yüklemek istersen ayrı bir süreç (yıllık $25 geliştirici hesabı).
> Şimdilik APK ile doğrudan kurulum yeterli.

---

## 🌐 Web Sürümü + Domain

### 5. Web Build Oluştur (Sen Yapacaksın)

```bash
cd /Users/furkankorkmaz/Desktop/ardenpia
flutter build web
```

Çıktı klasörü: `build/web/` — içindeki tüm dosyalar yüklenecek.

### 6. Domain Satın Al

**Önerilen domain sağlayıcıları (Türkiye):**

| Sağlayıcı | Fiyat (.com) | Fiyat (.com.tr) |
|------------|-------------|-----------------|
| [Natro](https://natro.com) | ~150₺/yıl | ~50₺/yıl |
| [Turhost](https://turhost.com) | ~150₺/yıl | ~50₺/yıl |
| [GoDaddy](https://godaddy.com) | ~200₺/yıl | — |

**Önerilen domain adı:** `ardenpia.com` veya `ardenpia.com.tr`

> `.com.tr` daha ucuz ve Türkiye'ye özel, ama `.com` daha profesyonel görünür.

### 7. Web Hosting (Firebase Hosting — Ücretsiz)

Firebase Hosting en kolay ve ücretsiz seçenek:

**Tek seferlik kurulum (sen yapacaksın):**

```bash
# 1. Firebase CLI kur (bir kere)
npm install -g firebase-tools

# 2. Firebase'e giriş yap
firebase login

# 3. Proje klasörüne git
cd /Users/furkankorkmaz/Desktop/ardenpia

# 4. Firebase projesini başlat
firebase init hosting
# Sorulara cevaplar:
#   - Public directory: build/web
#   - Single-page app: Yes
#   - GitHub deploys: No
#   - Overwrite index.html: No

# 5. Yayınla!
firebase deploy --only hosting
```

**Sonuç:** Uygulama `ardenpia.web.app` adresinde yayında olacak.

### 8. Özel Domain Bağla (İsteğe Bağlı)

Firebase Console → Hosting → **Custom Domain** → `ardenpia.com` gir

Firebase sana DNS kayıtları verecek. Bunları domain sağlayıcının (Natro/Turhost) DNS paneline gir:

| Kayıt | Tür | Değer |
|-------|-----|-------|
| `@` | A | Firebase'in vereceği IP |
| `www` | CNAME | `ardenpia.web.app` |

DNS yayılması 1-24 saat sürer, sonra `ardenpia.com` çalışır.

---

## ✅ Salon Sahibine Vereceğin Şeyler

| # | Ne | Nasıl |
|---|-----|-------|
| 1 | **APK dosyası** | WhatsApp / Drive ile gönder |
| 2 | **Web adresi** | `ardenpia.com` veya `ardenpia.web.app` |
| 3 | **Giriş bilgileri** | E-posta + şifre (kağıda yazılı) |
| 4 | **Kısa kullanım kılavuzu** | Aşağıdaki bölüm |

---

## 📖 Salon Sahibi İçin Kullanım Kılavuzu

### Giriş
- Uygulamayı aç (telefon veya web)
- E-posta ve şifre ile giriş yap

### Takvim
- **Günlük/Haftalık/Aylık** görünüm seçimi üst menüden
- Bir saate tıkla → Yeni randevu oluştur
- Randevuya tıkla → Düzenle / Tamamla / İptal et
- 🟥 Pembe-kırmızı = Planlanmış | 🟩 Yeşil = Tamamlanmış

### Müşteriler
- Sol menü → Müşteriler
- Yeni müşteri ekle, düzenle, ara

### Hizmetler
- Sol menü → Hizmetler
- Hizmet adı, süresi ve fiyatı gir

### Veri Yedekleme (CSV)
- Sağ üst menü (⋮) → "Müşterileri Dışa Aktar" veya "Randevuları Dışa Aktar"
- Ayda bir kere yedek al

### Tema
- Sağ üst köşedeki ay/güneş simgesi → Koyu/Açık mod

---

## 🔄 Güncelleme Süreci

Uygulamada değişiklik yaptığında:

**Web güncellemesi:**
```bash
flutter build web
firebase deploy --only hosting
# 30 saniyede canlıda!
```

**Android güncellemesi:**
```bash
flutter build apk --release
# Yeni APK'yı salon sahibine gönder
```

---

## ⚠️ Dikkat Edilecekler

1. **Supabase Ücretsiz Plan**: 7 gün kullanılmazsa uyku moduna girer. Salon sahibi günlük kullanıyorsa sorun olmaz.
2. **Tek Kullanıcı (Single Tenant)**: Bu uygulama tek salon için tasarlandı. Başka salonlar için ayrı Supabase projesi + ayrı build gerekir.
3. **SMS**: Şu an mock. Gerçek SMS gönderimi için Netgsm hesabı açılmalı (~0.05₺/SMS).
4. **Yedekleme**: CSV export var ama salon sahibine ayda bir yedek almasını hatırlat.
