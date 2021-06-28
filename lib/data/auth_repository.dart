import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';

abstract class BaseAuthRepository {
  Future<void> signInWithGoogle();
  Stream<User?> get authStateChanges;
  User? get currentUser;
  bool isSignedIn();
  void signOut();
}

final authProvider = Provider<AuthRepository>((ref) => AuthRepository());

class AuthRepository implements BaseAuthRepository {
  final _firebaseAuth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  @override
  Future<UserCredential?> signInWithGoogle() async {
    try {
      final googleUser = await _googleSignIn.signIn();
      final googleAuth = await googleUser?.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth?.accessToken,
        idToken: googleAuth?.idToken,
      );

      return await _firebaseAuth.signInWithCredential(credential);
    } on Exception catch (e) {
      print(e.toString());
    }
  }

  @override
  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  @override
  User? get currentUser => _firebaseAuth.currentUser;

  @override
  bool isSignedIn() => _firebaseAuth.currentUser != null;

  Future<void> deleteAccount() async {
    try {
      await _firebaseAuth.currentUser?.delete();
    } on FirebaseAuthException catch (e) {
      print(e.toString());
      final googleUser = await _googleSignIn.signIn();
      final googleAuth = await googleUser?.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth?.accessToken,
        idToken: googleAuth?.idToken,
      );
      currentUser!.reauthenticateWithCredential(credential);
      print('test');
      await _firebaseAuth.currentUser?.delete();
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await _firebaseAuth.signOut();
      await _googleSignIn.signOut();
    } on Exception catch (e) {
      print(e.toString());
    }
  }
}
