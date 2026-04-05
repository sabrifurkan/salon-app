import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/appointment_model.dart';
import '../services/supabase_service.dart';
import 'auth_provider.dart';

// ─── Selected Date ───
final selectedDateProvider = StateProvider<DateTime>((ref) {
  return DateTime.now();
});

// ─── Appointments for a date range ───
final appointmentsByDateProvider = StateNotifierProvider<
    AppointmentListNotifier, AsyncValue<List<AppointmentModel>>>((ref) {
  final service = ref.watch(supabaseServiceProvider);
  return AppointmentListNotifier(service);
});

class AppointmentListNotifier
    extends StateNotifier<AsyncValue<List<AppointmentModel>>> {
  final SupabaseService _service;

  AppointmentListNotifier(this._service) : super(const AsyncValue.loading());

  Future<void> loadByDate(DateTime date) async {
    state = const AsyncValue.loading();
    try {
      final appointments = await _service.getAppointmentsByDate(date);
      state = AsyncValue.data(appointments);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> loadByDateRange(DateTime start, DateTime end) async {
    state = const AsyncValue.loading();
    try {
      final appointments =
          await _service.getAppointmentsByDateRange(start, end);
      state = AsyncValue.data(appointments);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<AppointmentModel> addAppointment(AppointmentModel appointment) async {
    final created = await _service.createAppointment(appointment);
    // Reload current view
    final currentData = state.valueOrNull ?? [];
    state = AsyncValue.data([...currentData, created]);
    return created;
  }

  Future<void> cancelAppointment(String id) async {
    await _service.cancelAppointment(id);
    // Remove from current list
    final currentData = state.valueOrNull ?? [];
    state = AsyncValue.data(
        currentData.where((a) => a.id != id).toList());
  }

  Future<void> completeAppointment(String id) async {
    await _service.completeAppointment(id);
    final currentData = state.valueOrNull ?? [];
    state = AsyncValue.data(
      currentData.map((a) {
        if (a.id == id) return a.copyWith(status: 'completed');
        return a;
      }).toList(),
    );
  }
}
