import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:church/core/constants/app_constants.dart';
import 'package:church/core/logger/app_logger.dart';
import 'package:church/features/auth/data/user_model.dart';

const _tag = 'AuthRepository';

class AuthRepository {
  final FirebaseAuth      _auth      = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  User? get currentUser => _auth.currentUser;

  Future<UserModel?> getUserProfile(String uid) async {
    log.d(_tag, 'getUserProfile uid=$uid');
    try {
      final doc = await _firestore
          .collection(AppConstants.usersCollection)
          .doc(uid)
          .get();
      if (doc.exists && doc.data() != null) {
        log.d(_tag, 'getUserProfile found profile for uid=$uid');
        return UserModel.fromMap(doc.data()!, uid);
      }
      log.d(_tag, 'getUserProfile no profile found for uid=$uid');
      return null;
    } catch (e, stack) {
      log.e(_tag, 'getUserProfile failed for uid=$uid', error: e, stack: stack);
      return null;
    }
  }

  Future<void> saveUserProfile(UserModel user) async {
    log.i(_tag, 'saveUserProfile uid=${user.uid}');
    try {
      await _firestore
          .collection(AppConstants.usersCollection)
          .doc(user.uid)
          .set(user.toMap(), SetOptions(merge: true));
      log.i(_tag, 'saveUserProfile success uid=${user.uid}');
    } catch (e, stack) {
      log.e(_tag, 'saveUserProfile failed uid=${user.uid}', error: e, stack: stack);
      rethrow;
    }
  }

  Future<void> verifyPhone({
    required String phoneNumber,
    required Function(String verificationId, int? resendToken) codeSent,
    required Function(FirebaseAuthException e) verificationFailed,
    required Function(PhoneAuthCredential credential) verificationCompleted,
    required Function(String verificationId) codeAutoRetrievalTimeout,
  }) async {
    log.i(_tag, 'verifyPhone phone=$phoneNumber');
    await _auth.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      verificationCompleted: (credential) {
        log.i(_tag, 'verifyPhone auto-verified');
        verificationCompleted(credential);
      },
      verificationFailed: (e) {
        log.e(_tag, 'verifyPhone failed code=${e.code}', error: e);
        verificationFailed(e);
      },
      codeSent: (verificationId, resendToken) {
        log.i(_tag, 'verifyPhone code sent verificationId=$verificationId');
        codeSent(verificationId, resendToken);
      },
      codeAutoRetrievalTimeout: (verificationId) {
        log.w(_tag, 'verifyPhone auto-retrieval timeout verificationId=$verificationId');
        codeAutoRetrievalTimeout(verificationId);
      },
      timeout: const Duration(seconds: 60),
    );
  }

  Future<UserCredential> signInWithCredential(PhoneAuthCredential credential) async {
    log.i(_tag, 'signInWithCredential');
    try {
      final result = await _auth.signInWithCredential(credential);
      log.i(_tag, 'signIn success uid=${result.user?.uid}');
      return result;
    } catch (e, stack) {
      log.e(_tag, 'signInWithCredential failed', error: e, stack: stack);
      rethrow;
    }
  }

  Future<void> signOut() async {
    log.i(_tag, 'signOut uid=${_auth.currentUser?.uid}');
    try {
      await _auth.signOut();
      log.i(_tag, 'signOut complete');
    } catch (e, stack) {
      log.e(_tag, 'signOut failed', error: e, stack: stack);
      rethrow;
    }
  }

  Future<void> updateChurchAssociation(String uid, String? churchId) async {
    log.i(_tag, 'updateChurchAssociation uid=$uid churchId=$churchId');
    try {
      await _firestore
          .collection(AppConstants.usersCollection)
          .doc(uid)
          .update({'churchId': churchId});
      log.i(_tag, 'updateChurchAssociation success');
    } catch (e, stack) {
      log.e(_tag, 'updateChurchAssociation failed uid=$uid', error: e, stack: stack);
      rethrow;
    }
  }
}
