// lib/core/router/app_router.dart
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';
import '../../features/main/presentation/pages/main_page.dart';
import '../../features/onboarding/presentation/pages/preferences_page.dart';
import '../../features/settings/presentation/settings_page.dart';
import '../../features/splash/presentation/pages/splash_page.dart';
import '../../features/onboarding/presentation/pages/onboarding_page.dart';
import '../../features/auth/presentation/pages/auth_page.dart';
import '../../features/auth/presentation/pages/forgot_password_page.dart';
import '../../features/onboarding/presentation/pages/location_permission_page.dart';
import '../../features/trips/presentation/pages/ai_trip_planner_page.dart';
import '../../features/trips/presentation/pages/manual_trip_creator_page.dart';
import '../../features/trips/presentation/pages/trip_timeline_page.dart';
import '../../../../injection_container.dart';
import '../../features/destinations/presentation/bloc/destination_bloc.dart';
import '../../features/discovery/presentation/pages/explore_page.dart';
import '../../features/events/presentation/pages/event_detail_page.dart';
import '../../features/events/presentation/pages/events_list_page.dart';
import '../../features/events/domain/entities/event.dart';
import '../../features/events/presentation/bloc/event_bloc.dart';
import '../../features/destinations/presentation/pages/destination_detail_page.dart';
import '../../features/destinations/domain/entities/destination.dart';
import '../../features/trips/presentation/pages/favorites_page.dart';
import '../../features/trips/presentation/pages/my_trips_page.dart';
import '../../features/trips/presentation/pages/create_trip_page.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: '/',
  redirect: (context, state) {
    return null; // No redirect
  },
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const SplashPage(),
    ),
    GoRoute(
      path: '/onboarding',
      builder: (context, state) => const OnboardingPage(),
    ),
    GoRoute(
      path: '/auth',
      builder: (context, state) => const AuthPage(),
    ),
    GoRoute(
      path: '/forgot-password',
      builder: (context, state) => const ForgotPasswordPage(),
    ),
    GoRoute(
      path: '/preferences',
      builder: (context, state) => const PreferencesPage(),
    ),
    GoRoute(
      path: '/location-permission',
      builder: (context, state) => const LocationPermissionPage(),
    ),
    GoRoute(
      path: '/home',
      builder: (context, state) => const MainPage(),
    ),
    GoRoute(
      path: '/settings',
      builder: (context, state) => const SettingsPage(),
    ),
    GoRoute(
      path: '/ai-trip-planner',
      builder: (context, state) => const AITripPlannerPage(),
    ),
    GoRoute(
      path: '/manual-trip-creator',
      builder: (context, state) => const ManualTripCreatorPage(),
    ),
    GoRoute(
      path: '/trip-timeline/:tripId',
      builder: (context, state) {
        final tripId = state.pathParameters['tripId'] ?? '';
        return TripTimelinePage(tripId: tripId);
      },
    ),
    GoRoute(
      path: '/trips/:id',
      builder: (context, state) {
        final tripId = state.pathParameters['id'] ?? '';
        return TripTimelinePage(tripId: tripId);
      },
    ),
    GoRoute(
      path: '/explore',
      builder: (context, state) {
        return BlocProvider(
          create: (context) => sl<DestinationBloc>(),
          child: const ExplorePage(),
        );
      },
    ),
    GoRoute(
      path: '/explore-detail',
      builder: (context, state) {
        final extra = state.extra as Map<String, dynamic>?;
        return BlocProvider(
          create: (context) => sl<DestinationBloc>(),
          child: ExplorePage(
            initialCategory: extra?['categoryId'],
            initialFilter: extra?['filter'],
            initialSearch: extra?['search'],
          ),
        );
      },
    ),
    GoRoute(
      path: '/event-detail/:eventId',
      builder: (context, state) {
        final event = state.extra as Event?;
        if (event == null) {
          // If no event provided, navigate back or show error
          return Scaffold(
            body: Center(
              child: Text('Event not found'),
            ),
          );
        }
        return EventDetailPage(event: event);
      },
    ),
    GoRoute(
      path: '/destination-detail/:destinationId',
      builder: (context, state) {
        final destinationId = state.pathParameters['destinationId'] ?? '';
        final destination = state.extra as Destination?;

        return DestinationDetailPage(
          destinationId: destinationId,
          destination: destination,
        );
      },
    ),
    GoRoute(
      path: '/events',
      builder: (context, state) {
        return BlocProvider(
          create: (context) => sl<EventBloc>(),
          child: const EventsListPage(),
        );
      },
    ),
    GoRoute(
      path: '/favorites',
      builder: (context, state) {
        final extra = state.extra as Map<String, dynamic>?;
        final initialTab = extra?['initialTab'] as int? ?? 0;

        return BlocProvider(
          create: (context) => sl<DestinationBloc>(),
          child: FavoritesPage(initialTab: initialTab),
        );
      },
    ),
    GoRoute(
      path: '/my-trips',
      builder: (context, state) {
        return const MyTripsPage();
      },
    ),
    GoRoute(
      path: '/create-trip',
      builder: (context, state) {
        return const CreateTripPage();
      },
    ),
  ],
);