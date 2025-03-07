/*
This state is for tracking the authentication state of the app.
This might be refactored into a sign in service that is merely
accessed by this state provider
 */

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

  Future<void> signInWithGoogle() async {
    try {
      // begin interactive sign-in process
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      // obtain auth details from request
      final GoogleSignInAuthentication googleAuth =
          await googleUser!.authentication;

      // create new credential for user
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // sign in!
      UserCredential userCredential =
          await _auth.signInWithCredential(credential);

      _user = userCredential.user;

      if (_user != null) {
        // Check if user already exists in Firestore
        _userModel = await UserModel.fromFirestore(_user!.uid);
        if (_userModel == null) {
          // Create a new UserModel and save it to Firestore
          _userModel = UserModel(
              uid: _user!.uid, email: _user!.email!, username: 'null_username');
          await _userModel!.saveToFirestore();
        }
      }

      notifyListeners();
    } catch (e) {
      // in case where user closes dialog without signing in
      print('Google sign in cancelled: $e');
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
    await _googleSignIn.signOut();
    _user = null;
    _userModel = null;
    notifyListeners();
  }
}
