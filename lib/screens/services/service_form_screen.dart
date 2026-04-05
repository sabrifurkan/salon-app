import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../models/service_model.dart';
import '../../providers/service_provider.dart';

class ServiceFormScreen extends ConsumerStatefulWidget {
  final String? serviceId;

  const ServiceFormScreen({super.key, this.serviceId});

  @override
  ConsumerState<ServiceFormScreen> createState() => _ServiceFormScreenState();
}

class _ServiceFormScreenState extends ConsumerState<ServiceFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _durationController = TextEditingController(text: '30');
  final _priceController = TextEditingController(text: '0');
  bool _isLoading = false;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _isEditing = widget.serviceId != null;
    if (_isEditing) {
      _loadService();
    }
  }

  Future<void> _loadService() async {
    setState(() => _isLoading = true);
    try {
      final service =
          await ref.read(serviceByIdProvider(widget.serviceId!).future);
      if (service != null && mounted) {
        setState(() {
          _nameController.text = service.name;
          _durationController.text = service.defaultDurationMin.toString();
          _priceController.text = service.defaultPrice.toStringAsFixed(0);
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Hizmet yüklenemedi: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _durationController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Hizmet Düzenle' : 'Yeni Hizmet'),
      ),
      body: _isLoading && _isEditing
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Icon
                    Center(
                      child: Container(
                        width: 72,
                        height: 72,
                        decoration: BoxDecoration(
                          color: Theme.of(context)
                              .colorScheme
                              .primary
                              .withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Icon(
                          Icons.content_cut,
                          size: 36,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Name
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: 'Hizmet Adı *',
                        prefixIcon: Icon(Icons.label_outline),
                        hintText: 'Örn: Lazer Epilasyon',
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Hizmet adı gerekli';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    // Duration
                    TextFormField(
                      controller: _durationController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Varsayılan Süre (dakika) *',
                        prefixIcon: Icon(Icons.timer),
                        hintText: 'Örn: 45',
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Süre gerekli';
                        }
                        if (int.tryParse(value) == null ||
                            int.parse(value) <= 0) {
                          return 'Geçerli bir süre girin';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    // Price
                    TextFormField(
                      controller: _priceController,
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      decoration: const InputDecoration(
                        labelText: 'Varsayılan Fiyat (₺) *',
                        prefixIcon: Icon(Icons.payments),
                        hintText: 'Örn: 500',
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Fiyat gerekli';
                        }
                        if (double.tryParse(value) == null) {
                          return 'Geçerli bir fiyat girin';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 32),
                    // ─── Info Card ───
                    Card(
                      color: Theme.of(context)
                          .colorScheme
                          .primary
                          .withOpacity(0.05),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            Icon(Icons.info_outline,
                                color: Theme.of(context).colorScheme.primary),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'Bu değerler randevu oluşturulurken otomatik doldurulur, '
                                'ancak randevu sırasında değiştirilebilir.',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.copyWith(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .primary,
                                    ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Save
                    SizedBox(
                      height: 52,
                      child: ElevatedButton.icon(
                        icon: _isLoading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                    strokeWidth: 2, color: Colors.white),
                              )
                            : const Icon(Icons.save),
                        label: Text(
                          _isLoading
                              ? 'Kaydediliyor...'
                              : _isEditing
                                  ? 'Güncelle'
                                  : 'Kaydet',
                          style: const TextStyle(fontSize: 16),
                        ),
                        onPressed: _isLoading ? null : _saveService,
                      ),
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
    );
  }

  Future<void> _saveService() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    try {
      final service = ServiceModel(
        name: _nameController.text.trim(),
        defaultDurationMin: int.parse(_durationController.text),
        defaultPrice: double.parse(_priceController.text),
      );

      if (_isEditing) {
        await ref
            .read(serviceListProvider.notifier)
            .updateService(widget.serviceId!, service);
      } else {
        await ref.read(serviceListProvider.notifier).addService(service);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_isEditing
                ? 'Hizmet güncellendi ✓'
                : 'Hizmet oluşturuldu ✓'),
            backgroundColor: Colors.green,
          ),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Hata: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }
}
