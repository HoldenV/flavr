/*
This state is for tracking the authentication state of the app.
This might be refactored into a sign in service that is merely
accessed by this state provider
 */

import 'package:flavr/screens/account_creation.dart';
import 'package:flavr/widgets/app_state_wrapper.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../models/user.dart';

class AuthenticationState extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  User? _user;
  UserModel? _userModel;

  User? get user => _user;
  UserModel? get userModel => _userModel;

  AuthenticationState() {
    _initializeAuthState();
  }

  // Initialize authentication state
  Future<void> _initializeAuthState() async {
    // Check if a user is already signed in with Firebase
    _user = _auth.currentUser;

    if (_user != null) {
      // Try to load the user model from local storage
      _userModel = await UserModel.fromLocalStorage();

      // If no local data is found, fetch from Firestore
      if (_userModel == null) {
        _userModel = await UserModel.fromFirestore(_user!.uid);
        if (_userModel != null) {
          await _userModel!.saveToLocalStorage(); // Cache it locally
        }
      }
    } else {
      // If no Firebase user, try to load user data from local storage
      _userModel = await UserModel.fromLocalStorage();
    }

    if (_userModel != null) {
      _userModel!.addListener(notifyListeners);
    }

    notifyListeners();
  }

  Future<void> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      final GoogleSignInAuthentication googleAuth =
          await googleUser!.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      UserCredential userCredential =
          await _auth.signInWithCredential(credential);
      _user = userCredential.user;

      if (_user != null) {
        _userModel = await UserModel.fromFirestore(_user!.uid);
        if (_userModel == null) {
          _userModel = UserModel(
              uid: _user!.uid, email: _user!.email!, username: 'null_username');
          await _userModel!.saveToFirestore();
        }
        await _userModel!.saveToLocalStorage(); // Cache it locally
        _userModel!.addListener(notifyListeners);
      }

      notifyListeners();
    } catch (e) {
      print('Google sign in cancelled: $e');
    }
  }

  Future<void> signOut() async {
    if (_userModel != null) {
      _userModel!.removeListener(notifyListeners);
    }
    await _auth.signOut();
    await _googleSignIn.signOut();
    _user = null;
    _userModel = null;

    // Clear local storage
    await UserModel.localStorage.delete(key: UserModel.localStorageKey);

    notifyListeners();
  }

  Future<void> checkUsernameAndNavigate(
      BuildContext context, AuthenticationState authState) async {
    if (authState.userModel?.username == 'null_username') {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => AccountCreationScreen()),
        );
      });
    } else {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const AppStateWrapper()),
        );
      });
    }
  }
}
