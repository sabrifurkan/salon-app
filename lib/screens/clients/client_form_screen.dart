import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../models/client_model.dart';
import '../../providers/client_provider.dart';

// ─── Ankara İlçeleri ───
const List<String> _ankaraIlceleri = [
  'Akyurt',
  'Altındağ',
  'Ayaş',
  'Bala',
  'Beypazarı',
  'Çamlıdere',
  'Çankaya',
  'Çubuk',
  'Elmadağ',
  'Etimesgut',
  'Evren',
  'Gölbaşı',
  'Güdül',
  'Haymana',
  'Kahramankazan',
  'Kalecik',
  'Keçiören',
  'Kızılcahamam',
  'Mamak',
  'Nallıhan',
  'Polatlı',
  'Pursaklar',
  'Sincan',
  'Şereflikoçhisar',
  'Yenimahalle',
];

// ─── Telefon Numarası Formatter ───
// Kullanıcı yazarken otomatik 05XX XXX XX XX formatına çevirir
class _PhoneFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    // Sadece rakamları al
    final digits = newValue.text.replaceAll(RegExp(r'[^\d]'), '');

    // Maks 11 hane (05XX XXX XX XX)
    final limited = digits.length > 11 ? digits.substring(0, 11) : digits;

    // Formatla
    final buffer = StringBuffer();
    for (int i = 0; i < limited.length; i++) {
      if (i == 4 || i == 7 || i == 9) {
        buffer.write(' ');
      }
      buffer.write(limited[i]);
    }

    final formatted = buffer.toString();
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}

class ClientFormScreen extends ConsumerStatefulWidget {
  final String? clientId;

  const ClientFormScreen({super.key, this.clientId});

  @override
  ConsumerState<ClientFormScreen> createState() => _ClientFormScreenState();
}

