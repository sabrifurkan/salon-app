import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../models/appointment_model.dart';
import '../../models/client_model.dart';
import '../../models/service_model.dart';
import '../../providers/appointment_provider.dart';
import '../../providers/client_provider.dart';
import '../../providers/service_provider.dart';
import '../../widgets/client_autocomplete.dart';

class AppointmentForm extends ConsumerStatefulWidget {
  final DateTime? initialDate;
  final TimeOfDay? initialTime;
  final String? initialRoom; // oda seçimi dışarıdan gelebilir

  const AppointmentForm({
    super.key,
    this.initialDate,
    this.initialTime,
    this.initialRoom,
  });

  @override
  ConsumerState<AppointmentForm> createState() => _AppointmentFormState();
}

class _AppointmentFormState extends ConsumerState<AppointmentForm> {
  final _formKey = GlobalKey<FormState>();
  ClientModel? _selectedClient;
  ServiceModel? _selectedService;
  late DateTime _selectedDate;
  late TimeOfDay _selectedTime;
  int _duration = 30;
  double _price = 0;
  String _selectedRoom = 'oda1';
  final _notesController = TextEditingController();

  // ─── Düzeltme: Controller'lar initState'de oluşturulur, build'de DEĞİL ───
  late final TextEditingController _priceController;
  late final TextEditingController _durationController;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.initialDate ?? DateTime.now();
    _selectedTime = widget.initialTime ?? TimeOfDay.now();
    _selectedRoom = widget.initialRoom ?? 'oda1';
    _priceController = TextEditingController(text: '0');
    _durationController = TextEditingController(text: '30');
  }

  @override
  void dispose() {
    _notesController.dispose();
    _priceController.dispose();
    _durationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final servicesAsync = ref.watch(serviceListProvider);
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Yeni Randevu'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => context.pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ─── Oda Seçimi ───
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Oda Seçimi',
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium
                            ?.copyWith(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: _roomButton(
                              context,
                              label: '🛏 Oda 1',
                              value: 'oda1',
                              colorScheme: colorScheme,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _roomButton(
                              context,
                              label: '🛏 Oda 2',
                              value: 'oda2',
                              colorScheme: colorScheme,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // ─── Date & Time ───
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Tarih & Saat',
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium
                            ?.copyWith(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              icon: const Icon(Icons.calendar_today, size: 18),
                              label: Text(
                                DateFormat('dd.MM.yyyy')
                                    .format(_selectedDate),
                              ),
                              onPressed: _pickDate,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: OutlinedButton.icon(
                              icon:
                                  const Icon(Icons.access_time, size: 18),
                              label: Text(
                                '${_selectedTime.hour.toString().padLeft(2, '0')}:${_selectedTime.minute.toString().padLeft(2, '0')}',
                              ),
                              onPressed: _pickTime,
                            ),
                          ),
                        ],
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
                            'Müşteri Seçimi',
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(fontWeight: FontWeight.w600),
                          ),
                          TextButton.icon(
                            icon:
                                const Icon(Icons.person_add, size: 18),
                            label: const Text('Yeni',
                                style: TextStyle(fontSize: 12)),
                            onPressed: () async {
                              await context.push('/clients/new');
                              ref.invalidate(clientListProvider);
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      ClientAutocomplete(
                        onClientSelected: (client) {
                          setState(() => _selectedClient = client);
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // ─── Service Selection ───
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Hizmet Seçimi',
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium
                            ?.copyWith(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 12),
                      servicesAsync.when(
                        data: (services) =>
                            DropdownButtonFormField<ServiceModel>(
                          isExpanded: true,
                          decoration: const InputDecoration(
                            labelText: 'Hizmet',
                            prefixIcon: Icon(Icons.content_cut),
                          ),
                          items: services.map((s) {
                            return DropdownMenuItem(
                              value: s,
                              child: Text(
                                  '${s.name} (${s.defaultDurationMin} dk)'),
                            );
                          }).toList(),
                          onChanged: (service) {
                            if (service != null) {
                              setState(() {
                                _selectedService = service;
                                _duration = service.defaultDurationMin;
                                _price = service.defaultPrice;
                                // Controller'ları da güncelle
                                _durationController.text =
                                    _duration.toString();
                                _priceController.text =
                                    _price.toStringAsFixed(0);
                              });
                            }
                          },
                          validator: (value) {
                            if (value == null) {
                              return 'Lütfen bir hizmet seçin';
                            }
                            return null;
                          },
                        ),
                        loading: () =>
                            const LinearProgressIndicator(),
                        error: (e, _) =>
                            Text('Hizmetler yüklenemedi: $e'),
                      ),
                      const SizedBox(height: 16),
                      // ─── Duration & Price (Manual Override) ───
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              decoration: const InputDecoration(
                                labelText: 'Süre (dakika)',
                                prefixIcon: Icon(Icons.timer),
                              ),
                              keyboardType: TextInputType.number,
                              controller: _durationController,
                              onChanged: (value) {
                                final parsed = int.tryParse(value);
                                if (parsed != null) {
                                  setState(() => _duration = parsed);
                                }
                              },
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Süre gerekli';
                                }
                                if (int.tryParse(value) == null) {
                                  return 'Geçerli bir sayı girin';
                                }
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextFormField(
                              decoration: const InputDecoration(
                                labelText: 'Ücret (₺)',
                                prefixIcon: Icon(Icons.payments),
                              ),
                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                      decimal: true),
                              controller: _priceController,
                              onChanged: (value) {
                                final parsed = double.tryParse(value);
                                if (parsed != null) {
                                  _price = parsed;
                                }
                              },
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // ─── Notes ───
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: TextFormField(
                    controller: _notesController,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      labelText: 'Notlar (opsiyonel)',
                      prefixIcon: Icon(Icons.note_alt_outlined),
                      alignLabelWithHint: true,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // ─── Save Button ───
              SizedBox(
                height: 52,
                child: ElevatedButton.icon(
                  icon: _isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.save),
                  label: Text(
                    _isLoading ? 'Kaydediliyor...' : 'Randevuyu Kaydet',
                    style: const TextStyle(fontSize: 16),
                  ),
                  onPressed: _isLoading ? null : _saveAppointment,
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _roomButton(
    BuildContext context, {
    required String label,
    required String value,
    required ColorScheme colorScheme,
  }) {
    final isSelected = _selectedRoom == value;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: isSelected
              ? colorScheme.primary
              : colorScheme.surface,
          foregroundColor: isSelected
              ? colorScheme.onPrimary
              : colorScheme.onSurface,
          elevation: isSelected ? 3 : 0,
          side: BorderSide(
            color: isSelected
                ? colorScheme.primary
                : colorScheme.outline.withOpacity(0.4),
          ),
          padding: const EdgeInsets.symmetric(vertical: 14),
        ),
        onPressed: () => setState(() => _selectedRoom = value),
        child: Text(
          label,
          style: TextStyle(
            fontWeight:
                isSelected ? FontWeight.w700 : FontWeight.w500,
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  Future<void> _pickDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      locale: const Locale('tr', 'TR'),
    );
    if (date != null) {
      setState(() => _selectedDate = date);
    }
  }

  Future<void> _pickTime() async {
    final time = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context)
              .copyWith(alwaysUse24HourFormat: true),
          child: child!,
        );
      },
    );
    if (time != null) {
      setState(() => _selectedTime = time);
    }
  }

  Future<void> _saveAppointment() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedClient == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lütfen bir müşteri seçin')),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      final startTime = DateTime(
        _selectedDate.year,
        _selectedDate.month,
        _selectedDate.day,
        _selectedTime.hour,
        _selectedTime.minute,
      );
      final endTime = startTime.add(Duration(minutes: _duration));

      // Price: controller'dan parse et (en güncel değer)
      final priceValue =
          double.tryParse(_priceController.text) ?? _price;

      final appointment = AppointmentModel(
        clientId: _selectedClient!.id!,
        serviceId: _selectedService!.id!,
        startTime: startTime,
        endTime: endTime,
        durationMin: _duration,
        price: priceValue,
        room: _selectedRoom,
        notes: _notesController.text.isNotEmpty
            ? _notesController.text
            : null,
      );

      await ref
          .read(appointmentsByDateProvider.notifier)
          .addAppointment(appointment);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Randevu başarıyla oluşturuldu ✓'),
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
