import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthValidationException implements Exception {
  final String message;
  AuthValidationException(this.message);
}

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email', 'profile'],
    clientId:
        '451734690659-un6pntjhv6135u4fm6mna12d19raanfj.apps.googleusercontent.com',
  );

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Check if email is verified
  bool get isEmailVerified => _auth.currentUser?.emailVerified ?? false;

  // Send email verification
  Future<void> sendEmailVerification() async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw AuthValidationException('No user signed in');
      }
      if (user.emailVerified) {
        throw AuthValidationException('Email is already verified');
      }
      await user.sendEmailVerification();
    } on FirebaseAuthException catch (e) {
      print('Firebase Auth Error in sendEmailVerification: ${e.code} - ${e.message}');
      throw _getReadableError(e);
    } on AuthValidationException {
      rethrow;
    } catch (e) {
      print('Unexpected error in sendEmailVerification: $e');
      throw 'Error sending verification email. Please try again';
    }
  }

  // Reload user
  Future<void> reloadUser() async {
    try {
      await _auth.currentUser?.reload();
    } catch (e) {
      throw 'Error reloading user data. Please try again';
    }
  }

  String _getReadableError(FirebaseAuthException e) {
    switch (e.code) {
      case 'invalid-email':
        return 'Please enter a valid email address';
      case 'user-disabled':
        return 'This account has been disabled';
      case 'user-not-found':
        return 'No account found with this email';
      case 'wrong-password':
        return 'Incorrect password, please try again';
      case 'email-already-in-use':
        return 'An account already exists with this email';
      case 'operation-not-allowed':
        return 'Email/password accounts are not enabled';
      case 'weak-password':
        return 'Please use a stronger password (at least 6 characters)';
      case 'too-many-requests':
        return 'Too many attempts. Please try again later';
      case 'network-request-failed':
        return 'Network error. Please check your connection';
      default:
        return e.message ?? 'An error occurred. Please try again';
    }
  }

  // Sign in with email and password
  Future<UserCredential> signInWithEmailAndPassword(
      String email, String password) async {
    try {
      if (password.isEmpty) {
        throw AuthValidationException('Please enter your password');
      }
      if (email.isEmpty) {
        throw AuthValidationException('Please enter your email');
      }
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      if (!userCredential.user!.emailVerified) {
        throw AuthValidationException('Please verify your email before signing in');
      }
      
      return userCredential;
    } on FirebaseAuthException catch (e) {
      throw _getReadableError(e);
    } on AuthValidationException {
      rethrow;
    } catch (e) {
      throw 'An unexpected error occurred. Please try again';
    }
  }

  // Sign up with email and password
  Future<UserCredential> signUpWithEmailAndPassword(
      String email, String password) async {
    try {
      if (password.length < 6) {
        throw AuthValidationException(
            'Please use a stronger password (at least 6 characters)');
      }
      if (!email.contains('@')) {
        throw AuthValidationException('Please enter a valid email address');
      }
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      // Send email verification after successful sign up
      await userCredential.user?.sendEmailVerification();
      return userCredential;
    } on FirebaseAuthException catch (e) {
      throw _getReadableError(e);
    } on AuthValidationException {
      rethrow;
    } catch (e) {
      throw 'An unexpected error occurred. Please try again';
    }
  }

  // Sign in with Google
  Future<UserCredential?> signInWithGoogle() async {
    try {
      print('Starting Google Sign In process...');
      
      // Trigger the authentication flow
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn().catchError((error) {
        print('Error in googleSignIn.signIn(): $error');
        if (error.toString().contains('sign_in_canceled') || 
            error.toString().contains('canceled') ||
            error.toString().contains('cancelled')) {
          return null;
        }
        throw error;
      });
      
      if (googleUser == null) {
        print('Google Sign In cancelled by user');
        return null;
      }

      print('Google Sign In successful for user: ${googleUser.email}');

      try {
        // Obtain the auth details from the request
        print('Getting authentication details...');
        final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
        print('Got authentication details. AccessToken exists: ${googleAuth.accessToken != null}, IdToken exists: ${googleAuth.idToken != null}');

        // Create a new credential
        final credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );

        print('Signing in to Firebase with Google credential...');
        // Sign in to Firebase with the Google Auth credential
        final userCredential = await _auth.signInWithCredential(credential);
        print('Successfully signed in to Firebase with Google');
        return userCredential;
      } catch (e) {
        print('Detailed Google Auth Error: $e');
        throw 'Failed to get Google authentication. Please try again.';
      }
    } on FirebaseAuthException catch (e) {
      print('Firebase Auth Error: ${e.code} - ${e.message}');
      throw _getReadableError(e);
    } catch (e) {
      print('Unexpected Error in Google Sign In: $e');
      if (e is String) throw e;
      throw 'An unexpected error occurred during Google sign in. Please try again';
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      // First sign out from Google to prevent any pending Google operations
      try {
        await _googleSignIn.signOut();
      } catch (e) {
        print('Google Sign Out Error (non-fatal): $e');
      }
      
      // Then sign out from Firebase
      await _auth.signOut();
    } catch (e) {
      print('Sign Out Error: $e');
      throw 'Error signing out. Please try again';
    }
  }

  // Password reset
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      if (email.isEmpty) {
        throw AuthValidationException('Please enter your email');
      }
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw _getReadableError(e);
    } on AuthValidationException {
      rethrow;
    } catch (e) {
      throw 'Error sending password reset email. Please try again';
    }
  }

  // Stream of auth state changes
  Stream<User?> get authStateChanges => _auth.authStateChanges();
}

// Provider
final authServiceProvider = Provider<AuthService>((ref) => AuthService());

// Auth state provider
final authStateProvider = StreamProvider<User?>((ref) {
  final authService = ref.watch(authServiceProvider);
  return authService.authStateChanges;
});
