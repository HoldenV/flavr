import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:convert'; // For JSON encoding/decoding

class UserModel extends ChangeNotifier {
  String uid;
  String email;
  String username;

  static const localStorage = FlutterSecureStorage();
  static const localStorageKey = 'user_model';

  UserModel({required this.uid, required this.email, required this.username});

  // Convert UserModel to a map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'username': username,
    };
  }

  // Save user to Firestore and local storage
  Future<void> saveToFirestore() async {
    final FirebaseFirestore firestore = FirebaseFirestore.instance;
    await firestore.collection('users').doc(uid).set(toMap());
    await saveToLocalStorage(); // Save to local storage
  }

  // Save user to local storage
  Future<void> saveToLocalStorage() async {
    final String jsonString = jsonEncode(toMap());
    await localStorage.write(key: localStorageKey, value: jsonString);
  }

  // Fetch user from Firestore
  static Future<UserModel?> fromFirestore(String uid) async {
    final FirebaseFirestore firestore = FirebaseFirestore.instance;
    final DocumentSnapshot doc =
        await firestore.collection('users').doc(uid).get();
    if (doc.exists) {
      return UserModel(
        uid: doc['uid'],
        email: doc['email'],
        username:
            (doc.data() as Map<String, dynamic>?)?.containsKey('username') ==
                    true
                ? doc['username']
                : '',
      );
    }
    return null;
  }

  // Fetch user from local storage
  static Future<UserModel?> fromLocalStorage() async {
    final String? jsonString = await localStorage.read(key: localStorageKey);
    if (jsonString != null) {
      final Map<String, dynamic> data = jsonDecode(jsonString);
      return UserModel(
        uid: data['uid'],
        email: data['email'],
        username: data['username'],
      );
    }
    return null;
  }

  // Update username
  Future<void> updateUsername(String newUsername) async {
    username = newUsername;
    await saveToFirestore();
    notifyListeners();
  }
}
