import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../screens/login_screen.dart';
import '../screens/dashboard/dashboard_screen.dart';
import '../screens/clients/client_list_screen.dart';
import '../screens/clients/client_form_screen.dart';
import '../screens/services/service_list_screen.dart';
import '../screens/services/service_form_screen.dart';
import '../screens/campaigns/campaign_screen.dart';
import '../screens/appointments/appointment_form.dart';

final goRouter = GoRouter(
  initialLocation: '/',
  redirect: (context, state) {
    final session = Supabase.instance.client.auth.currentSession;
    final isLoggedIn = session != null;
    final isOnLogin = state.matchedLocation == '/login';

    if (!isLoggedIn && !isOnLogin) return '/login';
    if (isLoggedIn && isOnLogin) return '/';
    return null;
  },
  routes: [
    GoRoute(
      path: '/login',
      name: 'login',
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: '/',
      name: 'dashboard',
      builder: (context, state) => const DashboardScreen(),
    ),
    // ─── Client Routes ───
    GoRoute(
      path: '/clients',
      name: 'clients',
      builder: (context, state) => const ClientListScreen(),
    ),
    GoRoute(
      path: '/clients/new',
      name: 'client-new',
      builder: (context, state) => const ClientFormScreen(),
    ),
    GoRoute(
      path: '/clients/:id',
      name: 'client-edit',
      builder: (context, state) {
        final clientId = state.pathParameters['id']!;
        return ClientFormScreen(clientId: clientId);
      },
    ),
    // ─── Service Routes ───
    GoRoute(
      path: '/services',
      name: 'services',
      builder: (context, state) => const ServiceListScreen(),
    ),
    GoRoute(
      path: '/services/new',
      name: 'service-new',
      builder: (context, state) => const ServiceFormScreen(),
    ),
    GoRoute(
      path: '/services/:id',
      name: 'service-edit',
      builder: (context, state) {
        final serviceId = state.pathParameters['id']!;
        return ServiceFormScreen(serviceId: serviceId);
      },
    ),
    // ─── Campaign Routes ───
    GoRoute(
      path: '/campaigns',
      name: 'campaigns',
      builder: (context, state) => const CampaignScreen(),
    ),
    // ─── Appointment Routes ───
    GoRoute(
      path: '/appointments/new',
      name: 'appointment-new',
      builder: (context, state) {
        final extra = state.extra as Map<String, dynamic>?;
        return AppointmentForm(
          initialDate: extra?['date'] as DateTime?,
          initialTime: extra?['time'] as TimeOfDay?,
          initialRoom: extra?['room'] as String?,
        );
      },
    ),
  ],
);
