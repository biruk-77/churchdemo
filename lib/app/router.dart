import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:church/features/auth/presentation/providers/auth_provider.dart';
import 'package:church/features/auth/presentation/screens/splash_screen.dart';
import 'package:church/features/auth/presentation/screens/phone_auth_screen.dart';
import 'package:church/features/auth/presentation/screens/otp_screen.dart';
import 'package:church/features/auth/presentation/screens/profile_setup_screen.dart';
import 'package:church/features/church/presentation/screens/church_selection_screen.dart';
import 'package:church/features/home/presentation/screens/home_screen.dart';
import 'package:church/features/contributions/presentation/screens/contribute_screen.dart';
import 'package:church/features/contributions/presentation/screens/amount_entry_screen.dart';
import 'package:church/features/payment/presentation/screens/payment_method_screen.dart';
import 'package:church/features/payment/presentation/screens/payment_success_screen.dart';
import 'package:church/features/history/presentation/screens/history_screen.dart';
import 'package:church/features/history/presentation/screens/receipt_screen.dart';
import 'package:church/features/profile/presentation/screens/profile_screen.dart';
import 'package:church/features/notifications/presentation/screens/notifications_screen.dart';

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
    redirect: (context, state) {
      final authState = ref.read(authStateProvider);
      final status = authState.status;

      // Skip redirect on splash
      if (state.matchedLocation == '/') return null;

      // Allow auth routes if not logged in
      final isAuthPath = state.matchedLocation.startsWith('/auth');
      if (status == AuthStatus.unauthenticated || status == AuthStatus.initial) {
        return isAuthPath ? null : '/auth';
      }

      if (status == AuthStatus.needsProfileSetup) {
        return '/auth/setup';
      }

      if (status == AuthStatus.authenticated) {
        // Don't gate payment/success — user already paid, always let them through
        const noChurchGate = ['/payment/success', '/payment/method', '/church-select'];
        final loc = state.matchedLocation;
        if (authState.user?.churchId == null && !noChurchGate.any(loc.startsWith)) {
          return '/church-select';
        }
        if (isAuthPath || (loc == '/church-select' && authState.user?.churchId != null)) {
          return '/home';
        }
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/auth',
        builder: (context, state) => const PhoneAuthScreen(),
        routes: [
          GoRoute(
            path: 'otp',
            builder: (context, state) {
              final phone = state.extra as String? ?? '';
              return OtpScreen(phoneNumber: phone);
            },
          ),
          GoRoute(
            path: 'setup',
            builder: (context, state) => const ProfileSetupScreen(),
          ),
        ],
      ),
      GoRoute(
        path: '/church-select',
        builder: (context, state) => const ChurchSelectionScreen(),
      ),
      GoRoute(
        path: '/home',
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: '/contribute',
        builder: (context, state) => const ContributeScreen(),
        routes: [
          GoRoute(
            path: 'amount',
            builder: (context, state) {
              final type = state.extra as String? ?? 'asrat';
              return AmountEntryScreen(contributionType: type);
            },
          ),
        ],
      ),
      GoRoute(
        path: '/payment/method',
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>? ?? {};
          return PaymentMethodScreen(
            amount: extra['amount'] as double? ?? 0.0,
            type: extra['type'] as String? ?? 'asrat',
            note: extra['note'] as String?,
          );
        },
      ),
      GoRoute(
        path: '/payment/success',
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>? ?? {};
          return PaymentSuccessScreen(
            receiptNo: extra['receiptNo'] as String? ?? '',
            amount: extra['amount'] as double? ?? 0.0,
            type: extra['type'] as String? ?? 'asrat',
          );
        },
      ),
      GoRoute(
        path: '/history',
        builder: (context, state) => const HistoryScreen(),
        routes: [
          GoRoute(
            path: 'receipt',
            builder: (context, state) {
              final extra = state.extra as Map<String, dynamic>? ?? {};
              return ReceiptScreen(
                txId: extra['txId'] as String? ?? '',
                amount: extra['amount'] as double? ?? 0.0,
                type: extra['type'] as String? ?? 'asrat',
                receiptNo: extra['receiptNo'] as String? ?? '',
                date: extra['date'] as DateTime? ?? DateTime.now(),
              );
            },
          ),
        ],
      ),
      GoRoute(
        path: '/profile',
        builder: (context, state) => const ProfileScreen(),
      ),
      GoRoute(
        path: '/notifications',
        builder: (context, state) => const NotificationsScreen(),
      ),
    ],
  );
});
