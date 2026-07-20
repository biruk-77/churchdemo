import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:church/features/auth/data/auth_repository.dart';
import 'package:church/features/auth/data/user_model.dart';

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
      status: status ?? this.status,
      user: user ?? this.user,
      verificationId: verificationId ?? this.verificationId,
      errorMessage: errorMessage ?? this.errorMessage,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository();
});

final authStateProvider = NotifierProvider<AuthNotifier, AuthState>(AuthNotifier.new);

class AuthNotifier extends Notifier<AuthState> {
  late final AuthRepository _authRepository;

  @override
  AuthState build() {
    _authRepository = ref.read(authRepositoryProvider);
    _listenToAuthChanges();
    return const AuthState(status: AuthStatus.initial);
  }

  void _listenToAuthChanges() {
    _authRepository.authStateChanges.listen((User? firebaseUser) async {
      if (firebaseUser == null) {
        state = const AuthState(status: AuthStatus.unauthenticated);
      } else {
        state = state.copyWith(isLoading: true);
        final profile = await _authRepository.getUserProfile(firebaseUser.uid);
        if (profile == null) {
          state = AuthState(
            status: AuthStatus.needsProfileSetup,
            user: UserModel(
              uid: firebaseUser.uid,
              displayName: '',
              phone: firebaseUser.phoneNumber ?? '',
              role: 'member',
            ),
          );
        } else {
          state = AuthState(status: AuthStatus.authenticated, user: profile);
        }
      }
    });
  }

  Future<void> sendOtp(String phone) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      await _authRepository.verifyPhone(
        phoneNumber: phone,
        codeSent: (verificationId, resendToken) {
          state = state.copyWith(
            status: AuthStatus.codeSent,
            verificationId: verificationId,
            isLoading: false,
          );
        },
        verificationFailed: (e) {
          state = state.copyWith(
            status: AuthStatus.unauthenticated,
            errorMessage: e.message ?? 'Verification failed',
            isLoading: false,
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
        status: AuthStatus.unauthenticated,
        errorMessage: e.toString(),
        isLoading: false,
      );
    }
  }

  Future<void> verifyOtp(String smsCode) async {
    final verId = state.verificationId;
    if (verId == null) {
      state = state.copyWith(errorMessage: 'Verification ID missing');
      return;
    }
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final credential = PhoneAuthProvider.credential(
        verificationId: verId,
        smsCode: smsCode,
      );
      await _authRepository.signInWithCredential(credential);
    } catch (e) {
      state = state.copyWith(
        status: AuthStatus.codeSent,
        errorMessage: e.toString(),
        isLoading: false,
      );
    }
  }

  Future<void> completeProfile(String displayName, String? email) async {
    final currentUser = state.user;
    if (currentUser == null) return;
    state = state.copyWith(isLoading: true);
    try {
      final updatedUser = currentUser.copyWith(
        displayName: displayName,
        email: email,
        createdAt: DateTime.now(),
      );
      await _authRepository.saveUserProfile(updatedUser);
      state = AuthState(status: AuthStatus.authenticated, user: updatedUser);
    } catch (e) {
      state = state.copyWith(
        status: AuthStatus.needsProfileSetup,
        errorMessage: e.toString(),
        isLoading: false,
      );
    }
  }

  Future<void> selectChurch(String churchId) async {
    final currentUser = state.user;
    if (currentUser == null) return;
    state = state.copyWith(isLoading: true);
    try {
      await _authRepository.updateChurchAssociation(currentUser.uid, churchId);
      state = state.copyWith(
        user: currentUser.copyWith(churchId: churchId),
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  Future<void> signOut() async {
    await _authRepository.signOut();
    state = const AuthState(status: AuthStatus.unauthenticated);
  }
}
