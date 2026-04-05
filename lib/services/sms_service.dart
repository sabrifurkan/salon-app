import 'package:flutter/foundation.dart';

/// SMS Servisi — Kampanya mesajları göndermek için kullanılır.
///
/// Şu an mock olarak çalışır. Gerçek SMS sağlayıcısı (Twilio, Netgsm, vb.)
/// entegrasyonu için [sendSms] metodunun içeriğini değiştirmeniz yeterlidir.
class SmsService {
  /// Tekil SMS gönderimi.
  ///
  /// [phoneNumber] - Alıcı telefon numarası (örn: +905551234567)
  /// [message] - Gönderilecek mesaj metni
  ///
  /// Gerçek entegrasyon için bu metodu değiştirin:
  /// ```dart
  /// // Twilio örneği:
  /// final response = await http.post(
  ///   Uri.parse('https://api.twilio.com/...'),
  ///   headers: {'Authorization': 'Basic $credentials'},
  ///   body: {'To': phoneNumber, 'Body': message, 'From': '+1234567890'},
  /// );
  /// return response.statusCode == 201;
  ///
  /// // Netgsm (Türkiye) örneği:
  /// final response = await http.post(
  ///   Uri.parse('https://api.netgsm.com.tr/sms/send/get'),
  ///   body: {
  ///     'usercode': 'YOUR_USER',
  ///     'password': 'YOUR_PASS',
  ///     'gsmno': phoneNumber,
  ///     'msgheader': 'SALON_ADI',
  ///     'message': message,
  ///   },
  /// );
  /// return response.body.contains('00');
  /// ```
  Future<bool> sendSms({
    required String phoneNumber,
    required String message,
  }) async {
    // ─── MOCK IMPLEMENTATION ───
    // Gerçek SMS API'si entegre edildiğinde bu kısmı değiştirin.
    await Future.delayed(const Duration(milliseconds: 500));
    debugPrint('📱 SMS gönderildi → $phoneNumber: $message');
    return true;
  }

  /// Toplu SMS gönderimi (Kampanya).
  ///
  /// [phoneNumbers] - Alıcı telefon numaraları listesi
  /// [message] - Kampanya mesajı
  ///
  /// Başarılı gönderim sayısını döner.
  Future<int> sendBulkSms({
    required List<String> phoneNumbers,
    required String message,
  }) async {
    int successCount = 0;
    for (final phone in phoneNumbers) {
      try {
        final success = await sendSms(phoneNumber: phone, message: message);
        if (success) successCount++;
      } catch (e) {
        debugPrint('SMS gönderilemedi → $phone: $e');
      }
    }
    return successCount;
  }
}
