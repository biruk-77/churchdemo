import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:church/features/auth/data/auth_repository.dart';
import 'package:church/features/auth/data/user_model.dart';
import 'package:church/features/notifications/data/notification_service.dart';

// ── Session persistence keys ───────────────────────────────────────────────────
const _kSessionUid      = 'session_uid';
const _kSessionPhone    = 'session_phone';
const _kSessionName     = 'session_name';
const _kSessionEmail    = 'session_email';
const _kSessionChurchId = 'session_church_id';
const _kSessionStatus   = 'session_status';

// ── Debug mock config ─────────────────────────────────────────────────────────
// In DEBUG builds, any phone number is accepted and a random 6-digit OTP is
// delivered via local push notification instead of SMS.
// Disabled automatically in release builds.
const _kMockVerificationId = '__DEBUG_MOCK__';

String _generateDebugOtp() {
  final rng = Random.secure();
  return (100000 + rng.nextInt(900000)).toString();
}

enum AuthStatus {
  initial,
  unauthenticated,
  codeSent,
  authenticating,
  authenticated,
  needsProfileSetup,
  error
}

class AuthState {
  final AuthStatus status;
  final UserModel? user;
  final String? verificationId;
  final String? errorMessage;
  final bool isLoading;

  const AuthState({
    required this.status,
    this.user,
    this.verificationId,
    this.errorMessage,
    this.isLoading = false,
  });

  AuthState copyWith({
    AuthStatus? status,
    UserModel? user,
    String? verificationId,
    String? errorMessage,
    bool? isLoading,
  }) {
    return AuthState(
      status:         status         ?? this.status,
      user:           user           ?? this.user,
      verificationId: verificationId ?? this.verificationId,
      errorMessage:   errorMessage   ?? this.errorMessage,
      isLoading:      isLoading      ?? this.isLoading,
    );
  }
}

final authRepositoryProvider = Provider<AuthRepository>((ref) => AuthRepository());

final authStateProvider =
    NotifierProvider<AuthNotifier, AuthState>(AuthNotifier.new);

class AuthNotifier extends Notifier<AuthState> {
  late final AuthRepository _authRepository;
  late final NotificationService _notificationService;

  // Stored so verifyOtp can build the mock UserModel
  String? _pendingPhone;

  // Random 6-digit code generated fresh for each sendOtp call in debug mode
  String _currentMockOtp = '000000';

  @override
  AuthState build() {
    _authRepository = ref.read(authRepositoryProvider);
    _notificationService = ref.read(notificationServiceProvider);
    _listenToAuthChanges();
    _restoreSession();
    return const AuthState(status: AuthStatus.initial);
  }

  // ── Session helpers ────────────────────────────────────────────────────────

  Future<void> _restoreSession() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final uid   = prefs.getString(_kSessionUid);
      final phone = prefs.getString(_kSessionPhone);
      if (uid == null || phone == null) return;

      final name     = prefs.getString(_kSessionName) ?? '';
      final email    = prefs.getString(_kSessionEmail);
      final churchId = prefs.getString(_kSessionChurchId);
      final statusStr = prefs.getString(_kSessionStatus);

      UserModel? profile;
      try {
        profile = await _authRepository.getUserProfile(uid);
      } catch (_) {}

      profile ??= UserModel(
        uid:         uid,
        phone:       phone,
        displayName: name,
        email:       email,
        churchId:    churchId,
        role:        'member',
      );

      final status = (statusStr == 'needsProfileSetup' || profile.displayName.isEmpty)
          ? AuthStatus.needsProfileSetup
          : AuthStatus.authenticated;

