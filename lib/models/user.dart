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
      'profilePhotoURL': profilePhotoURL,
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
        profilePhotoURL: data['profilePhotoURL'] ?? '', // Ensure this is loaded
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
        profilePhotoURL: data['profilePhotoURL'] ?? '', // Ensure this is loaded
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

  // Send a friend request
  Future<void> sendFriendRequest(String targetUid) async {
    final firestore = FirebaseFirestore.instance;

    // Add the target user to the current user's sent friend requests
    friendRequestsSent.add(targetUid);
    await firestore.collection('users').doc(uid).update({
      'friendRequestsSent': friendRequestsSent,
    });

    // Add the current user to the target user's received friend requests
    await firestore.collection('users').doc(targetUid).update({
      'friendRequestsReceived': FieldValue.arrayUnion([uid]),
    });

    notifyListeners();
  }

  // Accept friend request
  Future<void> acceptFriendRequest(String requesterUid) async {
    final firestore = FirebaseFirestore.instance;

    // Remove the requester from the current user's received friend requests
    friendRequestsReceived.remove(requesterUid);
    await firestore.collection('users').doc(uid).update({
      'friendRequestsReceived': friendRequestsReceived,
    });

    // Add the requester to the current user's friends list
    friends.add(requesterUid);
    await firestore.collection('users').doc(uid).update({
      'friends': friends,
    });

    // Add the current user to the requester's friends list
    await firestore.collection('users').doc(requesterUid).update({
      'friends': FieldValue.arrayUnion([uid]),
    });

    notifyListeners();
  }

  // Reject friend request
  Future<void> rejectFriendRequest(String requesterUid) async {
    final firestore = FirebaseFirestore.instance;

    // Remove the requester from the current user's received friend requests
    friendRequestsReceived.remove(requesterUid);
    await firestore.collection('users').doc(uid).update({
      'friendRequestsReceived': friendRequestsReceived,
    });

    // Optionally, remove the current user from the requester's sent friend requests
    await firestore.collection('users').doc(requesterUid).update({
      'friendRequestsSent': FieldValue.arrayRemove([uid]),
    });

    notifyListeners();
  }

  // Cancel a friend request
  Future<void> cancelFriendRequest(String targetUid) async {
    final firestore = FirebaseFirestore.instance;

    // Remove the target user from the current user's sent friend requests
    friendRequestsSent.remove(targetUid);
    await firestore.collection('users').doc(uid).update({
      'friendRequestsSent': friendRequestsSent,
    });

    // Remove the current user from the target user's received friend requests
    await firestore.collection('users').doc(targetUid).update({
      'friendRequestsReceived': FieldValue.arrayRemove([uid]),
    });

    notifyListeners();
  }
}
