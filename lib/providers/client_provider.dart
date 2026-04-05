import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/client_model.dart';
import '../services/supabase_service.dart';
import 'auth_provider.dart';

// ─── All Clients List ───
final clientListProvider =
    StateNotifierProvider<ClientListNotifier, AsyncValue<List<ClientModel>>>(
        (ref) {
  final service = ref.watch(supabaseServiceProvider);
  return ClientListNotifier(service);
});

class ClientListNotifier extends StateNotifier<AsyncValue<List<ClientModel>>> {
  final SupabaseService _service;

  ClientListNotifier(this._service) : super(const AsyncValue.loading()) {
    loadClients();
  }

  Future<void> loadClients() async {
    state = const AsyncValue.loading();
    try {
      final clients = await _service.getClients();
      state = AsyncValue.data(clients);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> searchClients(String query) async {
    try {
      final clients = await _service.searchClients(query);
      state = AsyncValue.data(clients);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<ClientModel> addClient(ClientModel client) async {
    final created = await _service.createClient(client);
    await loadClients();
    return created;
  }

  Future<ClientModel> updateClient(String id, ClientModel client) async {
    final updated = await _service.updateClient(id, client);
    await loadClients();
    return updated;
  }

  Future<void> deleteClient(String id) async {
    await _service.deleteClient(id);
    await loadClients();
  }
}

// ─── Client Search (for autocomplete) ───
final clientSearchProvider =
    FutureProvider.family<List<ClientModel>, String>((ref, query) async {
  final service = ref.watch(supabaseServiceProvider);
  return service.searchClients(query);
});

// ─── Single Client ───
final clientByIdProvider =
    FutureProvider.family<ClientModel?, String>((ref, id) async {
  final service = ref.watch(supabaseServiceProvider);
  return service.getClientById(id);
});
