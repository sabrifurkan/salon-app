import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../models/client_model.dart';
import '../../models/campaign_model.dart';
import '../../providers/client_provider.dart';
import '../../providers/campaign_provider.dart';

class CampaignScreen extends ConsumerStatefulWidget {
  const CampaignScreen({super.key});

  @override
  ConsumerState<CampaignScreen> createState() => _CampaignScreenState();
}

class _CampaignScreenState extends ConsumerState<CampaignScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _messageController = TextEditingController();
  final Set<String> _selectedClientIds = {};
  bool _selectAll = false;
  bool _isSending = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('SMS Kampanyaları'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Yeni Kampanya', icon: Icon(Icons.edit)),
            Tab(text: 'Geçmiş', icon: Icon(Icons.history)),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildNewCampaignTab(),
          _buildHistoryTab(),
        ],
      ),
    );
  }

  // ────────────────────────────────────────────
  // NEW CAMPAIGN TAB
  // ────────────────────────────────────────────
  Widget _buildNewCampaignTab() {
    final clientsAsync = ref.watch(clientListProvider);
    final colorScheme = Theme.of(context).colorScheme;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ─── Message Input ───
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Kampanya Mesajı',
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _messageController,
                    maxLines: 5,
                    maxLength: 500,
                    decoration: const InputDecoration(
                      hintText: 'Kampanya mesajınızı yazın...\n'
                          'Örn: Sayın müşterimiz, bu ay tüm cilt bakımı '
                          'hizmetlerinde %20 indirim!',
                      alignLabelWithHint: true,
                    ),
                    onChanged: (v) => setState(() {}),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // ─── Client Selection ───
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Alıcılar',
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium
                            ?.copyWith(fontWeight: FontWeight.w600),
                      ),
                      Row(
                        children: [
                          Text(
                            '${_selectedClientIds.length} seçili',
                            style: TextStyle(
                              color: colorScheme.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(width: 8),
                          FilterChip(
                            label: const Text('Tümünü Seç'),
                            selected: _selectAll,
                            onSelected: (selected) {
                              final clients =
                                  clientsAsync.valueOrNull ?? [];
                              setState(() {
                                _selectAll = selected;
                                if (selected) {
                                  _selectedClientIds.addAll(clients
                                      .where((c) =>
                                          c.phone != null &&
                                          c.phone!.isNotEmpty)
                                      .map((c) => c.id!));
                                } else {
                                  _selectedClientIds.clear();
                                }
                              });
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  clientsAsync.when(
                    data: (clients) {
                      final withPhone = clients
                          .where((c) =>
                              c.phone != null && c.phone!.isNotEmpty)
                          .toList();

                      if (withPhone.isEmpty) {
                        return Padding(
                          padding: const EdgeInsets.all(16),
                          child: Center(
                            child: Text(
                              'Telefon numarası olan müşteri bulunamadı',
                              style: TextStyle(
                                  color: colorScheme.onSurface
                                      .withOpacity(0.6)),
                            ),
                          ),
                        );
                      }

                      return SizedBox(
                        height: 250,
                        child: ListView.builder(
                          itemCount: withPhone.length,
                          itemBuilder: (context, index) {
                            final client = withPhone[index];
                            final isSelected =
                                _selectedClientIds.contains(client.id);
                            return CheckboxListTile(
                              dense: true,
                              value: isSelected,
                              onChanged: (checked) {
                                setState(() {
                                  if (checked == true) {
                                    _selectedClientIds.add(client.id!);
                                  } else {
                                    _selectedClientIds.remove(client.id);
                                    _selectAll = false;
                                  }
                                });
                              },
                              title: Text(client.fullName),
                              subtitle: Text(client.phone ?? '',
                                  style: const TextStyle(fontSize: 12)),
                              secondary: CircleAvatar(
                                radius: 16,
                                backgroundColor:
                                    colorScheme.primary.withOpacity(0.1),
                                child: Text(
                                  client.name.isNotEmpty
                                      ? client.name[0].toUpperCase()
                                      : '?',
                                  style: TextStyle(
                                    color: colorScheme.primary,
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      );
                    },
                    loading: () =>
                        const Center(child: CircularProgressIndicator()),
                    error: (e, _) => Text('Müşteriler yüklenemedi: $e'),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // ─── Send Button ───
          SizedBox(
            height: 52,
            child: ElevatedButton.icon(
              icon: _isSending
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white),
                    )
                  : const Icon(Icons.send),
              label: Text(
                _isSending
                    ? 'Gönderiliyor...'
                    : 'Kampanyayı Gönder (${_selectedClientIds.length} kişi)',
                style: const TextStyle(fontSize: 16),
              ),
              onPressed: _canSend() && !_isSending ? _sendCampaign : null,
            ),
          ),
        ],
      ),
    );
  }

  bool _canSend() {
    return _messageController.text.trim().isNotEmpty &&
        _selectedClientIds.isNotEmpty;
  }

  Future<void> _sendCampaign() async {
    setState(() => _isSending = true);

    try {
      final clients = ref.read(clientListProvider).valueOrNull ?? [];
      final selectedClients = clients
          .where((c) => _selectedClientIds.contains(c.id))
          .toList();
      final phones = selectedClients
          .map((c) => c.phone ?? '')
          .where((p) => p.isNotEmpty)
          .toList();

      // Send SMS via mock service
      final smsService = ref.read(smsServiceProvider);
      final successCount = await smsService.sendBulkSms(
        phoneNumbers: phones,
        message: _messageController.text.trim(),
      );

      // Log campaign to Supabase
      final campaign = CampaignModel(
        message: _messageController.text.trim(),
        recipientCount: phones.length,
        recipientIds: _selectedClientIds.toList(),
        status: 'sent',
      );
      await ref.read(campaignListProvider.notifier).addCampaign(campaign);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content:
                Text('Kampanya gönderildi! $successCount/${ phones.length} başarılı ✓'),
            backgroundColor: Colors.green,
          ),
        );
        // Reset form
        _messageController.clear();
        setState(() {
          _selectedClientIds.clear();
          _selectAll = false;
        });
        _tabController.animateTo(1); // Switch to history tab
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Kampanya gönderilemedi: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSending = false);
    }
  }

  // ────────────────────────────────────────────
  // HISTORY TAB
  // ────────────────────────────────────────────
  Widget _buildHistoryTab() {
    final campaignsAsync = ref.watch(campaignListProvider);
    final colorScheme = Theme.of(context).colorScheme;

    return campaignsAsync.when(
      data: (campaigns) {
        if (campaigns.isEmpty) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.campaign_outlined,
                    size: 64, color: colorScheme.outline),
                const SizedBox(height: 16),
                Text(
                  'Henüz kampanya gönderilmemiş',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ],
            ),
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: campaigns.length,
          separatorBuilder: (_, __) => const SizedBox(height: 8),
          itemBuilder: (context, index) {
            final campaign = campaigns[index];
            return Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(
                              campaign.status == 'sent'
                                  ? Icons.check_circle
                                  : Icons.error,
                              size: 18,
                              color: campaign.status == 'sent'
                                  ? Colors.green
                                  : colorScheme.error,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '${campaign.recipientCount} alıcı',
                              style: const TextStyle(
                                  fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                        Text(
                          campaign.sentAt != null
                              ? DateFormat('dd.MM.yyyy HH:mm')
                                  .format(campaign.sentAt!)
                              : '-',
                          style: TextStyle(
                            fontSize: 12,
                            color:
                                colorScheme.onSurface.withOpacity(0.5),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      campaign.message,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 13),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Geçmiş yüklenemedi: $e')),
    );
  }
}
