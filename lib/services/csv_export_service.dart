import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';

import '../models/client_model.dart';
import '../models/appointment_model.dart';

// Web-only import handled conditionally
import 'csv_export_stub.dart'
    if (dart.library.html) 'csv_export_web.dart' as platform;

/// Verileri CSV formatında dışa aktarma servisi.
class CsvExportService {
  static final _dateFormat = DateFormat('dd.MM.yyyy');
  static final _timeFormat = DateFormat('HH:mm');

  /// Bir hücreyi CSV-safe yapar (virgül, tırnak, newline varsa çift tırnak ile sarar).
  static String _escape(String value) {
    if (value.contains(',') || value.contains('"') || value.contains('\n')) {
      return '"${value.replaceAll('"', '""')}"';
    }
    return value;
  }

  /// Satır listesini CSV string'e çevirir.
  static String _rowsToCsv(List<List<String>> rows) {
    return rows.map((row) => row.map(_escape).join(',')).join('\n');
  }

  /// Müşterileri CSV string'e çevirir.
  static String clientsToCsv(List<ClientModel> clients) {
    final rows = <List<String>>[
      // Başlık satırı
      ['Ad', 'Soyad', 'Cinsiyet', 'Meslek', 'Telefon', 'Adres', 'Doğum Tarihi', 'Tedavi Bölgeleri', 'Bölge Başı Fiyat', 'Notlar'],
      // Veri satırları
      ...clients.map((c) => [
            c.name,
            c.surname,
            c.gender ?? '',
            c.job ?? '',
            c.phone ?? '',
            c.address ?? '',
            c.dob != null ? _dateFormat.format(c.dob!) : '',
            c.treatmentAreas.join('; '),
            c.pricePerArea.toStringAsFixed(2),
            c.notes ?? '',
          ]),
    ];
    return _rowsToCsv(rows);
  }

  /// Randevuları CSV string'e çevirir.
  static String appointmentsToCsv(List<AppointmentModel> appointments) {
    final rows = <List<String>>[
      // Başlık satırı
      ['Tarih', 'Başlangıç', 'Bitiş', 'Süre (dk)', 'Müşteri', 'Hizmet', 'Ücret (₺)', 'Durum', 'Notlar'],
      // Veri satırları
      ...appointments.map((a) => [
            _dateFormat.format(a.startTime),
            _timeFormat.format(a.startTime),
            _timeFormat.format(a.endTime),
            a.durationMin.toString(),
            a.clientName ?? '',
            a.serviceName ?? '',
            a.price.toStringAsFixed(2),
            _statusText(a.status),
            a.notes ?? '',
          ]),
    ];
    return _rowsToCsv(rows);
  }

  /// CSV dosyasını indir/paylaş.
  static Future<void> downloadCsv(String csvContent, String fileName) async {
    platform.downloadCsv(csvContent, fileName);
  }

  static String _statusText(String status) {
    switch (status) {
      case 'scheduled':
        return 'Planlandı';
      case 'completed':
        return 'Tamamlandı';
      case 'cancelled':
        return 'İptal Edildi';
      default:
        return status;
    }
  }
}
