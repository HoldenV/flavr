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
  final DateTime? accountCreationDatetime;
  final DateTime? lastLoginDatetime;

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
    List<String>? friends,
    List<String>? friendRequestsSent,
    List<String>? friendRequestsReceived,
    this.accountCreationDatetime,
    this.lastLoginDatetime,
  })  : friends = friends ?? List.empty(growable: true),
        friendRequestsSent = friendRequestsSent ?? List.empty(growable: true),
        friendRequestsReceived =
            friendRequestsReceived ?? List.empty(growable: true);

  factory UserModel.fromMap(Map<String, dynamic> data) {
    DateTime? parseDate(dynamic value) {
      if (value is Timestamp) {
        return value.toDate();
      } else if (value is String) {
        return DateTime.tryParse(value);
      }
      return null;
    }

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
      accountCreationDatetime: parseDate(data['accountCreationDatetime']),
      lastLoginDatetime: parseDate(data['lastLoginTimestamp']),
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
      'accountCreationTimestamp': accountCreationDatetime?.toIso8601String(),
      'lastLoginTimestamp': lastLoginDatetime?.toIso8601String(),
    };
  }

  // Save user to Firestore and local storage
  Future<void> saveToFirestore() async {
    final FirebaseFirestore firestore = FirebaseFirestore.instance;

    await firestore
        .collection('users')
        .doc(uid)
        .set(toMap(), SetOptions(merge: true));
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

      // Update the lastLoginDatetime to the current time
      await firestore.collection('users').doc(uid).update({
        'lastLoginTimestamp': FieldValue.serverTimestamp(),
      });

      return UserModel.fromMap(data);
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
        accountCreationDatetime: data['accountCreationTimestamp'],
        lastLoginDatetime: data['lastLoginTimestamp'],
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
    if (!friendRequestsSent.contains(targetUid)) {
      friendRequestsSent.add(targetUid);
    }

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

    // Update Firestore: delete the field if the list is empty, otherwise update it
    await firestore.collection('users').doc(uid).update({
      'friendRequestsReceived': friendRequestsReceived.isEmpty
          ? FieldValue.delete()
          : friendRequestsReceived,
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

    // Remove the current user from the requester's sent friend requests
    await firestore.collection('users').doc(requesterUid).update({
      'friendRequestsSent': FieldValue.arrayRemove([uid]),
    });

    notifyListeners();
  }

  // Reject friend request
  Future<void> rejectFriendRequest(String requesterUid) async {
    final firestore = FirebaseFirestore.instance;

    // Remove the requester from the current user's received friend requests
    friendRequestsReceived.remove(requesterUid);

    // Update Firestore: delete the field if the list is empty, otherwise update it
    await firestore.collection('users').doc(uid).update({
      'friendRequestsReceived': friendRequestsReceived.isEmpty
          ? FieldValue.delete()
          : friendRequestsReceived,
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

    // Update Firestore: delete the field if the list is empty, otherwise update it
    await firestore.collection('users').doc(uid).update({
      'friendRequestsSent':
          friendRequestsSent.isEmpty ? FieldValue.delete() : friendRequestsSent,
    });

    // Remove the current user from the target user's received friend requests
    await firestore.collection('users').doc(targetUid).update({
      'friendRequestsReceived': FieldValue.arrayRemove([uid]),
    });

    notifyListeners();
  }

  // Remove a friend
  Future<void> removeFriend(String targetUid) async {
    final firestore = FirebaseFirestore.instance;

    // Remove the target user from the current user's sent friend requests
    friends.remove(targetUid);

    // Update Firestore: delete the field if the list is empty, otherwise update it
    await firestore.collection('users').doc(uid).update({
      'friends': friends.isEmpty ? FieldValue.delete() : friends,
    });

    // Remove the current user from the target user's friends
    await firestore.collection('users').doc(targetUid).update({
      'friends': FieldValue.arrayRemove([uid]),
    });

    notifyListeners();
  }
}
