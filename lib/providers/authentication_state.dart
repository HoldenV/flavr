/*
This state is for tracking the authentication state of the app.
This might be refactored into a sign in service that is merely
accessed by this state provider
 */

import 'package:flavr/screens/account_creation.dart';
import 'package:flavr/widgets/authentication_wrapper.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user.dart';

class AuthenticationState extends ChangeNotifier {
  final auth = FirebaseAuth.instance;
  final googleSignIn = GoogleSignIn();
  final firestore = FirebaseFirestore.instance;

  bool _loading = true;
  double _restaurantDistance = 15;
  UserModel? _user;

  bool get loading => _loading;
  UserModel? get user => _user;
  double get restaurantDistance => _restaurantDistance;

  set user(UserModel? newUser) {
    _user = newUser;
    notifyListeners();
  }

  void setRestaurantDistance(double value) {
    _restaurantDistance = value;
    notifyListeners();
  }

  AuthenticationState() {
    initializeAuthState();
  }

  Future<void> initializeAuthState() async {
    final firebaseUser = auth.currentUser;

    if (firebaseUser != null) {
      // Try to fetch the user from Firestore
      user = await UserModel.fromFirestore(firebaseUser.uid);

      // If the user is found, save it to local storage
      if (user != null) {
        await user!.saveToLocalStorage();
      }

      // Notify listeners to rebuild dependent widgets
      notifyListeners();
    }

    _loading = false; // Set loading to false once data is fetched
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
          // Update only the profile photo URL if necessary
          if (user!.profilePhotoURL != profilePhotoUrl) {
            final updatedUserMap = user!.toMap();
            updatedUserMap['profilePhotoURL'] = profilePhotoUrl;
            user = UserModel.fromMap(updatedUserMap);
            await firestore.collection('users').doc(user!.uid).update({
              'profilePhotoURL': profilePhotoUrl,
            });
          }

          // Save the user to local storage
          await user!.saveToLocalStorage();
          notifyListeners();
        }
      }
    } catch (e) {
      print('Google sign-in failed: $e');
    }
  }

  Future<void> signOut(context) async {
    await auth.signOut();
    await googleSignIn.signOut();
    user = null;
    await UserModel.localStorage.delete(key: UserModel.localStorageKey);
    await UserModel.localStorage.deleteAll();
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => const AuthenticationWrapper()),
    );
    notifyListeners();
  }
}
