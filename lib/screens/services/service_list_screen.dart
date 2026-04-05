import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../models/service_model.dart';
import '../../providers/service_provider.dart';

class ServiceListScreen extends ConsumerWidget {
  const ServiceListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final servicesAsync = ref.watch(serviceListProvider);
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Hizmetler'),
      ),
      body: servicesAsync.when(
        data: (services) {
          if (services.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.content_cut,
                      size: 64, color: colorScheme.outline),
                  const SizedBox(height: 16),
                  Text(
                    'Henüz hizmet eklenmemiş',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.add),
                    label: const Text('İlk Hizmeti Ekle'),
                    onPressed: () => context.push('/services/new'),
                  ),
                ],
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: services.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final service = services[index];
              return _buildServiceCard(context, ref, service);
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.error_outline, size: 48, color: colorScheme.error),
              const SizedBox(height: 12),
              const Text('Hizmetler yüklenemedi'),
              ElevatedButton(
                onPressed: () =>
                    ref.read(serviceListProvider.notifier).loadServices(),
                child: const Text('Tekrar Dene'),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await context.push('/services/new');
          ref.read(serviceListProvider.notifier).loadServices();
        },
        icon: const Icon(Icons.add),
        label: const Text('Yeni Hizmet'),
      ),
    );
  }

  Widget _buildServiceCard(
      BuildContext context, WidgetRef ref, ServiceModel service) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      child: ListTile(
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: colorScheme.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(Icons.content_cut, color: colorScheme.primary),
        ),
        title: Text(
          service.name,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Row(
            children: [
              Icon(Icons.timer, size: 14,
                  color: colorScheme.onSurface.withOpacity(0.5)),
              const SizedBox(width: 4),
              Text('${service.defaultDurationMin} dk',
                  style: const TextStyle(fontSize: 13)),
              const SizedBox(width: 16),
              Icon(Icons.payments, size: 14,
                  color: colorScheme.onSurface.withOpacity(0.5)),
              const SizedBox(width: 4),
              Text('₺${service.defaultPrice.toStringAsFixed(0)}',
                  style: const TextStyle(fontSize: 13)),
            ],
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit_outlined, size: 20),
              tooltip: 'Düzenle',
              onPressed: () async {
                await context.push('/services/${service.id}');
                ref.read(serviceListProvider.notifier).loadServices();
              },
            ),
            IconButton(
              icon: Icon(Icons.delete_outline,
                  size: 20, color: colorScheme.error),
              tooltip: 'Sil',
              onPressed: () async {
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: const Text('Hizmeti Sil'),
                    content: Text(
                        '"${service.name}" hizmetini silmek istiyor musunuz?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(ctx, false),
                        child: const Text('Vazgeç'),
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            backgroundColor: colorScheme.error),
                        onPressed: () => Navigator.pop(ctx, true),
                        child: const Text('Sil'),
                      ),
                    ],
                  ),
                );
                if (confirm == true) {
                  await ref
                      .read(serviceListProvider.notifier)
                      .deleteService(service.id!);
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Hizmet silindi'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  }
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
