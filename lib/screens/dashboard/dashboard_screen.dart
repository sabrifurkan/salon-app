import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../providers/auth_provider.dart';
import '../../providers/client_provider.dart';
import '../../providers/appointment_provider.dart';
import '../../services/csv_export_service.dart';
import 'calendar_screen.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isWide = MediaQuery.of(context).size.width > 800;

    return Scaffold(
      appBar: AppBar(
        title: const Text('ArdenPia'),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            onSelected: (value) async {
              switch (value) {
                case 'export_clients':
                  await _exportClients();
                  break;
                case 'export_appointments':
                  await _exportAppointments();
                  break;
                case 'logout':
                  final service = ref.read(supabaseServiceProvider);
                  await service.signOut();
                  if (mounted) context.go('/login');
                  break;
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'export_clients',
                child: Row(
                  children: [
                    Icon(Icons.people_outline, size: 20),
                    SizedBox(width: 8),
                    Text('Müşterileri Dışa Aktar (CSV)'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'export_appointments',
                child: Row(
                  children: [
                    Icon(Icons.calendar_month_outlined, size: 20),
                    SizedBox(width: 8),
                    Text('Randevuları Dışa Aktar (CSV)'),
                  ],
                ),
              ),
              const PopupMenuDivider(),
              const PopupMenuItem(
                value: 'logout',
                child: Row(
                  children: [
                    Icon(Icons.logout, size: 20),
                    SizedBox(width: 8),
                    Text('Çıkış Yap'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: Row(
        children: [
          // ─── Navigation Rail (wide screens) ───
          if (isWide)
            NavigationRail(
              selectedIndex: _selectedIndex,
              onDestinationSelected: _onNavSelected,
              labelType: NavigationRailLabelType.all,
              leading: Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Icon(Icons.spa_rounded,
                    color: colorScheme.primary, size: 32),
              ),
              destinations: const [
                NavigationRailDestination(
                  icon: Icon(Icons.calendar_month_outlined),
                  selectedIcon: Icon(Icons.calendar_month),
                  label: Text('Takvim'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.people_outlined),
                  selectedIcon: Icon(Icons.people),
                  label: Text('Müşteriler'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.content_cut_outlined),
                  selectedIcon: Icon(Icons.content_cut),
                  label: Text('Hizmetler'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.campaign_outlined),
                  selectedIcon: Icon(Icons.campaign),
                  label: Text('Kampanyalar'),
                ),
              ],
            ),
          if (isWide) const VerticalDivider(width: 1, thickness: 1),
          // ─── Content ───
          Expanded(
            child: _buildContent(),
          ),
        ],
      ),
      // ─── Bottom Nav (narrow screens) ───
      bottomNavigationBar: isWide
          ? null
          : NavigationBar(
              selectedIndex: _selectedIndex,
              onDestinationSelected: _onNavSelected,
              destinations: const [
                NavigationDestination(
                  icon: Icon(Icons.calendar_month_outlined),
                  selectedIcon: Icon(Icons.calendar_month),
                  label: 'Takvim',
                ),
                NavigationDestination(
                  icon: Icon(Icons.people_outlined),
                  selectedIcon: Icon(Icons.people),
                  label: 'Müşteriler',
                ),
                NavigationDestination(
                  icon: Icon(Icons.content_cut_outlined),
                  selectedIcon: Icon(Icons.content_cut),
                  label: 'Hizmetler',
                ),
                NavigationDestination(
                  icon: Icon(Icons.campaign_outlined),
                  selectedIcon: Icon(Icons.campaign),
                  label: 'Kampanyalar',
                ),
              ],
            ),
    );
  }

  void _onNavSelected(int index) {
    if (index == _selectedIndex) return;
    switch (index) {
      case 0:
        setState(() => _selectedIndex = 0);
        break;
      case 1:
        context.push('/clients');
        break;
      case 2:
        context.push('/services');
        break;
      case 3:
        context.push('/campaigns');
        break;
    }
  }

  Widget _buildContent() {
    switch (_selectedIndex) {
      case 0:
        return const CalendarScreen();
      default:
        return const CalendarScreen();
    }
  }

  Future<void> _exportClients() async {
    try {
      final clients = ref.read(clientListProvider).valueOrNull ?? [];
      if (clients.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Dışa aktarılacak müşteri yok')),
          );
        }
        return;
      }
      final csv = CsvExportService.clientsToCsv(clients);
      final now = DateFormat('yyyy-MM-dd').format(DateTime.now());
      await CsvExportService.downloadCsv(csv, 'ardenpia_musteriler_$now.csv');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${clients.length} müşteri dışa aktarıldı ✓'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Dışa aktarma hatası: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  Future<void> _exportAppointments() async {
    try {
      // Fetch all appointments for the last 12 months + next 3 months
      final now = DateTime.now();
      final start = DateTime(now.year - 1, now.month, 1);
      final end = DateTime(now.year, now.month + 3, 0, 23, 59);

      final service = ref.read(supabaseServiceProvider);
      final appointments = await service.getAppointmentsByDateRange(start, end);

      if (appointments.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Dışa aktarılacak randevu yok')),
          );
        }
        return;
      }
      final csv = CsvExportService.appointmentsToCsv(appointments);
      final dateStr = DateFormat('yyyy-MM-dd').format(now);
      await CsvExportService.downloadCsv(csv, 'ardenpia_randevular_$dateStr.csv');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${appointments.length} randevu dışa aktarıldı ✓'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Dışa aktarma hatası: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }
}
