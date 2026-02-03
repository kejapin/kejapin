import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_localizations/flutter_localizations.dart';
import 'l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'core/providers/locale_provider.dart';
import 'features/admin_features/presentation/screens/component_gallery_screen.dart';
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
import 'features/messages/presentation/screens/chat_screen.dart';
import 'features/messages/presentation/screens/debug_messages_screen.dart';
import 'features/profile/presentation/screens/profile_screen.dart';
import 'features/profile/presentation/screens/settings_screen.dart';
import 'features/profile/presentation/screens/edit_profile_screen.dart';
import 'features/marketplace/presentation/screens/saved_listings_screen.dart';
import 'features/auth/presentation/forgot_password_screen.dart';
import 'features/auth/presentation/reset_password_screen.dart';
import 'features/auth/presentation/verify_email_pending_screen.dart';
import 'features/profile/data/profile_repository.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'features/search/data/repositories/search_repository.dart';
import 'features/search/presentation/bloc/search_bloc.dart';
import 'features/search/presentation/screens/map_screen.dart';
import 'features/search/presentation/screens/all_results_screen.dart';
import 'features/marketplace/presentation/screens/listing_details_screen.dart';
import 'features/landlord_features/presentation/screens/create_listing_screen.dart';
import 'features/landlord_features/presentation/screens/landlord_dashboard_screen.dart';
import 'features/landlord_features/presentation/screens/manage_listings_screen.dart';
import 'features/landlord_features/presentation/screens/landlord_details_screen.dart';
import 'features/search/data/models/search_result.dart';
import 'features/profile/presentation/screens/apply_landlord_screen.dart';
import 'features/tenant_dashboard/presentation/screens/tenant_dashboard_screen.dart';
import 'features/admin_features/presentation/screens/admin_dashboard_screen.dart';
import 'features/admin_features/presentation/screens/verification_list_screen.dart';
import 'features/admin_features/presentation/screens/verification_detail_screen.dart';
import 'features/admin_features/data/admin_repository.dart';

