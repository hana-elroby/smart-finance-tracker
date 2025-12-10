import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Stream subscriptions for cleanup
  late final StreamSubscription<User?> _authSub;
  late final StreamSubscription<User?> _idTokenSub;
  late final StreamSubscription<User?> _userSub;

  void setupListeners() {
    // 1. Auth state changes (login/logout)
    _authSub = _auth.authStateChanges().listen((User? user) {
      if (user == null) {
        print('AuthState: User signed out');
      } else {
        print('AuthState: User signed in, uid: ${user.uid}');
      }
    });

    // 2. ID token changes (token refresh / custom claims)
    _idTokenSub = _auth.idTokenChanges().listen((User? user) async {
      if (user == null) {
        print('IDToken: User signed out');
      } else {
        final tokenResult = await user.getIdTokenResult(true);
        print('IDToken: User signed in, claims: ${tokenResult.claims}');
      }
    });

    // 3. User profile changes (displayName, photoURL)
    _userSub = _auth.userChanges().listen((User? user) {
      if (user == null) {
        print('UserChanges: User signed out');
      } else {
        print(
          'UserChanges: User signed in, displayName: ${user.displayName}, email: ${user.email}',
        );
      }
    });
  }

  // Call this when disposing the service or widget
  void dispose() {
    _authSub.cancel();
    _idTokenSub.cancel();
    _userSub.cancel();
  }

  // Register new user
  Future<User?> signupWithEmail(String email, String password) async {
    try {
      UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(email: email, password: password);
      return userCredential.user;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        throw Exception('The password provided is too weak.');
      } else if (e.code == 'email-already-in-use') {
        throw Exception('The account already exists for that email.');
      } else {
        throw Exception(e.message);
      }
    } catch (e) {
      throw Exception('signup failed: $e');
    }
  }

  // Sign in existing user
  Future<User?> signInWithEmail(String email, String password) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential.user;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        throw Exception('No user found for that email.');
      } else if (e.code == 'wrong-password') {
        throw Exception('Wrong password provided.');
      } else {
        throw Exception(e.message);
      }
    } catch (e) {
      throw Exception('Login failed: $e');
    }
  }
}
