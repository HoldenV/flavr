import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:convert';

class UserModel extends ChangeNotifier {
  final String uid;
  final String email;
  String username;
  final String? firstName;
  final String? lastName;
  final String? bio;
  final String? profilePhotoURL;
  List<String> friends;
  List<String> friendRequestsSent;
  List<String> friendRequestsReceived;

  static const localStorage = FlutterSecureStorage();
  static const localStorageKey = 'user_model';

  UserModel({
    required this.uid,
    required this.email,
    required this.username,
    this.firstName,
    this.lastName,
    this.bio,
    this.profilePhotoURL,
    this.friends = const [],
    this.friendRequestsSent = const [],
    this.friendRequestsReceived = const [],
  });

  // Define the copyWith method
  UserModel copyWith({
    String? uid,
    String? email,
    String? username,
    String? firstName,
    String? lastName,
    String? bio,
    String? profilePhotoURL,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      username: username ?? this.username,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      bio: bio ?? this.bio,
      profilePhotoURL: profilePhotoURL ?? this.profilePhotoURL,
    );
  }

  // Convert UserModel to a map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'username': username,
      'firstName': firstName,
      'lastName': lastName,
      'bio': bio,
      'profilePhoto': profilePhotoURL,
      'friends': friends,
      'friendRequestsSent': friendRequestsSent,
      'friendRequestsReceived': friendRequestsReceived,
    };
  }

  // Save user to Firestore and local storage
  Future<void> saveToFirestore() async {
    final FirebaseFirestore firestore = FirebaseFirestore.instance;
    final data = toMap();

    await firestore.collection('users').doc(uid).set(data);

    // Log the data being sent to Firestore
    print('Saved user to Firestore');

    await saveToLocalStorage();
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
      final data = doc.data() as Map<String, dynamic>;
      return UserModel(
        uid: data['uid'],
        email: data['email'],
        username: data['username'],
        firstName: data['firstName'] ?? '',
        lastName: data['lastName'] ?? '',
        bio: data['bio'] ?? '',
        profilePhotoURL: data['profilePhotoURL'] ?? '',
        friends: List<String>.from(data['friends'] ?? []),
        friendRequestsSent: List<String>.from(data['friendRequestsSent'] ?? []),
        friendRequestsReceived:
            List<String>.from(data['friendRequestsReceived'] ?? []),
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
        firstName: data['firstName'] ?? '',
        lastName: data['lastName'] ?? '',
        bio: data['bio'] ?? '',
        profilePhotoURL: data['profilePhotoURL'] ?? '',
        friends: List<String>.from(data['friends'] ?? []),
        friendRequestsSent: List<String>.from(data['friendRequestsSent'] ?? []),
        friendRequestsReceived:
            List<String>.from(data['friendRequestsReceived'] ?? []),
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
