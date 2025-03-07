import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final String email;
  final String username;

  UserModel({required this.uid, required this.email, required this.username});

  // Convert UserModel to a map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'username': username,
    };
  }

  // Save user to Firestore
  Future<void> saveToFirestore() async {
    final FirebaseFirestore firestore = FirebaseFirestore.instance;
    await firestore.collection('users').doc(uid).set(toMap());
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
}
