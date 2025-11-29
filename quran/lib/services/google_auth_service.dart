import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class GoogleAuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _google = GoogleSignIn(scopes: ['email']);

  Future<User?> signIn() async {
    try {
      if (kIsWeb) {
        final provider = GoogleAuthProvider();
        final cred = await _auth.signInWithPopup(provider);
        return cred.user;
      }
      final account = await _google.signIn();
      if (account == null) return null;
      final auth = await account.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: auth.accessToken,
        idToken: auth.idToken,
      );
      final result = await _auth.signInWithCredential(credential);
      return result.user;
    } on FirebaseAuthException {
      // Bubble up for UI to handle and log
      rethrow;
    }
  }

  Future<User?> silent() async {
    if (kIsWeb) return _auth.currentUser;
    final account = await _google.signInSilently();
    if (account == null) return null;
    final auth = await account.authentication;
    final credential = GoogleAuthProvider.credential(
      accessToken: auth.accessToken,
      idToken: auth.idToken,
    );
    return (await _auth.signInWithCredential(credential)).user;
  }

  Future<void> signOut() async {
    if (!kIsWeb) {
      try {
        await _google.signOut();
      } catch (_) {}
    }
    await _auth.signOut();
  }

  Future<User?> linkToExisting(User existing) async {
    final account = await _google.signIn();
    if (account == null) return null;
    final auth = await account.authentication;
    final credential = GoogleAuthProvider.credential(
      accessToken: auth.accessToken,
      idToken: auth.idToken,
    );
    final linked = await existing.linkWithCredential(credential);
    return linked.user;
  }
}
