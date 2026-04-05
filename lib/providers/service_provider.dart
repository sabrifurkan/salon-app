import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/service_model.dart';
import '../services/supabase_service.dart';
import 'auth_provider.dart';

// ─── All Services List ───
final serviceListProvider =
    StateNotifierProvider<ServiceListNotifier, AsyncValue<List<ServiceModel>>>(
        (ref) {
  final service = ref.watch(supabaseServiceProvider);
  return ServiceListNotifier(service);
});

class ServiceListNotifier
    extends StateNotifier<AsyncValue<List<ServiceModel>>> {
  final SupabaseService _service;

  ServiceListNotifier(this._service) : super(const AsyncValue.loading()) {
    loadServices();
  }

  Future<void> loadServices() async {
    state = const AsyncValue.loading();
    try {
      final services = await _service.getServices();
      state = AsyncValue.data(services);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<ServiceModel> addService(ServiceModel svc) async {
    final created = await _service.createService(svc);
    await loadServices();
    return created;
  }

  Future<ServiceModel> updateService(String id, ServiceModel svc) async {
    final updated = await _service.updateService(id, svc);
    await loadServices();
    return updated;
  }

  Future<void> deleteService(String id) async {
    await _service.deleteService(id);
    await loadServices();
  }
}

// ─── Single Service ───
final serviceByIdProvider =
    FutureProvider.family<ServiceModel?, String>((ref, id) async {
  final service = ref.watch(supabaseServiceProvider);
  return service.getServiceById(id);
});
