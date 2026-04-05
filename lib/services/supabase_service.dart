import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/client_model.dart';
import '../models/service_model.dart';
import '../models/appointment_model.dart';
import '../models/campaign_model.dart';

class SupabaseService {
  final SupabaseClient _client = Supabase.instance.client;

  String get _userId => _client.auth.currentUser!.id;

  // ═══════════════════════════════════════════════
  // AUTH
  // ═══════════════════════════════════════════════

  Future<AuthResponse> signIn(String email, String password) async {
    return await _client.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  Future<void> signOut() async {
    await _client.auth.signOut();
  }

  User? get currentUser => _client.auth.currentUser;
  Stream<AuthState> get authStateChanges => _client.auth.onAuthStateChange;

  // ═══════════════════════════════════════════════
  // CLIENTS
  // ═══════════════════════════════════════════════

  Future<List<ClientModel>> getClients() async {
    final response = await _client
        .from('clients')
        .select()
        .eq('user_id', _userId)
        .order('name');
    return (response as List).map((e) => ClientModel.fromJson(e)).toList();
  }

  Future<ClientModel?> getClientById(String id) async {
    final response =
        await _client.from('clients').select().eq('id', id).maybeSingle();
    return response != null ? ClientModel.fromJson(response) : null;
  }

  Future<List<ClientModel>> searchClients(String query) async {
    if (query.isEmpty) return getClients();
    final response = await _client
        .from('clients')
        .select()
        .eq('user_id', _userId)
        .or('name.ilike.%$query%,surname.ilike.%$query%')
        .order('name')
        .limit(20);
    return (response as List).map((e) => ClientModel.fromJson(e)).toList();
  }

  Future<ClientModel> createClient(ClientModel client) async {
    final data = client.toJson();
    data['user_id'] = _userId;
    final response =
        await _client.from('clients').insert(data).select().single();
    return ClientModel.fromJson(response);
  }

  Future<ClientModel> updateClient(String id, ClientModel client) async {
    final data = client.toJson();
    data.remove('id');
    final response = await _client
        .from('clients')
        .update(data)
        .eq('id', id)
        .select()
        .single();
    return ClientModel.fromJson(response);
  }

  Future<void> deleteClient(String id) async {
    await _client.from('clients').delete().eq('id', id);
  }

  // ═══════════════════════════════════════════════
  // SERVICES
  // ═══════════════════════════════════════════════

  Future<List<ServiceModel>> getServices() async {
    final response = await _client
        .from('services')
        .select()
        .eq('user_id', _userId)
        .eq('is_active', true)
        .order('name');
    return (response as List).map((e) => ServiceModel.fromJson(e)).toList();
  }

  Future<ServiceModel?> getServiceById(String id) async {
    final response =
        await _client.from('services').select().eq('id', id).maybeSingle();
    return response != null ? ServiceModel.fromJson(response) : null;
  }

  Future<ServiceModel> createService(ServiceModel service) async {
    final data = service.toJson();
    data['user_id'] = _userId;
    final response =
        await _client.from('services').insert(data).select().single();
    return ServiceModel.fromJson(response);
  }

  Future<ServiceModel> updateService(String id, ServiceModel service) async {
    final data = service.toJson();
    data.remove('id');
    final response = await _client
        .from('services')
        .update(data)
        .eq('id', id)
        .select()
        .single();
    return ServiceModel.fromJson(response);
  }

  Future<void> deleteService(String id) async {
    // Soft-delete: deactivate the service
    await _client.from('services').update({'is_active': false}).eq('id', id);
  }

  // ═══════════════════════════════════════════════
  // APPOINTMENTS
  // ═══════════════════════════════════════════════

  Future<List<AppointmentModel>> getAppointmentsByDateRange(
      DateTime start, DateTime end) async {
    final response = await _client
        .from('appointments')
        .select('*, clients(name, surname), services(name)')
        .eq('user_id', _userId)
        .neq('status', 'cancelled')
        .gte('start_time', start.toIso8601String())
        .lte('start_time', end.toIso8601String())
        .order('start_time');
    return (response as List)
        .map((e) => AppointmentModel.fromJson(e))
        .toList();
  }

  Future<List<AppointmentModel>> getAppointmentsByDate(DateTime date) async {
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));
    return getAppointmentsByDateRange(startOfDay, endOfDay);
  }

  Future<AppointmentModel> createAppointment(
      AppointmentModel appointment) async {
    final data = appointment.toJson();
    data['user_id'] = _userId;
    final response =
        await _client.from('appointments').insert(data).select(
            '*, clients(name, surname), services(name)').single();
    return AppointmentModel.fromJson(response);
  }

  Future<AppointmentModel> updateAppointment(
      String id, AppointmentModel appointment) async {
    final data = appointment.toJson();
    data.remove('id');
    final response = await _client
        .from('appointments')
        .update(data)
        .eq('id', id)
        .select('*, clients(name, surname), services(name)')
        .single();
    return AppointmentModel.fromJson(response);
  }

  Future<void> cancelAppointment(String id) async {
    await _client
        .from('appointments')
        .update({'status': 'cancelled'}).eq('id', id);
  }

  Future<void> completeAppointment(String id) async {
    await _client
        .from('appointments')
        .update({'status': 'completed'}).eq('id', id);
  }

  // ═══════════════════════════════════════════════
  // CAMPAIGNS
  // ═══════════════════════════════════════════════

  Future<List<CampaignModel>> getCampaigns() async {
    final response = await _client
        .from('campaigns')
        .select()
        .eq('user_id', _userId)
        .order('created_at', ascending: false);
    return (response as List).map((e) => CampaignModel.fromJson(e)).toList();
  }

  Future<CampaignModel> createCampaign(CampaignModel campaign) async {
    final data = campaign.toJson();
    data['user_id'] = _userId;
    final response =
        await _client.from('campaigns').insert(data).select().single();
    return CampaignModel.fromJson(response);
  }

  // ═══════════════════════════════════════════════
  // REALTIME SUBSCRIPTIONS
  // ═══════════════════════════════════════════════

  RealtimeChannel subscribeToAppointments(
      void Function(PostgresChangePayload) callback) {
    return _client
        .channel('public:appointments')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'appointments',
          callback: (payload) {
            debugPrint('Appointment realtime event: ${payload.eventType}');
            callback(payload);
          },
        )
        .subscribe();
  }

  void unsubscribeChannel(RealtimeChannel channel) {
    _client.removeChannel(channel);
  }
}
