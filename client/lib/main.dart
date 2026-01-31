import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:go_router/go_router.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/presentation/landing_page.dart';
import 'features/auth/presentation/login_screen.dart';
import 'features/auth/presentation/onboarding_screen.dart';
import 'features/auth/presentation/register_screen.dart';
import 'features/auth/presentation/splash_screen.dart';

import 'features/marketplace/presentation/screens/marketplace_feed.dart';
import 'core/widgets/main_layout.dart';
import 'features/tenant_dashboard/presentation/screens/life_pins_screen.dart';
import 'features/messages/presentation/screens/messages_screen.dart';
import 'features/messages/presentation/screens/notifications_screen.dart';
import 'features/profile/presentation/screens/profile_screen.dart';
import 'features/profile/presentation/screens/settings_screen.dart';
import 'features/marketplace/presentation/screens/saved_listings_screen.dart';
import 'features/auth/presentation/forgot_password_screen.dart';
import 'features/auth/presentation/reset_password_screen.dart';
import 'features/auth/presentation/verify_email_pending_screen.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'features/search/data/repositories/search_repository.dart';
import 'features/search/presentation/bloc/search_bloc.dart';
import 'features/search/presentation/screens/map_screen.dart';
import 'features/search/presentation/screens/all_results_screen.dart';
import 'features/marketplace/presentation/screens/listing_details_screen.dart';
import 'features/landlord_features/presentation/screens/landlord_details_screen.dart';
import 'features/search/data/models/search_result.dart';

import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://jxdanbsfcjkuvrakvnoa.supabase.co',
    anonKey: 'sb_publishable_b7AgK9iw5qof-ZuBTDVyHg_FeNHRxox',
  );

  // Initialize SharedPreferences
  await SharedPreferences.getInstance();

  runApp(const KejapinApp());
}

class KejapinApp extends StatefulWidget {
  const KejapinApp({super.key});

  @override
  State<KejapinApp> createState() => _KejapinAppState();
}

class _KejapinAppState extends State<KejapinApp> {
  @override
  void initState() {
    super.initState();
    // Listen for auth state changes
    Supabase.instance.client.auth.onAuthStateChange.listen((data) {
      final AuthChangeEvent event = data.event;
      if (event == AuthChangeEvent.passwordRecovery) {
        _router.go('/reset-password');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return RepositoryProvider(
      create: (context) => SupabaseSearchRepository(),
      child: BlocProvider(
        create: (context) => SearchBloc(context.read<SupabaseSearchRepository>()),
        child: MaterialApp.router(
          title: 'kejapin',
          theme: AppTheme.lightTheme,
          routerConfig: _router,
          debugShowCheckedModeBanner: false,
        ),
      ),
    );
  }
}

final GoRouter _router = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) {
        // Web: Landing page, Mobile: Splash screen
        if (kIsWeb) {
          return const LandingPage();
        }
        return const SplashScreen();
      },
    ),
    GoRoute(
      path: '/onboarding',
      builder: (context, state) => const OnboardingScreen(),
    ),
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: '/register',
      builder: (context, state) => const RegisterScreen(),
    ),
    GoRoute(
      path: '/forgot-password',
      builder: (context, state) => const ForgotPasswordScreen(),
    ),
    GoRoute(
      path: '/reset-password',
      builder: (context, state) => const ResetPasswordScreen(),
    ),
    GoRoute(
      path: '/verify-email-pending',
      builder: (context, state) {
        final email = state.uri.queryParameters['email'] ?? '';
        return VerifyEmailPendingScreen(email: email);
      },
    ),
    ShellRoute(
      builder: (context, state, child) => MainLayout(child: child),
      routes: [
        GoRoute(
          path: '/marketplace',
          builder: (context, state) {
            final query = state.uri.queryParameters['query'];
            final propertyType = state.uri.queryParameters['propertyType'];
            return MarketplaceFeed(
              initialSearchQuery: query,
              initialPropertyType: propertyType,
            );
          },
        ),
        GoRoute(
          path: '/life-pins',
          builder: (context, state) => const LifePinsScreen(),
        ),
        GoRoute(
          path: '/messages',
          builder: (context, state) => const MessagesScreen(),
        ),
        GoRoute(
          path: '/profile',
          builder: (context, state) => const ProfileScreen(),
        ),
        GoRoute(
          path: '/saved',
          builder: (context, state) => const SavedListingsScreen(),
        ),
        GoRoute(
          path: '/settings',
          builder: (context, state) => const SettingsScreen(),
        ),
      ],
    ),
    GoRoute(
      path: '/notifications',
      builder: (context, state) => const NotificationsScreen(),
    ),
    // Search & Details Routes
    GoRoute(
      path: '/search-results',
      builder: (context, state) {
        final category = state.uri.queryParameters['category'];
        return AllResultsScreen(category: category);
      },
    ),
    GoRoute(
      path: '/map',
      builder: (context, state) {
        final extra = state.extra as SearchResult?;
        return MapScreen(extra: extra);
      },
    ),
    GoRoute(
      path: '/marketplace/listing/:id',
      builder: (context, state) {
        final id = state.pathParameters['id']!;
        final map = state.extra as Map<String, dynamic>?;
        // final listing = map?['listing']; // We might pass entities too eventually
        final initialView = map?['initialView'] as String? ?? 'image';
        return ListingDetailsScreen(
          id: id, 
          activeViewMode: initialView
        );
      },
    ),
    GoRoute(
      path: '/landlords/:id',
      builder: (context, state) {
        final id = state.pathParameters['id']!;
        final extra = state.extra as SearchResult?;
        return LandlordDetailsScreen(id: id, extra: extra);
      },
    ),
  ],
);

