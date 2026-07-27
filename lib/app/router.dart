import 'package:flutter/material.dart';
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

// ── Transition helpers ────────────────────────────────────────────────────────

/// Slide in from the right with a subtle parallax fade on the previous screen.
Page<void> _slideRight(GoRouterState state, Widget child) =>
    CustomTransitionPage<void>(
      key: state.pageKey,
      child: child,
      transitionDuration: const Duration(milliseconds: 360),
      reverseTransitionDuration: const Duration(milliseconds: 280),
      transitionsBuilder: (_, animation, secondaryAnimation, child) {
        final curve = CurvedAnimation(parent: animation, curve: Curves.easeOutCubic);
        final secondary = CurvedAnimation(parent: secondaryAnimation, curve: Curves.easeInCubic);
        return SlideTransition(
          position: Tween<Offset>(begin: const Offset(1.0, 0), end: Offset.zero).animate(curve),
          child: SlideTransition(
            position: Tween<Offset>(begin: Offset.zero, end: const Offset(-0.08, 0)).animate(secondary),
            child: FadeTransition(
              opacity: Tween<double>(begin: 0.4, end: 1).animate(curve),
              child: child,
            ),
          ),
        );
      },
    );

/// Fade + gentle scale-up — feels like arriving at a destination.
Page<void> _fadeScale(GoRouterState state, Widget child) =>
    CustomTransitionPage<void>(
      key: state.pageKey,
      child: child,
      transitionDuration: const Duration(milliseconds: 420),
      reverseTransitionDuration: const Duration(milliseconds: 300),
      transitionsBuilder: (_, animation, _, child) {
        final curve = CurvedAnimation(parent: animation, curve: Curves.easeOutCubic);
        return FadeTransition(
          opacity: Tween<double>(begin: 0.0, end: 1).animate(curve),
          child: ScaleTransition(
            scale: Tween<double>(begin: 0.90, end: 1).animate(curve),
            child: child,
          ),
        );
      },
    );

/// Slide up from the bottom — panels & modals feel.
Page<void> _slideUp(GoRouterState state, Widget child) =>
    CustomTransitionPage<void>(
      key: state.pageKey,
      child: child,
      transitionDuration: const Duration(milliseconds: 420),
      reverseTransitionDuration: const Duration(milliseconds: 300),
      transitionsBuilder: (_, animation, _, child) {
        final curve = CurvedAnimation(parent: animation, curve: Curves.easeOutCubic);
        return SlideTransition(
          position: Tween<Offset>(begin: const Offset(0, 1.0), end: Offset.zero).animate(curve),
          child: FadeTransition(
            opacity: Tween<double>(begin: 0.0, end: 1).animate(
              CurvedAnimation(parent: animation, curve: const Interval(0, 0.5, curve: Curves.easeOut)),
            ),
            child: child,
          ),
        );
      },
    );

/// Dramatic scale + fade — for celebration / success moments.
Page<void> _celebrationReveal(GoRouterState state, Widget child) =>
    CustomTransitionPage<void>(
      key: state.pageKey,
      child: child,
      transitionDuration: const Duration(milliseconds: 500),
      reverseTransitionDuration: const Duration(milliseconds: 350),
      transitionsBuilder: (_, animation, _, child) {
        final curve = CurvedAnimation(parent: animation, curve: Curves.easeOutBack);
        return FadeTransition(
          opacity: CurvedAnimation(parent: animation, curve: const Interval(0, 0.5, curve: Curves.easeOut)),
          child: ScaleTransition(
            scale: Tween<double>(begin: 0.75, end: 1).animate(curve),
            child: child,
          ),
        );
      },
    );

// ── Router ────────────────────────────────────────────────────────────────────

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
    redirect: (context, state) {
      final authState = ref.read(authStateProvider);
      final status = authState.status;

      if (state.matchedLocation == '/') return null;

      final isAuthPath = state.matchedLocation.startsWith('/auth');
      if (status == AuthStatus.unauthenticated || status == AuthStatus.initial) {
        return isAuthPath ? null : '/auth';
      }
      if (status == AuthStatus.needsProfileSetup) return '/auth/setup';

      if (status == AuthStatus.authenticated) {
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
        pageBuilder: (context, state) => _fadeScale(state, const SplashScreen()),
      ),
      GoRoute(
        path: '/auth',
        pageBuilder: (context, state) => _fadeScale(state, const PhoneAuthScreen()),
        routes: [
          GoRoute(
            path: 'otp',
            pageBuilder: (context, state) {
              final phone = state.extra as String? ?? '';
              return _slideRight(state, OtpScreen(phoneNumber: phone));
            },
          ),
          GoRoute(
            path: 'setup',
            pageBuilder: (context, state) => _slideRight(state, const ProfileSetupScreen()),
          ),
        ],
      ),
      GoRoute(
        path: '/church-select',
        pageBuilder: (context, state) => _slideUp(state, const ChurchSelectionScreen()),
      ),
      GoRoute(
        path: '/home',
        pageBuilder: (context, state) => _fadeScale(state, const HomeScreen()),
      ),
      GoRoute(
        path: '/contribute',
        pageBuilder: (context, state) => _slideUp(state, const ContributeScreen()),
        routes: [
          GoRoute(
            path: 'amount',
            pageBuilder: (context, state) {
              final type = state.extra as String? ?? 'asrat';
              return _slideRight(state, AmountEntryScreen(contributionType: type));
            },
          ),
        ],
      ),
      GoRoute(
        path: '/payment/method',
        pageBuilder: (context, state) {
          final extra = state.extra as Map<String, dynamic>? ?? {};
          return _slideRight(
            state,
            PaymentMethodScreen(
              amount: extra['amount'] as double? ?? 0.0,
              type: extra['type'] as String? ?? 'asrat',
              note: extra['note'] as String?,
            ),
          );
        },
      ),
      GoRoute(
        path: '/payment/success',
        pageBuilder: (context, state) {
          final extra = state.extra as Map<String, dynamic>? ?? {};
          return _celebrationReveal(
            state,
            PaymentSuccessScreen(
              receiptNo: extra['receiptNo'] as String? ?? '',
              amount: extra['amount'] as double? ?? 0.0,
              type: extra['type'] as String? ?? 'asrat',
            ),
          );
        },
      ),
      GoRoute(
        path: '/history',
        pageBuilder: (context, state) => _slideRight(state, const HistoryScreen()),
        routes: [
          GoRoute(
            path: 'receipt',
            pageBuilder: (context, state) {
              final extra = state.extra as Map<String, dynamic>? ?? {};
              return _slideUp(
                state,
                ReceiptScreen(
                  txId: extra['txId'] as String? ?? '',
                  amount: extra['amount'] as double? ?? 0.0,
                  type: extra['type'] as String? ?? 'asrat',
                  receiptNo: extra['receiptNo'] as String? ?? '',
                  date: extra['date'] as DateTime? ?? DateTime.now(),
                ),
              );
            },
          ),
        ],
      ),
      GoRoute(
        path: '/profile',
        pageBuilder: (context, state) => _slideRight(state, const ProfileScreen()),
      ),
      GoRoute(
        path: '/notifications',
        pageBuilder: (context, state) => _slideRight(state, const NotificationsScreen()),
      ),
    ],
  );
});
