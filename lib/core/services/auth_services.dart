import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  
  // Get current user
  User? get currentUser => _auth.currentUser;
  
  // Check if user is logged in
  bool get isLoggedIn => _auth.currentUser != null;
  
  // Sign out
  Future<void> signOut() async {
    await _auth.signOut();
    try {
      await GoogleSignIn().signOut();
    } catch (e) {
      // Ignore if Google Sign In not initialized
    }
  }
  
  // Send password reset email
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw Exception(e.message);
    }
  }
  
  // Resend email verification
  Future<void> resendEmailVerification() async {
    final user = _auth.currentUser;
    if (user != null && !user.emailVerified) {
      await user.sendEmailVerification();
    }
  }

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
  // _idTokenSub = _auth.idTokenChanges().listen((User? user) async {
  //     if (user == null) {
  //       print('IDToken: User signed out');
  //     } else {
  //       final tokenResult = await user.getIdTokenResult(true);
  //       print('IDToken: User signed in, claims: ${tokenResult.claims}');
  //     }
  //   });

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
          await userCredential.user!.sendEmailVerification();
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

Future<User?> signInWithGoogle() async {
  try {
    print('=== Starting Google Sign In ===');
    
    final GoogleSignIn googleSignIn = GoogleSignIn();
    
    // Sign out first to clear any cached credentials
    await googleSignIn.signOut();
    print('Cleared previous session');
    
    // Trigger the authentication flow
    print('Triggering Google Sign In...');
    final googleUser = await googleSignIn.signIn();
    
    if (googleUser == null) {
      print('User cancelled sign in');
      throw Exception('Google sign-in cancelled by user');
    }
    
    print('Google user: ${googleUser.email}');

    // Obtain the auth details from the request
    print('Getting authentication tokens...');
    final googleAuth = await googleUser.authentication;

    // Check if we have the required tokens
    if (googleAuth.idToken == null) {
      print('ERROR: No ID token received');
      throw Exception('Failed to get Google ID token');
    }
    
    print('Got ID token, creating Firebase credential...');

    // Create a new credential
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    // Sign in to Firebase with the Google credential
    print('Signing in to Firebase...');
    final userCredential = await _auth.signInWithCredential(credential);
    
    print('=== Google Sign In SUCCESS ===');
    return userCredential.user;

  } catch (e) {
    print('=== Google Sign In ERROR ===');
    print('Error type: ${e.runtimeType}');
    print('Error message: $e');
    
    // Handle specific Google Sign In errors
    if (e.toString().contains('canceled') || e.toString().contains('cancelled')) {
      throw Exception('Google sign-in was cancelled');
    } else if (e.toString().contains('network')) {
      throw Exception('Network error. Please check your connection');
    } else {
      throw Exception('Google sign-in failed: ${e.toString()}');
    }
  }
}

  // Sign up with Google (same as sign in, Firebase handles account creation)
  Future<User?> signUpWithGoogle() async {
    return await signInWithGoogle();
  }


}
