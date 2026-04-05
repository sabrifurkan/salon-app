import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';

import '../../models/appointment_model.dart';
import '../../providers/appointment_provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/time_grid.dart';

/// Takvim görünüm modu
enum CalendarViewMode { daily, weekly, monthly }

class CalendarScreen extends ConsumerStatefulWidget {
  final String room; // 'oda1' veya 'oda2'
  const CalendarScreen({super.key, this.room = 'oda1'});

  @override
  ConsumerState<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends ConsumerState<CalendarScreen> {
  CalendarViewMode _viewMode = CalendarViewMode.weekly;
  DateTime _focusedDay = DateTime.now();
  DateTime _selectedDay = DateTime.now();
  late String _currentRoom;

  @override
  void initState() {
    super.initState();
    _currentRoom = widget.room;
    _loadAppointments();
  }

  void _loadAppointments() {
    final notifier = ref.read(appointmentsByDateProvider.notifier);
    switch (_viewMode) {
      case CalendarViewMode.daily:
        notifier.loadByDate(_selectedDay);
        break;
      case CalendarViewMode.weekly:
        final weekStart =
            _selectedDay.subtract(Duration(days: _selectedDay.weekday - 1));
        final weekEnd = weekStart.add(const Duration(days: 7));
        notifier.loadByDateRange(weekStart, weekEnd);
        break;
      case CalendarViewMode.monthly:
        final monthStart =
            DateTime(_focusedDay.year, _focusedDay.month, 1);
        final monthEnd =
            DateTime(_focusedDay.year, _focusedDay.month + 1, 0, 23, 59);
        notifier.loadByDateRange(monthStart, monthEnd);
        break;
    }
  }

  /// Seçili odaya göre randevuları filtrele
  List<AppointmentModel> _filterByRoom(List<AppointmentModel> all) {
    return all.where((a) => a.room == _currentRoom).toList();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final appointments = ref.watch(appointmentsByDateProvider);
    final isNarrow = MediaQuery.of(context).size.width < 600;

    return Column(
      children: [
        // ─── Oda Toggle (Oda 1 / Oda 2) ───
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: colorScheme.surface,
            border: Border(
              bottom: BorderSide(
                  color: colorScheme.outline.withOpacity(0.15), width: 1.5),
            ),
          ),
          child: Row(
            children: [
              _roomToggleButton('🛏 Oda 1', 'oda1', colorScheme),
              const SizedBox(width: 8),
              _roomToggleButton('🛏 Oda 2', 'oda2', colorScheme),
            ],
          ),
        ),
        // ─── View Mode Selector ───
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: colorScheme.surface,
            border: Border(
              bottom: BorderSide(
                  color: colorScheme.outline.withOpacity(0.2)),
            ),
          ),
          child: isNarrow ? _buildMobileHeader() : _buildDesktopHeader(),
        ),
        // ─── Calendar Content ───
        Expanded(
          child: appointments.when(
            data: (appointmentList) {
              final filtered = _filterByRoom(appointmentList);
              return _buildCalendarView(filtered);
            },
            loading: () =>
                const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.error_outline,
                      size: 48, color: colorScheme.error),
                  const SizedBox(height: 12),
                  Text('Randevular yüklenemedi',
                      style: Theme.of(context).textTheme.bodyLarge),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: _loadAppointments,
                    child: const Text('Tekrar Dene'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _roomToggleButton(
      String label, String roomValue, ColorScheme colorScheme) {
    final isSelected = _currentRoom == roomValue;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor:
              isSelected ? colorScheme.primary : Colors.transparent,
          foregroundColor: isSelected
              ? colorScheme.onPrimary
              : colorScheme.onSurface.withOpacity(0.7),
          elevation: isSelected ? 2 : 0,
          side: BorderSide(
            color: isSelected
                ? colorScheme.primary
                : colorScheme.outline.withOpacity(0.4),
          ),
          padding:
              const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10)),
        ),
        onPressed: () {
          setState(() => _currentRoom = roomValue);
        },
        child: Text(
          label,
          style: TextStyle(
            fontWeight:
                isSelected ? FontWeight.w700 : FontWeight.w500,
            fontSize: 13,
          ),
        ),
      ),
    );
  }

  // ─── Mobil header ───
  Widget _buildMobileHeader() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _viewModeButton('Günlük', CalendarViewMode.daily),
            const SizedBox(width: 6),
            _viewModeButton('Haftalık', CalendarViewMode.weekly),
            const SizedBox(width: 6),
            _viewModeButton('Aylık', CalendarViewMode.monthly),
          ],
        ),
        const SizedBox(height: 6),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              icon: const Icon(Icons.chevron_left, size: 20),
              onPressed: _previousPeriod,
              tooltip: 'Önceki',
              visualDensity: VisualDensity.compact,
            ),
            Flexible(
              child: Text(
                _getDateLabel(),
                style: Theme.of(context)
                    .textTheme
                    .titleSmall
                    ?.copyWith(fontWeight: FontWeight.w600),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            IconButton(
              icon: const Icon(Icons.chevron_right, size: 20),
              onPressed: _nextPeriod,
              tooltip: 'Sonraki',
              visualDensity: VisualDensity.compact,
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  _focusedDay = DateTime.now();
                  _selectedDay = DateTime.now();
                });
                _loadAppointments();
              },
              style: TextButton.styleFrom(
                visualDensity: VisualDensity.compact,
                padding:
                    const EdgeInsets.symmetric(horizontal: 8),
              ),
              child: const Text('Bugün',
                  style: TextStyle(fontSize: 12)),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDesktopHeader() {
    return Row(
      children: [
        _viewModeButton('Günlük', CalendarViewMode.daily),
        const SizedBox(width: 8),
        _viewModeButton('Haftalık', CalendarViewMode.weekly),
        const SizedBox(width: 8),
        _viewModeButton('Aylık', CalendarViewMode.monthly),
        const Spacer(),
        IconButton(
          icon: const Icon(Icons.chevron_left),
          onPressed: _previousPeriod,
          tooltip: 'Önceki',
        ),
        Text(
          _getDateLabel(),
          style: Theme.of(context)
              .textTheme
              .titleMedium
              ?.copyWith(fontWeight: FontWeight.w600),
        ),
        IconButton(
          icon: const Icon(Icons.chevron_right),
          onPressed: _nextPeriod,
          tooltip: 'Sonraki',
        ),
        const SizedBox(width: 8),
        TextButton.icon(
          icon: const Icon(Icons.today, size: 18),
          label: const Text('Bugün'),
          onPressed: () {
            setState(() {
              _focusedDay = DateTime.now();
              _selectedDay = DateTime.now();
            });
            _loadAppointments();
          },
        ),
      ],
    );
  }

  Widget _viewModeButton(String label, CalendarViewMode mode) {
    final isSelected = _viewMode == mode;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (selected) {
          setState(() => _viewMode = mode);
          _loadAppointments();
        },
        selectedColor:
            Theme.of(context).colorScheme.primary.withOpacity(0.2),
        checkmarkColor: Theme.of(context).colorScheme.primary,
      ),
    );
  }

  String _getDateLabel() {
    final trMonths = [
      '',
      'Ocak',
      'Şubat',
      'Mart',
      'Nisan',
      'Mayıs',
      'Haziran',
      'Temmuz',
      'Ağustos',
      'Eylül',
      'Ekim',
      'Kasım',
      'Aralık'
    ];
    switch (_viewMode) {
      case CalendarViewMode.daily:
        return '${_selectedDay.day} ${trMonths[_selectedDay.month]} ${_selectedDay.year}';
      case CalendarViewMode.weekly:
        final weekStart =
            _selectedDay.subtract(Duration(days: _selectedDay.weekday - 1));
        final weekEnd = weekStart.add(const Duration(days: 6));
        return '${weekStart.day}-${weekEnd.day} ${trMonths[weekEnd.month]}';
      case CalendarViewMode.monthly:
        return '${trMonths[_focusedDay.month]} ${_focusedDay.year}';
    }
  }

  void _previousPeriod() {
    setState(() {
      switch (_viewMode) {
        case CalendarViewMode.daily:
          _selectedDay =
              _selectedDay.subtract(const Duration(days: 1));
          _focusedDay = _selectedDay;
          break;
        case CalendarViewMode.weekly:
          _selectedDay =
              _selectedDay.subtract(const Duration(days: 7));
          _focusedDay = _selectedDay;
          break;
        case CalendarViewMode.monthly:
          _focusedDay =
              DateTime(_focusedDay.year, _focusedDay.month - 1, 1);
          break;
      }
    });
    _loadAppointments();
  }

  void _nextPeriod() {
    setState(() {
      switch (_viewMode) {
        case CalendarViewMode.daily:
          _selectedDay = _selectedDay.add(const Duration(days: 1));
          _focusedDay = _selectedDay;
          break;
        case CalendarViewMode.weekly:
          _selectedDay = _selectedDay.add(const Duration(days: 7));
          _focusedDay = _selectedDay;
          break;
        case CalendarViewMode.monthly:
          _focusedDay =
              DateTime(_focusedDay.year, _focusedDay.month + 1, 1);
          break;
      }
    });
    _loadAppointments();
  }

  Widget _buildCalendarView(List<AppointmentModel> appointments) {
    switch (_viewMode) {
      case CalendarViewMode.daily:
        return _buildDailyView(appointments);
      case CalendarViewMode.weekly:
        return _buildWeeklyView(appointments);
      case CalendarViewMode.monthly:
        return _buildMonthlyView(appointments);
    }
  }

  // ────────────────────────────────────────────
  // DAILY VIEW
  // ────────────────────────────────────────────
  Widget _buildDailyView(List<AppointmentModel> appointments) {
    final dayAppointments = appointments.where((a) {
      return a.startTime.year == _selectedDay.year &&
          a.startTime.month == _selectedDay.month &&
          a.startTime.day == _selectedDay.day;
    }).toList();

    return SingleChildScrollView(
      child: TimeGrid(
        date: _selectedDay,
        appointments: dayAppointments,
        onSlotTap: (time) => _createAppointment(time),
        onAppointmentTap: (appointment) =>
            _showAppointmentDetails(appointment),
      ),
    );
  }

  // ────────────────────────────────────────────
  // WEEKLY VIEW
  // ────────────────────────────────────────────
  Widget _buildWeeklyView(List<AppointmentModel> appointments) {
    final weekStart =
        _selectedDay.subtract(Duration(days: _selectedDay.weekday - 1));
    final trDays = ['Pzt', 'Sal', 'Çar', 'Per', 'Cum', 'Cmt', 'Paz'];

    return Column(
      children: [
        // ─── Sabit Gün Başlıkları ───
        Row(
          children: List.generate(7, (dayIndex) {
            final date = weekStart.add(Duration(days: dayIndex));
            final isToday = _isSameDay(date, DateTime.now());
            final isSelected = _isSameDay(date, _selectedDay);

            return Expanded(
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedDay = date;
                    _viewMode = CalendarViewMode.daily;
                  });
                  _loadAppointments();
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      vertical: 8, horizontal: 4),
                  decoration: BoxDecoration(
                    color: isToday
                        ? Theme.of(context)
                            .colorScheme
                            .primary
                            .withOpacity(0.1)
                        : null,
                    border: Border(
                      bottom: BorderSide(
                        color: isSelected
                            ? Theme.of(context).colorScheme.primary
                            : Theme.of(context)
                                .colorScheme
                                .outline
                                .withOpacity(0.2),
                        width: isSelected ? 2 : 1,
                      ),
                      right: dayIndex < 6
                          ? BorderSide(
                              color: Theme.of(context)
                                  .colorScheme
                                  .outline
                                  .withOpacity(0.1))
                          : BorderSide.none,
                    ),
                  ),
                  child: Column(
                    children: [
                      Text(
                        trDays[dayIndex],
                        style: Theme.of(context)
                            .textTheme
                            .labelSmall
                            ?.copyWith(
                              color: isToday
                                  ? Theme.of(context)
                                      .colorScheme
                                      .primary
                                  : null,
                              fontWeight: isToday
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                            ),
                      ),
                      const SizedBox(height: 2),
                      Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isToday
                              ? Theme.of(context).colorScheme.primary
                              : null,
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          '${date.day}',
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall
                              ?.copyWith(
                                color: isToday ? Colors.white : null,
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
        ),
        // ─── Kaydırılabilir Zaman Grid'leri ───
        Expanded(
          child: SingleChildScrollView(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: List.generate(7, (dayIndex) {
                final date =
                    weekStart.add(Duration(days: dayIndex));
                final dayAppointments = appointments.where((a) {
                  return a.startTime.year == date.year &&
                      a.startTime.month == date.month &&
                      a.startTime.day == date.day;
                }).toList();

                return Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border(
                        right: dayIndex < 6
                            ? BorderSide(
                                color: Theme.of(context)
                                    .colorScheme
                                    .outline
                                    .withOpacity(0.1))
                            : BorderSide.none,
                      ),
                    ),
                    child: TimeGrid(
                      date: date,
                      appointments: dayAppointments,
                      compact: true,
                      showTimeLabels: dayIndex == 0,
                      onSlotTap: (time) => _createAppointment(time),
                      onAppointmentTap: (appointment) =>
                          _showAppointmentDetails(appointment),
                    ),
                  ),
                );
              }),
            ),
          ),
        ),
      ],
    );
  }

  // ────────────────────────────────────────────
  // MONTHLY VIEW
  // ────────────────────────────────────────────
  Widget _buildMonthlyView(List<AppointmentModel> appointments) {
    return TableCalendar(
      firstDay: DateTime.utc(2020, 1, 1),
      lastDay: DateTime.utc(2030, 12, 31),
      focusedDay: _focusedDay,
      selectedDayPredicate: (day) => _isSameDay(day, _selectedDay),
      onDaySelected: (selectedDay, focusedDay) {
        setState(() {
          _selectedDay = selectedDay;
          _focusedDay = focusedDay;
          _viewMode = CalendarViewMode.daily;
        });
        _loadAppointments();
      },
      onPageChanged: (focusedDay) {
        setState(() => _focusedDay = focusedDay);
        _loadAppointments();
      },
      calendarFormat: CalendarFormat.month,
      startingDayOfWeek: StartingDayOfWeek.monday,
      locale: 'tr_TR',
      headerVisible: false,
      daysOfWeekStyle: DaysOfWeekStyle(
        weekdayStyle: TextStyle(
          color: Theme.of(context).colorScheme.onSurface,
          fontWeight: FontWeight.w600,
          fontSize: 13,
        ),
        weekendStyle: TextStyle(
          color: Theme.of(context)
              .colorScheme
              .onSurface
              .withOpacity(0.6),
          fontWeight: FontWeight.w600,
          fontSize: 13,
        ),
      ),
      calendarStyle: CalendarStyle(
        todayDecoration: BoxDecoration(
          color: Theme.of(context)
              .colorScheme
              .primary
              .withOpacity(0.3),
          shape: BoxShape.circle,
        ),
        selectedDecoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primary,
          shape: BoxShape.circle,
        ),
        markerDecoration: BoxDecoration(
          color: Theme.of(context).colorScheme.secondary,
          shape: BoxShape.circle,
        ),
        markersMaxCount: 3,
        outsideDaysVisible: false,
      ),
      calendarBuilders: CalendarBuilders(
        markerBuilder: (context, day, events) {
          final normalDay =
              DateTime(day.year, day.month, day.day);
          final dayAppointments = appointments.where((a) {
            return a.startTime.year == normalDay.year &&
                a.startTime.month == normalDay.month &&
                a.startTime.day == normalDay.day;
          }).toList();
          if (dayAppointments.isEmpty) return null;
          return Positioned(
            bottom: 1,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(
                dayAppointments.length > 3
                    ? 3
                    : dayAppointments.length,
                (i) => Container(
                  width: 6,
                  height: 6,
                  margin:
                      const EdgeInsets.symmetric(horizontal: 1),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppTheme.getStatusColor(
                        dayAppointments[i].status),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year &&
        a.month == b.month &&
        a.day == b.day;
  }

  void _createAppointment(DateTime dateTime) {
    context.push('/appointments/new', extra: {
      'date': dateTime,
      'time': TimeOfDay.fromDateTime(dateTime),
      'room': _currentRoom,
    });
  }

  void _showAppointmentDetails(AppointmentModel appointment) {
    final colorScheme = Theme.of(context).colorScheme;
    final timeFormat = DateFormat('HH:mm');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius:
            BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => Consumer(
        builder: (context, ref, _) {
          return Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Handle bar
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color:
                          colorScheme.outline.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                // Title
                Row(
                  children: [
                    Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppTheme.getStatusColor(
                            appointment.status),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        appointment.clientName ?? 'Müşteri',
                        style: Theme.of(context)
                            .textTheme
                            .headlineSmall
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                    ),
                    Chip(
                      label: Text(
                        AppTheme.getStatusText(appointment.status),
                        style: const TextStyle(fontSize: 12),
                      ),
                      backgroundColor:
                          AppTheme.getStatusColor(appointment.status)
                              .withOpacity(0.15),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _detailRow(Icons.content_cut, 'Hizmet',
                    appointment.serviceName ?? '-'),
                _detailRow(
                    Icons.meeting_room_outlined,
                    'Oda',
                    appointment.room == 'oda1' ? 'Oda 1' : 'Oda 2'),
                _detailRow(
                    Icons.access_time,
                    'Saat',
                    '${timeFormat.format(appointment.startTime)} - ${timeFormat.format(appointment.endTime)}'),
                _detailRow(Icons.timer, 'Süre',
                    '${appointment.durationMin} dakika'),
                _detailRow(Icons.payments, 'Ücret',
                    '₺${appointment.price.toStringAsFixed(2)}'),
                if (appointment.notes != null &&
                    appointment.notes!.isNotEmpty)
                  _detailRow(
                      Icons.note, 'Not', appointment.notes!),
                const SizedBox(height: 24),
                // Actions
                if (appointment.isScheduled)
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          icon:
                              const Icon(Icons.check_circle_outline),
                          label: const Text('Tamamla'),
                          onPressed: () async {
                            await ref
                                .read(appointmentsByDateProvider
                                    .notifier)
                                .completeAppointment(
                                    appointment.id!);
                            if (context.mounted) {
                              Navigator.pop(context);
                            }
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          icon: const Icon(Icons.cancel_outlined),
                          label: const Text('İptal Et'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: colorScheme.error,
                            foregroundColor: colorScheme.onError,
                          ),
                          onPressed: () async {
                            final confirm =
                                await showDialog<bool>(
                              context: context,
                              builder: (ctx) => AlertDialog(
                                title: const Text(
                                    'Randevuyu İptal Et'),
                                content: const Text(
                                    'Bu randevuyu iptal etmek istediğinize emin misiniz?'),
                                actions: [
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.pop(ctx, false),
                                    child: const Text('Vazgeç'),
                                  ),
                                  ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                        backgroundColor:
                                            colorScheme.error),
                                    onPressed: () =>
                                        Navigator.pop(ctx, true),
                                    child: const Text('İptal Et'),
                                  ),
                                ],
                              ),
                            );
                            if (confirm == true) {
                              await ref
                                  .read(appointmentsByDateProvider
                                      .notifier)
                                  .cancelAppointment(appointment.id!);
                              if (context.mounted) {
                                Navigator.pop(context);
                              }
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                const SizedBox(height: 8),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _detailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon,
              size: 20,
              color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 12),
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withOpacity(0.6),
                  ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }
}
