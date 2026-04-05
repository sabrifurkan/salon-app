import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/appointment_model.dart';
import '../theme/app_theme.dart';
import 'appointment_card.dart';

/// Özel zaman ızgarası widget'ı.
///
/// Randevuları süreleriyle orantılı yükseklikte gösterir.
/// Formül:  pixelHeight = (durationMin / 60) × hourSlotHeight
///          topOffset   = ((startHour - 8) * 60 + startMin) / 60 × hourSlotHeight
///
/// Bu widget 08:00 - 20:00 arası zaman dilimini görüntüler.
/// NOT: Bu widget kendi içinde kaydırma YAPMAZ. Kaydırma sorumluluğu
/// üst widget'a aittir (SingleChildScrollView ile sarılmalıdır).
class TimeGrid extends StatelessWidget {
  final DateTime date;
  final List<AppointmentModel> appointments;
  final bool compact;
  final bool showTimeLabels;
  final void Function(DateTime time)? onSlotTap;
  final void Function(AppointmentModel appointment)? onAppointmentTap;

  /// Saatlik slot yüksekliği (px) — dışarıdan geçilebilir
  final double hourSlotHeight;

  /// Günün başlangıç/bitiş saati
  static const int startHour = 8;
  static const int endHour = 20;
  static const int totalHours = endHour - startHour; // 12 saat

  const TimeGrid({
    super.key,
    required this.date,
    required this.appointments,
    this.compact = false,
    this.showTimeLabels = true,
    this.onSlotTap,
    this.onAppointmentTap,
    this.hourSlotHeight = 200.0,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final totalHeight = totalHours * hourSlotHeight;

    return SizedBox(
      height: totalHeight,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ─── Time Labels ───
          if (showTimeLabels)
            SizedBox(
              width: compact ? 36 : 60,
              child: Column(
                children: List.generate(totalHours, (index) {
                  final hour = startHour + index;
                  return SizedBox(
                    height: hourSlotHeight,
                    child: Align(
                      alignment: Alignment.topRight,
                      child: Padding(
                        padding: EdgeInsets.only(
                          right: compact ? 4 : 10,
                          top: 4,
                        ),
                        child: Text(
                          compact
                              ? '${hour.toString().padLeft(2, '0')}'
                              : '${hour.toString().padLeft(2, '0')}:00',
                          style: Theme.of(context)
                              .textTheme
                              .labelSmall
                              ?.copyWith(
                                color: colorScheme.onSurface.withOpacity(0.75),
                                fontSize: compact ? 11 : 14,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0.3,
                              ),
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ),
          // ─── Grid + Appointments ───
          Expanded(
            child: GestureDetector(
              onTapUp: (details) {
                if (onSlotTap == null) return;
                // Calculate which time was tapped
                final tapY = details.localPosition.dy;
                final minutesFromStart =
                    (tapY / hourSlotHeight * 60).round();
                final hour = startHour + (minutesFromStart ~/ 60);
                final minute = (minutesFromStart % 60);
                // Snap to 15-minute intervals
                final snappedMinute = (minute ~/ 15) * 15;
                final tappedTime = DateTime(
                  date.year,
                  date.month,
                  date.day,
                  hour.clamp(startHour, endHour - 1),
                  snappedMinute,
                );
                onSlotTap!(tappedTime);
              },
              child: Stack(
                children: [
                  // ─── Hour grid lines ───
                  Column(
                    children: List.generate(totalHours, (index) {
                      return Container(
                        height: hourSlotHeight,
                        decoration: BoxDecoration(
                          border: Border(
                            top: BorderSide(
                              color: colorScheme.outline.withOpacity(0.15),
                              width: 0.5,
                            ),
                          ),
                        ),
                        // Half-hour line
                        child: Column(
                          children: [
                            SizedBox(height: hourSlotHeight / 2),
                            Divider(
                              height: 0,
                              thickness: 0.5,
                              color: colorScheme.outline.withOpacity(0.07),
                            ),
                          ],
                        ),
                      );
                    }),
                  ),
                  // ─── Current time indicator ───
                  if (_isToday())
                    Positioned(
                      top: _currentTimeOffset(),
                      left: 0,
                      right: 0,
                      child: Row(
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: colorScheme.error,
                            ),
                          ),
                          Expanded(
                            child: Container(
                              height: 1.5,
                              color: colorScheme.error.withOpacity(0.7),
                            ),
                          ),
                        ],
                      ),
                    ),
                  // ─── Appointment Cards (Proportional Height) ───
                  ...appointments.asMap().entries.map((entry) {
                    final index = entry.key;
                    final appointment = entry.value;
                    return _buildPositionedAppointment(
                        context, appointment, index);
                  }),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Randevuyu orantılı yükseklikte ve doğru pozisyonda konumlandırır.
  Widget _buildPositionedAppointment(
      BuildContext context, AppointmentModel appointment, int index) {
    // ─── Dinamik Yükseklik Hesaplama ───
    // top: randevu başlangıç saatinin grid başlangıcına göre piksel ofseti
    // height: randevu süresinin piksele dönüşümü
    final startMinutesFromGridStart =
        (appointment.startTime.hour - startHour) * 60 +
            appointment.startTime.minute;
    final top = (startMinutesFromGridStart / 60) * hourSlotHeight;
    final height = (appointment.durationMin / 60) * hourSlotHeight;

    return Positioned(
      top: top.clamp(0.0, totalHours * hourSlotHeight - 20),
      left: compact ? 1 : 4,
      right: compact ? 1 : 4,
      height: height.clamp(14.0, totalHours * hourSlotHeight),
      child: AppointmentCard(
        appointment: appointment,
        color: AppTheme.getStatusColor(appointment.status),
        compact: compact,
        onTap: () => onAppointmentTap?.call(appointment),
      ),
    );
  }

  bool _isToday() {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  double _currentTimeOffset() {
    final now = DateTime.now();
    final minutesFromStart = (now.hour - startHour) * 60 + now.minute;
    return (minutesFromStart / 60) * hourSlotHeight;
  }
}