      state = AuthState(status: status, user: profile);
      _notificationService.startBroadcastListener(userChurchId: profile.churchId);
      debugPrint('[AuthSession] Session restored uid=$uid name="$name" churchId=$churchId status=$status');
    } catch (e) {
      debugPrint('[AuthSession] Session restore failed: $e');
    }
  }

  Future<void> _saveSession(UserModel user, AuthStatus status) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_kSessionUid, user.uid);
      await prefs.setString(_kSessionPhone, user.phone);
      await prefs.setString(_kSessionName, user.displayName);
      if (user.email != null && user.email!.isNotEmpty) {
        await prefs.setString(_kSessionEmail, user.email!);
      } else {
        await prefs.remove(_kSessionEmail);
      }
      if (user.churchId != null && user.churchId!.isNotEmpty) {
        await prefs.setString(_kSessionChurchId, user.churchId!);
      } else {
        await prefs.remove(_kSessionChurchId);
      }
      await prefs.setString(_kSessionStatus, status.name);
      debugPrint('[AuthSession] Session saved for uid=${user.uid}, status=${status.name}');
    } catch (e) {
      debugPrint('[AuthSession] Save error: $e');
    }
  }

  Future<void> _clearSession() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_kSessionUid);
      await prefs.remove(_kSessionPhone);
      await prefs.remove(_kSessionName);
      await prefs.remove(_kSessionEmail);
      await prefs.remove(_kSessionChurchId);
      await prefs.remove(_kSessionStatus);
      debugPrint('[AuthSession] Session cleared');
    } catch (_) {}
  }

  void _listenToAuthChanges() {
    _authRepository.authStateChanges.listen((User? firebaseUser) async {
      // Don't override state if session is already active, loading, or in mock auth flow
      if (state.isLoading) return;
      if (state.verificationId == _kMockVerificationId) return;
      if (state.status == AuthStatus.authenticated || state.status == AuthStatus.needsProfileSetup) {
        return;
      }

      if (firebaseUser == null) {
        if (state.user == null) {
          state = const AuthState(status: AuthStatus.unauthenticated);
        }
      } else {
        state = state.copyWith(isLoading: true);
        UserModel? profile;
        try {
          profile = await _authRepository.getUserProfile(firebaseUser.uid);
        } catch (_) {}

        final user = profile ?? UserModel(
          uid:         firebaseUser.uid,
          displayName: '',
          phone:       firebaseUser.phoneNumber ?? '',
          role:        'member',
        );

        final status = (profile == null || profile.displayName.isEmpty)
            ? AuthStatus.needsProfileSetup
            : AuthStatus.authenticated;

        state = AuthState(status: status, user: user);
        await _saveSession(user, status);
      }
    });
  }

  // ── Send OTP ───────────────────────────────────────────────────────────────

  Future<void> sendOtp(String phone) async {
    _pendingPhone = phone;
    state = state.copyWith(isLoading: true, errorMessage: null);

    // ── DEBUG MOCK ─────────────────────────────────────────────────────────
    if (kDebugMode) {
      // Generate a fresh random 6-digit code every time
      _currentMockOtp = _generateDebugOtp();
      await Future.delayed(const Duration(milliseconds: 500));
      state = state.copyWith(
        status:         AuthStatus.codeSent,
        verificationId: _kMockVerificationId,
        isLoading:      false,
      );
      // Fire a real local push notification with the code
      await _notificationService.showOtpNotification(
        phone: phone,
        code:  _currentMockOtp,
      );
      debugPrint('[AuthMock] OTP for $phone → $_currentMockOtp  (also sent as push notification)');
      return;
    }
    // ── END DEBUG MOCK ─────────────────────────────────────────────────────

    try {
      await _authRepository.verifyPhone(
        phoneNumber: phone,
        codeSent: (verificationId, resendToken) {
          state = state.copyWith(
            status:         AuthStatus.codeSent,
            verificationId: verificationId,
            isLoading:      false,
          );
          // Notify the user that an SMS code was sent (no code revealed)
          _notificationService.showCodeSentConfirmation(phone: phone);
        },
        verificationFailed: (e) {
          state = state.copyWith(
            status:       AuthStatus.unauthenticated,
            errorMessage: e.message ?? 'Verification failed',
            isLoading:    false,
          );
        },
        verificationCompleted: (credential) async {
          await _authRepository.signInWithCredential(credential);
        },
        codeAutoRetrievalTimeout: (verificationId) {
          state = state.copyWith(verificationId: verificationId);
        },
      );
    } catch (e) {
      state = state.copyWith(
        status:       AuthStatus.unauthenticated,
        errorMessage: e.toString(),
        isLoading:    false,
      );
    }
  }

  // ── Verify OTP ─────────────────────────────────────────────────────────────

  Future<void> verifyOtp(String smsCode) async {
    final verId = state.verificationId;
    if (verId == null) {
      state = state.copyWith(errorMessage: 'Verification ID missing');
      return;
    }

    state = state.copyWith(isLoading: true, errorMessage: null);

    // ── DEBUG MOCK ─────────────────────────────────────────────────────────
    if (kDebugMode && verId == _kMockVerificationId) {
      if (smsCode != _currentMockOtp) {
        state = state.copyWith(
          status:       AuthStatus.codeSent,
          errorMessage: 'Wrong code — check your notification for the code.',
          isLoading:    false,
        );
        return;
      }

      await Future.delayed(const Duration(milliseconds: 300));
      final phone = _pendingPhone ?? '+251000000000';
      final clean = phone.replaceAll(RegExp(r'[^\d]'), '');
      
      String uid = 'debug_$clean';
      try {
        final cred = await FirebaseAuth.instance.signInAnonymously();
        if (cred.user != null) {
          uid = cred.user!.uid;
        }
      } catch (e) {
        debugPrint('[AuthMock] Anonymous sign-in failed: $e. Falling back to email sign-in...');
        try {
          final email = 'phone_$clean@demo.com';
          const password = 'PhoneDemoPassword123!';
          UserCredential cred;
          try {
            cred = await FirebaseAuth.instance.signInWithEmailAndPassword(
              email: email,
              password: password,
            );
          } on FirebaseAuthException catch (authErr) {
            if (authErr.code == 'user-not-found' || authErr.code == 'invalid-credential') {
              cred = await FirebaseAuth.instance.createUserWithEmailAndPassword(
                email: email,
                password: password,
              );
            } else {
              rethrow;
            }
          }
          if (cred.user != null) {
            uid = cred.user!.uid;
          }
        } catch (fallbackError) {
          debugPrint('[AuthMock] Phone-email fallback registration failed: $fallbackError');
        }
      }

      // Re-use existing profile if already created, otherwise prompt setup
      UserModel? existing;
      try {
        existing = await _authRepository.getUserProfile(uid);
      } catch (_) {}

      // If Firestore is unavailable, fall back to the persisted session
      if (existing == null) {
        final prefs = await SharedPreferences.getInstance();
        final savedName = prefs.getString(_kSessionName) ?? '';
        final savedChurch = prefs.getString(_kSessionChurchId);
        if (savedName.isNotEmpty) {
          existing = UserModel(
            uid: uid,
            phone: phone,
            displayName: savedName,
            email: prefs.getString(_kSessionEmail),
            churchId: savedChurch,
            role: 'member',
          );
        }
      }

      if (existing != null && existing.displayName.isNotEmpty) {
        state = AuthState(status: AuthStatus.authenticated, user: existing);
        await _saveSession(existing, AuthStatus.authenticated);
      } else {
        final newUser = UserModel(uid: uid, displayName: '', phone: phone, role: 'member');
        state = AuthState(status: AuthStatus.needsProfileSetup, user: newUser);
        await _saveSession(newUser, AuthStatus.needsProfileSetup);
      }
      // Dismiss the OTP notification now that the code was accepted
      await _notificationService.dismissOtpNotification();
      debugPrint('[AuthMock] Signed in as mock user uid=$uid');
      return;
    }
    // ── END DEBUG MOCK ─────────────────────────────────────────────────────

    try {
      final credential = PhoneAuthProvider.credential(
        verificationId: verId,
        smsCode:        smsCode,
      );
      await _authRepository.signInWithCredential(credential);
    } catch (e) {
      state = state.copyWith(
        status:       AuthStatus.codeSent,
        errorMessage: e.toString(),
        isLoading:    false,
      );
    }
  }

  // ── Profile / Church ───────────────────────────────────────────────────────

  Future<void> completeProfile(String displayName, String? email) async {
    final currentUser = state.user;
    if (currentUser == null) return;
    state = state.copyWith(isLoading: true);
    try {
      final updatedUser = currentUser.copyWith(
        displayName: displayName,
        email:       email,
        createdAt:   DateTime.now(),
      );
      await _authRepository.saveUserProfile(updatedUser).catchError((e) {
        debugPrint('[AuthRepository] Firestore save profile note: $e');
      });
      state = AuthState(status: AuthStatus.authenticated, user: updatedUser);
      await _saveSession(updatedUser, AuthStatus.authenticated);
    } catch (e) {
      state = state.copyWith(
        status:       AuthStatus.needsProfileSetup,
        errorMessage: e.toString(),
        isLoading:    false,
      );
    }
  }

  Future<void> selectChurch(String churchId) async {
    final currentUser = state.user;
    if (currentUser == null) return;
    state = state.copyWith(isLoading: true);
    try {
      await _authRepository.updateChurchAssociation(currentUser.uid, churchId).catchError((e) {
        debugPrint('[AuthRepository] Firestore update church note: $e');
      });
      final updatedUser = currentUser.copyWith(churchId: churchId);
      state = state.copyWith(
        user:      updatedUser,
        isLoading: false,
      );
      await _saveSession(updatedUser, state.status);
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  Future<void> signUpWithEmail(String displayName, String email, String password) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final credential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      final firebaseUser = credential.user;
      if (firebaseUser != null) {
        final user = UserModel(
          uid:         firebaseUser.uid,
          displayName: displayName.trim(),
          email:       email.trim(),
          phone:       '',
          role:        'member',
          createdAt:   DateTime.now(),
        );

        await _authRepository.saveUserProfile(user).catchError((e) {
          debugPrint('[AuthRepository] saveUserProfile failed: $e');
        });

        state = AuthState(status: AuthStatus.authenticated, user: user);
        await _saveSession(user, AuthStatus.authenticated);
        _notificationService.startBroadcastListener(userChurchId: user.churchId);
      }
    } catch (e) {
      state = state.copyWith(
        status:       AuthStatus.unauthenticated,
        errorMessage: e.toString(),
        isLoading:    false,
      );
    }
  }

  Future<void> signInWithEmail(String email, String password) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      UserCredential credential;
      try {
        credential = await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: email.trim(),
          password: password,
        );
      } on FirebaseAuthException catch (authErr) {
        if (authErr.code == 'user-not-found' || authErr.code == 'invalid-credential') {
          credential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
            email: email.trim(),
            password: password,
          );
        } else {
          rethrow;
        }
      }

      final firebaseUser = credential.user;
      if (firebaseUser != null) {
        UserModel? profile;
        try {
          profile = await _authRepository.getUserProfile(firebaseUser.uid);
        } catch (_) {}

        final user = profile ?? UserModel(
          uid:         firebaseUser.uid,
          displayName: email.split('@')[0],
          email:       email.trim(),
          phone:       '',
          role:        'member',
        );

        final status = (profile == null || profile.displayName.isEmpty)
            ? AuthStatus.needsProfileSetup
            : AuthStatus.authenticated;

        state = AuthState(status: status, user: user);
        await _saveSession(user, status);
        _notificationService.startBroadcastListener(userChurchId: user.churchId);
      }
    } catch (e) {
      state = state.copyWith(
        status:       AuthStatus.unauthenticated,
        errorMessage: e.toString(),
        isLoading:    false,
      );
    }
  }

  Future<void> signInWithGoogle() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      // For demo, authenticate with Google Mock Email
      const email = 'google_demo_user@demo.com';
      const password = 'GoogleDemoPassword123!';
      
      UserCredential credential;
      try {
        credential = await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: email,
          password: password,
        );
      } on FirebaseAuthException catch (authErr) {
        if (authErr.code == 'user-not-found' || authErr.code == 'invalid-credential') {
          credential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
            email: email,
            password: password,
          );
        } else {
          rethrow;
        }
      }

      final firebaseUser = credential.user;
      if (firebaseUser != null) {
        UserModel? profile;
        try {
          profile = await _authRepository.getUserProfile(firebaseUser.uid);
        } catch (_) {}

        final user = profile ?? UserModel(
          uid:         firebaseUser.uid,
          displayName: 'Google Demo User',
          email:       email,
          phone:       '',
          role:        'member',
        );

        final status = (profile == null || profile.displayName.isEmpty)
            ? AuthStatus.needsProfileSetup
            : AuthStatus.authenticated;

        state = AuthState(status: status, user: user);
        await _saveSession(user, status);
        _notificationService.startBroadcastListener(userChurchId: user.churchId);
      }
    } catch (e) {
      state = state.copyWith(
        status:       AuthStatus.unauthenticated,
        errorMessage: e.toString(),
        isLoading:    false,
      );
    }
  }

  Future<void> signInWithFacebook() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      // For demo, authenticate with Facebook Mock Email
      const email = 'facebook_demo_user@demo.com';
      const password = 'FacebookDemoPassword123!';
      
      UserCredential credential;
      try {
        credential = await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: email,
          password: password,
        );
      } on FirebaseAuthException catch (authErr) {
        if (authErr.code == 'user-not-found' || authErr.code == 'invalid-credential') {
          credential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
            email: email,
            password: password,
          );
        } else {
          rethrow;
        }
      }

      final firebaseUser = credential.user;
      if (firebaseUser != null) {
        UserModel? profile;
        try {
          profile = await _authRepository.getUserProfile(firebaseUser.uid);
        } catch (_) {}

        final user = profile ?? UserModel(
          uid:         firebaseUser.uid,
          displayName: 'Facebook Demo User',
          email:       email,
          phone:       '',
          role:        'member',
        );

        final status = (profile == null || profile.displayName.isEmpty)
            ? AuthStatus.needsProfileSetup
            : AuthStatus.authenticated;

        state = AuthState(status: status, user: user);
        await _saveSession(user, status);
        _notificationService.startBroadcastListener(userChurchId: user.churchId);
      }
    } catch (e) {
      state = state.copyWith(
        status:       AuthStatus.unauthenticated,
        errorMessage: e.toString(),
        isLoading:    false,
      );
    }
  }

  Future<void> signOut() async {
    _pendingPhone = null;
    await _clearSession();
    await _authRepository.signOut().catchError((_) {});
    state = const AuthState(status: AuthStatus.unauthenticated);
  }
}