import 'features/tenant_dashboard/presentation/screens/property_review_screen.dart';
import 'features/profile/presentation/screens/settings/account_security_screen.dart';
import 'features/profile/presentation/screens/settings/notification_settings_screen.dart';
import 'features/profile/presentation/screens/settings/payment_methods_screen.dart';
import 'features/profile/presentation/screens/settings/help_support_screen.dart';
import 'features/marketplace/domain/listing_entity.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:firebase_core/firebase_core.dart';
import 'core/services/notification_service.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Custom Error Handling to make app errors stand out from system logs
  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.presentError(details);
    debugPrint('\n\x1B[31m==================================================\x1B[0m');
    debugPrint('\x1B[31m⚠️  KEJAPIN APP ERROR: ${details.exception}\x1B[0m');
    debugPrint('\x1B[31m${details.stack}\x1B[0m');
    debugPrint('\x1B[31m==================================================\x1B[0m\n');
  };

  await Supabase.initialize(
    url: 'https://jxdanbsfcjkuvrakvnoa.supabase.co',
    anonKey: 'sb_publishable_b7AgK9iw5qof-ZuBTDVyHg_FeNHRxox',
  );

  // Initialize Firebase (Catch if not configured yet)
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    await NotificationService().initialize();
  } catch (e) {
    debugPrint("Firebase not initialized: $e");
    debugPrint("Please run 'flutterfire configure' to set up notifications.");
  }

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
      } else if (event == AuthChangeEvent.signedIn) {
        NotificationService().listenToRealtimeNotifications();
        if (data.session?.user != null) {
          _syncProfilePicture(data.session!.user);
        }
      }
    });

    // Sync profile for already logged-in users on startup
    final user = Supabase.instance.client.auth.currentUser;
    if (user != null) {
      _syncProfilePicture(user);
    }
  }

  Future<void> _syncProfilePicture(User user) async {
    try {
      final sb = Supabase.instance.client;
      final profile = await sb.from('users').select('profile_picture').eq('id', user.id).single();
      
      if (profile['profile_picture'] == null) {
        final avatarUrl = user.userMetadata?['avatar_url'] ?? user.userMetadata?['picture'];
        if (avatarUrl != null) {
          await sb.from('users').update({'profile_picture': avatarUrl}).eq('id', user.id);
        }
      }
    } catch (e) {
      debugPrint("Error syncing profile picture: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => LocaleProvider()),
      ],
      child: RepositoryProvider(
        create: (context) => SupabaseSearchRepository(),
        child: BlocProvider(
          create: (context) => SearchBloc(context.read<SupabaseSearchRepository>()),
          child: Consumer<LocaleProvider>(
            builder: (context, localeProvider, child) {
              return MaterialApp.router(
                title: 'kejapin',
                theme: AppTheme.lightTheme,
                routerConfig: _router,
                debugShowCheckedModeBanner: false,
                locale: localeProvider.locale,
                localizationsDelegates: [
                  AppLocalizations.delegate,
                  GlobalMaterialLocalizations.delegate,
                  GlobalWidgetsLocalizations.delegate,
                  GlobalCupertinoLocalizations.delegate,
                ],
                supportedLocales: const [
                  Locale('en'), // English
                  Locale('sw'), // Swahili Sanifu
                  Locale('sw', 'KE'), // Swahili Kenyan
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>();

final GoRouter _router = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) {
        if (kIsWeb) return const LandingPage();
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
          routes: [
            GoRoute(
              path: 'edit',
              builder: (context, state) {
                final profile = state.extra as UserProfile;
                return EditProfileScreen(profile: profile);
              },
            ),
          ],
        ),
        GoRoute(
          path: '/saved',
          builder: (context, state) => const SavedListingsScreen(),
        ),
        GoRoute(
          path: '/settings',
          builder: (context, state) => const SettingsScreen(),
        ),
        GoRoute(
          path: '/tenant-dashboard',
          builder: (context, state) => const TenantDashboardScreen(),
        ),
        GoRoute(
          path: '/landlord-dashboard',
          builder: (context, state) => const LandlordDashboardScreen(),
        ),
        GoRoute(
          path: '/manage-listings',
          builder: (context, state) => const ManageListingsScreen(),
        ),
        GoRoute(
          path: '/create-listing',
          builder: (context, state) {
            final listing = state.extra as ListingEntity?;
            return CreateListingScreen(existingListing: listing);
          },
        ),
        GoRoute(
          path: '/admin-dashboard',
          builder: (context, state) => const AdminDashboardScreen(),
        ),
        GoRoute(
          path: '/apply-landlord',
          builder: (context, state) => const ApplyLandlordScreen(),
        ),
        GoRoute(
          path: '/gallery',
          builder: (context, state) => const ComponentGalleryScreen(),
        ),
        GoRoute(
          path: '/admin/verifications',
          builder: (context, state) => const VerificationListScreen(),
        ),
        GoRoute(
          path: '/admin/verifications/detail',
          builder: (context, state) {
            final app = state.extra as VerificationApplication;
            return VerificationDetailScreen(application: app);
          },
        ),
        GoRoute(
          path: '/review/:id',
          builder: (context, state) {
            final id = state.pathParameters['id']!;
            final name = state.uri.queryParameters['name'] ?? 'Property';
            return PropertyReviewScreen(propertyId: id, propertyName: name);
          },
        ),
        GoRoute(
          path: '/notifications',
          builder: (context, state) => const NotificationsScreen(),
        ),
        GoRoute(
          path: '/settings/security',
          builder: (context, state) => const AccountSecurityScreen(),
        ),
        GoRoute(
          path: '/settings/notifications',
          builder: (context, state) => const NotificationSettingsScreen(),
        ),
        GoRoute(
          path: '/settings/payment',
          builder: (context, state) => const PaymentMethodsScreen(),
        ),
        GoRoute(
          path: '/settings/help',
          builder: (context, state) => const HelpSupportScreen(),
        ),
      ],
    ),
    // Chat Route (Outside shell for full-screen immersive chat without bottom nav)
    GoRoute(
      path: '/chat',
      builder: (context, state) {
        final extras = state.extra as Map<String, dynamic>;
        return ChatScreen(
          otherUserId: extras['otherUserId'],
          otherUserName: extras['otherUserName'],
          avatarUrl: extras['avatarUrl'],
          propertyTitle: extras['propertyTitle'],
          propertyId: extras['propertyId'],
        );
      },
    ),
    GoRoute(
      path: '/debug-chat',
      builder: (context, state) => const DebugMessagesScreen(),
    ),
    // Search & Details Routes (Outside shell for full-screen feel)
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
        final initialView = map?['initialView'] as String? ?? 'image';
        return ListingDetailsScreen(id: id, activeViewMode: initialView);
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

