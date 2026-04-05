import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/appointment_model.dart';

/// Takvim grid'inde süresine orantılı yükseklikte gösterilen randevu kartı.
class AppointmentCard extends StatelessWidget {
  final AppointmentModel appointment;
  final Color color;
  final bool compact;
  final VoidCallback? onTap;

  const AppointmentCard({
    super.key,
    required this.appointment,
    required this.color,
    this.compact = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final timeFormat = DateFormat('HH:mm');

    return GestureDetector(
      onTap: onTap,
      child: Container(
        clipBehavior: Clip.hardEdge,
        decoration: BoxDecoration(
          color: color.withOpacity(0.95), // Daha az şeffaf, daha doygun renk
          borderRadius: BorderRadius.circular(compact ? 4 : 8),
          border: Border.all(
            color: Colors.black.withOpacity(0.1),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.3),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        padding: EdgeInsets.symmetric(
          horizontal: compact ? 4 : 8,
          vertical: compact ? 2 : 4,
        ),
        child: compact
            ? _buildCompactContent(context, timeFormat)
            : _buildFullContent(context, timeFormat),
      ),
    );
  }

  // ─── Haftalık görünüm için kompakt kart ───
  Widget _buildCompactContent(BuildContext context, DateFormat timeFormat) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final availableHeight = constraints.maxHeight;
        
        // 10-15 dk gibi çok kısa randevularda (< 30px) her şeyi tek satıra koy
        if (availableHeight < 32) {
          final singleLine = "${appointment.clientName ?? ''}${appointment.serviceName != null ? ' • ${appointment.serviceName}' : ''}";
          return Text(
            singleLine,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.black, // En yüksek kontrast için simsiyah
              fontSize: 12,
              fontWeight: FontWeight.w800,
            ),
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(
              child: Text(
                appointment.clientName ?? '',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  height: 1.1,
                ),
              ),
            ),
            if (availableHeight > 38)
              Flexible(
                child: Text(
                  appointment.serviceName ?? '',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.black87,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    height: 1.1,
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  // ─── Günlük görünüm için tam kart ───
  Widget _buildFullContent(BuildContext context, DateFormat timeFormat) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final availableHeight = constraints.maxHeight;
        
        // Günlük görünümde çok kısa (< 34px) ise tek satır
        if (availableHeight < 36) {
           final singleLine = "${appointment.clientName ?? ''} • ${appointment.serviceName ?? ''}";
           return Text(
            singleLine,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.black,
              fontSize: 14,
              fontWeight: FontWeight.w800,
            ),
          );
        }

        final showService = availableHeight >= 36;
        final showTime = availableHeight >= 60;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(
              child: Text(
                appointment.clientName ?? 'Müşteri',
                maxLines: showService ? 1 : 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 15,
                  fontWeight: FontWeight.w900, // Ekstra kalın
                  height: 1.1,
                ),
              ),
            ),
            if (showService) ...[
              const SizedBox(height: 2),
              Flexible(
                child: Text(
                  appointment.serviceName ?? '',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.black87,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    height: 1.1,
                  ),
                ),
              ),
            ],
            if (showTime) ...[
              const SizedBox(height: 2),
              Flexible(
                child: Text(
                  '${timeFormat.format(appointment.startTime)} – ${timeFormat.format(appointment.endTime)}',
                  style: const TextStyle(
                    color: Colors.black54,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    height: 1.1,
                  ),
                ),
              ),
            ],
          ],
        );
      },
    );
  }
}