class _ClientFormScreenState extends ConsumerState<ClientFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _surnameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _jobController = TextEditingController();
  final _acikAdresController = TextEditingController();
  final _notesController = TextEditingController();
  final _priceController = TextEditingController(text: '0');
  final _treatmentController = TextEditingController();

  String? _gender;
  String? _ilce;
  DateTime? _dob;
  List<String> _treatmentAreas = [];
  bool _isLoading = false;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _isEditing = widget.clientId != null;
    if (_isEditing) {
      _loadClient();
    }
  }

  Future<void> _loadClient() async {
    setState(() => _isLoading = true);
    try {
      final client =
          await ref.read(clientByIdProvider(widget.clientId!).future);
      if (client != null && mounted) {
        setState(() {
          _nameController.text = client.name;
          _surnameController.text = client.surname;
          _phoneController.text = client.phone ?? '';
          _jobController.text = client.job ?? '';
          _notesController.text = client.notes ?? '';
          _priceController.text = client.pricePerArea.toStringAsFixed(0);
          _gender = client.gender;
          _dob = client.dob;
          _treatmentAreas = List.from(client.treatmentAreas);
          // Adres parse: "Ankara, İlçe, Açık Adres"
          _parseAddress(client.address);
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Müşteri yüklenemedi: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _parseAddress(String? address) {
    if (address == null || address.isEmpty) return;
    final parts = address.split(', ');
    // parts[0] = İl (Ankara), parts[1] = İlçe, parts[2+] = Açık adres
    if (parts.length >= 2) {
      final ilce = parts[1].trim();
      if (_ankaraIlceleri.contains(ilce)) {
        _ilce = ilce;
      }
    }
    if (parts.length >= 3) {
      _acikAdresController.text = parts.sublist(2).join(', ').trim();
    }
  }

  String _buildAddress() {
    final parts = <String>['Ankara'];
    if (_ilce != null && _ilce!.isNotEmpty) {
      parts.add(_ilce!);
    }
    if (_acikAdresController.text.trim().isNotEmpty) {
      parts.add(_acikAdresController.text.trim());
    }
    return parts.join(', ');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _surnameController.dispose();
    _phoneController.dispose();
    _jobController.dispose();
    _acikAdresController.dispose();
    _notesController.dispose();
    _priceController.dispose();
    _treatmentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Müşteri Düzenle' : 'Yeni Müşteri'),
        actions: [
          if (_isEditing)
            IconButton(
              icon: const Icon(Icons.delete_outline),
              tooltip: 'Sil',
              onPressed: _deleteClient,
            ),
        ],
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
                    // ─── Kişisel Bilgiler ───
                    _sectionTitle('Kişisel Bilgiler'),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _nameController,
                            decoration: const InputDecoration(
                              labelText: 'Ad *',
                              prefixIcon: Icon(Icons.person),
                            ),
                            validator: (v) =>
                                v == null || v.isEmpty ? 'Ad gerekli' : null,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextFormField(
                            controller: _surnameController,
                            decoration: const InputDecoration(
                              labelText: 'Soyad *',
                              prefixIcon: Icon(Icons.person_outline),
                            ),
                            validator: (v) => v == null || v.isEmpty
                                ? 'Soyad gerekli'
                                : null,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            value: _gender,
                            decoration: const InputDecoration(
                              labelText: 'Cinsiyet',
                              prefixIcon: Icon(Icons.wc),
                            ),
                            items: const [
                              DropdownMenuItem(
                                  value: 'Kadın', child: Text('Kadın')),
                              DropdownMenuItem(
                                  value: 'Erkek', child: Text('Erkek')),
                              DropdownMenuItem(
                                  value: 'Diğer', child: Text('Diğer')),
                            ],
                            onChanged: (v) => setState(() => _gender = v),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextFormField(
                            controller: _jobController,
                            decoration: const InputDecoration(
                              labelText: 'Meslek',
                              prefixIcon: Icon(Icons.work_outline),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    // DOB
                    OutlinedButton.icon(
                      icon: const Icon(Icons.cake_outlined),
                      label: Text(
                        _dob != null
                            ? 'Doğum Tarihi: ${DateFormat('dd.MM.yyyy').format(_dob!)} (${ClientModel.calculateAge(_dob)} yaş)'
                            : 'Doğum Tarihi Seç',
                      ),
                      onPressed: _pickDob,
                    ),

                    const SizedBox(height: 24),
                    // ─── İletişim ───
                    _sectionTitle('İletişim'),
                    const SizedBox(height: 12),
                    // Telefon — Zorunlu + Otomatik Format
                    TextFormField(
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        _PhoneFormatter(),
                      ],
                      decoration: const InputDecoration(
                        labelText: 'Telefon *',
                        prefixIcon: Icon(Icons.phone),
                        hintText: '05XX XXX XX XX',
                      ),
                      validator: (v) {
                        if (v == null || v.isEmpty) {
                          return 'Telefon numarası zorunludur';
                        }
                        final digits = v.replaceAll(RegExp(r'[^\d]'), '');
                        if (digits.length != 11) {
                          return 'Telefon 11 haneli olmalıdır';
                        }
                        if (!digits.startsWith('05')) {
                          return 'Telefon 05 ile başlamalıdır';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // ─── Adres ───
                    _sectionTitle('Adres'),
                    const SizedBox(height: 12),
                    // İl — Sabit Ankara
                    TextFormField(
                      initialValue: 'Ankara',
                      readOnly: true,
                      decoration: InputDecoration(
                        labelText: 'İl *',
                        prefixIcon: const Icon(Icons.location_city),
                        filled: true,
                        fillColor: Theme.of(context).brightness == Brightness.dark
                            ? const Color(0xFF2A2A48).withOpacity(0.5)
                            : Colors.grey.shade100,
                      ),
                    ),
                    const SizedBox(height: 12),
                    // İlçe — Dropdown, Zorunlu
                    DropdownButtonFormField<String>(
                      value: _ilce,
                      isExpanded: true,
                      decoration: const InputDecoration(
                        labelText: 'İlçe *',
                        prefixIcon: Icon(Icons.map_outlined),
                      ),
                      items: _ankaraIlceleri
                          .map((ilce) => DropdownMenuItem(
                                value: ilce,
                                child: Text(ilce),
                              ))
                          .toList(),
                      onChanged: (v) => setState(() => _ilce = v),
                      validator: (v) =>
                          v == null || v.isEmpty ? 'İlçe seçimi zorunludur' : null,
                    ),
                    const SizedBox(height: 12),
                    // Açık Adres — Opsiyonel
                    TextFormField(
                      controller: _acikAdresController,
                      maxLines: 2,
                      decoration: const InputDecoration(
                        labelText: 'Açık Adres',
                        prefixIcon: Icon(Icons.location_on_outlined),
                        alignLabelWithHint: true,
                        hintText: 'Mahalle, sokak, bina no...',
                      ),
                    ),

                    const SizedBox(height: 24),
                    // ─── Tedavi Bilgileri ───
                    _sectionTitle('Tedavi Bilgileri'),
                    const SizedBox(height: 12),
                    // Treatment areas
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _treatmentController,
                            decoration: const InputDecoration(
                              labelText: 'Tedavi Bölgesi Ekle',
                              prefixIcon: Icon(Icons.add_circle_outline),
                              hintText: 'Örn: Yüz, Bacak, Kol...',
                            ),
                            onSubmitted: _addTreatmentArea,
                          ),
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          icon: const Icon(Icons.add),
                          onPressed: () =>
                              _addTreatmentArea(_treatmentController.text),
                        ),
                      ],
                    ),
                    if (_treatmentAreas.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: _treatmentAreas.map((area) {
                          return Chip(
                            label: Text(area),
                            onDeleted: () {
                              setState(() => _treatmentAreas.remove(area));
                            },
                          );
                        }).toList(),
                      ),
                    ],
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _priceController,
                      keyboardType: const TextInputType.numberWithOptions(
                          decimal: true),
                      decoration: const InputDecoration(
                        labelText: 'Alan Başı Fiyat (₺)',
                        prefixIcon: Icon(Icons.payments),
                      ),
                    ),

                    const SizedBox(height: 24),
                    // ─── Notlar ───
                    _sectionTitle('Notlar'),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _notesController,
                      maxLines: 4,
                      decoration: const InputDecoration(
                        labelText: 'Müşteri Notları',
                        prefixIcon: Icon(Icons.note_alt_outlined),
                        alignLabelWithHint: true,
                        hintText: 'Özel bilgiler, alerjiler, vb.',
                      ),
                    ),

                    const SizedBox(height: 32),
                    // ─── Save Button ───
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
                        onPressed: _isLoading ? null : _saveClient,
                      ),
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _sectionTitle(String title) {
    return Text(
      title,
      style: Theme.of(context)
          .textTheme
          .titleMedium
          ?.copyWith(fontWeight: FontWeight.bold),
    );
  }

  void _addTreatmentArea(String area) {
    final trimmed = area.trim();
    if (trimmed.isNotEmpty && !_treatmentAreas.contains(trimmed)) {
      setState(() {
        _treatmentAreas.add(trimmed);
        _treatmentController.clear();
      });
    }
  }

  Future<void> _pickDob() async {
    try {
      final date = await showDatePicker(
        context: context,
        initialDate: _dob ?? DateTime(1990),
        firstDate: DateTime(1920),
        lastDate: DateTime.now(),
        helpText: 'Doğum Tarihi',
        cancelText: 'İptal',
        confirmText: 'Tamam',
        fieldLabelText: 'Tarih',
        fieldHintText: 'gg/aa/yyyy',
        initialEntryMode: DatePickerEntryMode.calendarOnly,
        initialDatePickerMode: DatePickerMode.year,
        builder: (context, child) {
          return Theme(
            data: Theme.of(context).copyWith(
              datePickerTheme: Theme.of(context).datePickerTheme.copyWith(
                surfaceTintColor: Colors.transparent,
              ),
            ),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  maxWidth: 500,
                  maxHeight: 700,
                ),
                child: child!,
              ),
            ),
          );
        },
      );
      if (date != null && mounted) setState(() => _dob = date);
    } catch (e) {
      debugPrint('DatePicker error: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Tarih seçici açılamadı: $e')),
      );
    }
  }

  Future<void> _saveClient() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    try {
      final calculatedAge = ClientModel.calculateAge(_dob);

      final client = ClientModel(
        name: _nameController.text.trim(),
        surname: _surnameController.text.trim(),
        gender: _gender,
        job: _jobController.text.trim().isNotEmpty
            ? _jobController.text.trim()
            : null,
        dob: _dob,
        age: calculatedAge,
        phone: _phoneController.text.trim(),
        address: _buildAddress(),
        notes: _notesController.text.trim().isNotEmpty
            ? _notesController.text.trim()
            : null,
        treatmentAreas: _treatmentAreas,
        pricePerArea: double.tryParse(_priceController.text) ?? 0,
      );

      if (_isEditing) {
        await ref
            .read(clientListProvider.notifier)
            .updateClient(widget.clientId!, client);
      } else {
        await ref.read(clientListProvider.notifier).addClient(client);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_isEditing
                ? 'Müşteri güncellendi ✓'
                : 'Müşteri oluşturuldu ✓'),
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

  Future<void> _deleteClient() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Müşteriyi Sil'),
        content: const Text(
            'Bu müşteriyi silmek istediğinize emin misiniz? Bu işlem geri alınamaz.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Vazgeç')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.error),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Sil'),
          ),
        ],
      ),
    );
    if (confirm == true) {
      await ref
          .read(clientListProvider.notifier)
          .deleteClient(widget.clientId!);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Müşteri silindi'),
              backgroundColor: Colors.green),
        );
        context.pop();
      }
    }
  }
}
