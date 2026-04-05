import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/client_model.dart';
import '../providers/client_provider.dart';

/// Müşteri arama ve seçme widget'ı (autocomplete).
/// Fuzzy search destekler: büyük/küçük harf, Türkçe karakter ve
/// 1-2 yazım hatası toleransı ile arama yapar.
class ClientAutocomplete extends ConsumerStatefulWidget {
  final ClientModel? initialClient;
  final void Function(ClientModel client) onClientSelected;

  const ClientAutocomplete({
    super.key,
    this.initialClient,
    required this.onClientSelected,
  });

  @override
  ConsumerState<ClientAutocomplete> createState() =>
      _ClientAutocompleteState();
}

class _ClientAutocompleteState extends ConsumerState<ClientAutocomplete> {
  final _controller = TextEditingController();
  List<ClientModel> _suggestions = [];
  bool _showDropdown = false;
  ClientModel? _selectedClient;

  @override
  void initState() {
    super.initState();
    _selectedClient = widget.initialClient;
    if (_selectedClient != null) {
      _controller.text = _selectedClient!.fullName;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // ─── Levenshtein distance (basit implementasyon) ───
  int _levenshtein(String a, String b) {
    if (a == b) return 0;
    if (a.isEmpty) return b.length;
    if (b.isEmpty) return a.length;

    final List<List<int>> dp = List.generate(
      a.length + 1,
      (i) => List.generate(b.length + 1, (j) => 0),
    );

    for (int i = 0; i <= a.length; i++) dp[i][0] = i;
    for (int j = 0; j <= b.length; j++) dp[0][j] = j;

    for (int i = 1; i <= a.length; i++) {
      for (int j = 1; j <= b.length; j++) {
        final cost = a[i - 1] == b[j - 1] ? 0 : 1;
        dp[i][j] = [
          dp[i - 1][j] + 1,
          dp[i][j - 1] + 1,
          dp[i - 1][j - 1] + cost,
        ].reduce((a, b) => a < b ? a : b);
      }
    }
    return dp[a.length][b.length];
  }

  /// Türkçe karakterleri normalize eder (büyük/küçük + ğ/İ vb.)
  String _normalize(String s) {
    return s
        .toLowerCase()
        .replaceAll('ğ', 'g')
        .replaceAll('ü', 'u')
        .replaceAll('ş', 's')
        .replaceAll('ı', 'i')
        .replaceAll('ö', 'o')
        .replaceAll('ç', 'c');
  }

  /// Bir query kelimesinin, hedef string'deki herhangi bir kelimeyle
  /// fuzzy eşleşip eşleşmediğini kontrol eder.
  bool _fuzzyWordMatch(String queryWord, String targetWord) {
    final q = _normalize(queryWord);
    final t = _normalize(targetWord);

    // Substring match (q, t içinde geçiyorsa doğrudan eşleşme)
    if (t.contains(q) || q.contains(t)) return true;

    // Levenshtein toleransı: kısa kelimeler için ≤1, uzun kelimeler için ≤2
    final maxDist = q.length <= 4 ? 1 : 2;
    return _levenshtein(q, t) <= maxDist;
  }

  /// Bir müşterinin sorguyla eşleşip eşleşmediğini kontrol eder.
  bool _matches(ClientModel client, String query) {
    final queryWords = query.trim().split(RegExp(r'\s+')).where((w) => w.isNotEmpty).toList();
    if (queryWords.isEmpty) return true;

    // Müşterinin adı ve soyadı -> hedef kelimeler
    final targetWords = [
      client.name,
      client.surname,
      ...client.name.split(' '),
      ...client.surname.split(' '),
    ].where((w) => w.isNotEmpty).toList();

    // Her query kelimesi, en az bir target kelimeyle eşleşmeli
    for (final qw in queryWords) {
      if (qw.length < 2) continue; // 1 harflik kelimeler atlanır
      final anyMatch = targetWords.any((tw) => _fuzzyWordMatch(qw, tw));
      if (!anyMatch) return false;
    }
    return true;
  }

  void _search(String query) {
    if (query.length < 2) {
      setState(() {
        _suggestions = [];
        _showDropdown = false;
      });
      return;
    }

    // Tüm müşteri listesi üzerinde lokal fuzzy filtre uygula
    final allClients = ref.read(clientListProvider).valueOrNull ?? [];
    final results = allClients.where((c) => _matches(c, query)).toList();

    setState(() {
      _suggestions = results;
      _showDropdown = results.isNotEmpty;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          controller: _controller,
          decoration: InputDecoration(
            labelText: 'Müşteri',
            prefixIcon: const Icon(Icons.person_search),
            hintText: 'Müşteri adı yazarak arayın...',
            suffixIcon: _selectedClient != null
                ? IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      _controller.clear();
                      setState(() {
                        _selectedClient = null;
                        _showDropdown = false;
                      });
                    },
                  )
                : null,
          ),
          onChanged: (value) {
            _selectedClient = null;
            _search(value);
          },
          validator: (value) {
            if (_selectedClient == null) {
              return 'Lütfen bir müşteri seçin';
            }
            return null;
          },
        ),
        // ─── Dropdown suggestions ───
        if (_showDropdown)
          Container(
            constraints: const BoxConstraints(maxHeight: 220),
            margin: const EdgeInsets.only(top: 4),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ListView.builder(
              shrinkWrap: true,
              padding: const EdgeInsets.symmetric(vertical: 4),
              itemCount: _suggestions.length,
              itemBuilder: (context, index) {
                final client = _suggestions[index];
                return ListTile(
                  dense: true,
                  leading: CircleAvatar(
                    radius: 16,
                    backgroundColor: Theme.of(context)
                        .colorScheme
                        .primary
                        .withOpacity(0.1),
                    child: Text(
                      client.name.isNotEmpty
                          ? client.name[0].toUpperCase()
                          : '?',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  title: Text(client.fullName),
                  subtitle: client.phone != null
                      ? Text(client.phone!,
                          style: const TextStyle(fontSize: 12))
                      : null,
                  onTap: () {
                    setState(() {
                      _selectedClient = client;
                      _controller.text = client.fullName;
                      _showDropdown = false;
                    });
                    widget.onClientSelected(client);
                  },
                );
              },
            ),
          ),
      ],
    );
  }
}
