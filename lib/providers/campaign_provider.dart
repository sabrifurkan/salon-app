import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/campaign_model.dart';
import '../services/supabase_service.dart';
import '../services/sms_service.dart';
import 'auth_provider.dart';

// ─── SMS Service ───
final smsServiceProvider = Provider<SmsService>((ref) {
  return SmsService();
});

// ─── Campaign List ───
final campaignListProvider =
    StateNotifierProvider<CampaignListNotifier, AsyncValue<List<CampaignModel>>>(
        (ref) {
  final service = ref.watch(supabaseServiceProvider);
  return CampaignListNotifier(service);
});

class CampaignListNotifier
    extends StateNotifier<AsyncValue<List<CampaignModel>>> {
  final SupabaseService _service;

  CampaignListNotifier(this._service) : super(const AsyncValue.loading()) {
    loadCampaigns();
  }

  Future<void> loadCampaigns() async {
    state = const AsyncValue.loading();
    try {
      final campaigns = await _service.getCampaigns();
      state = AsyncValue.data(campaigns);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<CampaignModel> addCampaign(CampaignModel campaign) async {
    final created = await _service.createCampaign(campaign);
    await loadCampaigns();
    return created;
  }
}
