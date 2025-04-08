/*
This state is for tracking the authentication state of the app.
This might be refactored into a sign in service that is merely
accessed by this state provider
 */

import 'package:flavr/screens/account_creation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../models/user.dart';

class AuthenticationState extends ChangeNotifier {
  final auth = FirebaseAuth.instance;
  final googleSignIn = GoogleSignIn();

  UserModel? _user;

  UserModel? get user => _user;

  set user(UserModel? newUser) {
    _user = newUser;
    notifyListeners();
  }

  AuthenticationState() {
    initializeAuthState();
  }

  Future<void> initializeAuthState() async {
    final firebaseUser = auth.currentUser;

    if (firebaseUser != null) {
      // Try to fetch the user from local storage or Firestore
      user = await UserModel.fromLocalStorage() ??
          await UserModel.fromFirestore(firebaseUser.uid);

      // If the user is found, save it to local storage
      if (user != null) {
        await user!.saveToLocalStorage();
      } else {
        print(
            'No user found in Firestore or local storage for UID: ${firebaseUser.uid}');
      }
    } else {
      // If no FirebaseAuth user is found, try to load from local storage
      user = await UserModel.fromLocalStorage();
      if (user == null) {
        print('No user found in local storage.');
      }
    }

    // Notify listeners to rebuild dependent widgets
    notifyListeners();
  }

  Future<void> signInWithGoogle(BuildContext context) async {
    try {
      final googleUser = await googleSignIn.signIn();
      if (googleUser == null) {
        print('Google sign-in canceled by user.');
        return; // User canceled the sign-in
      }

      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await auth.signInWithCredential(credential);
      final firebaseUser = userCredential.user;

      if (firebaseUser != null) {
        // Retrieve the profile photo URL from Google
        final profilePhotoUrl = googleUser.photoUrl;

        // Fetch the user from Firestore or create a new one
        user = await UserModel.fromFirestore(firebaseUser.uid);

        if (user == null) {
          // If the user does not exist, navigate to the account creation screen
          if (!context.mounted) return;
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) => AccountCreationScreen(
                userCredential: userCredential,
              ),
            ),
          );
        } else {
          // Update the user's profile photo URL if it is not already set
          user = user!.copyWith(profilePhotoURL: profilePhotoUrl);
          await user!.saveToFirestore();

          // Save the user to local storage
          await user!.saveToLocalStorage();
          notifyListeners();
        }
      }
    } catch (e) {
      print('Google sign-in failed: $e');
    }
  }

  Future<void> signOut() async {
    await auth.signOut();
    await googleSignIn.signOut();
    user = null;
    await UserModel.localStorage.delete(key: UserModel.localStorageKey);
    notifyListeners();
  }
}
