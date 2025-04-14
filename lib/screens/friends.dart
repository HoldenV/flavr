import 'package:flavr/providers/authentication_state.dart';
import 'package:flavr/widgets/add_friend_popup.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';

class FriendsScreen extends StatefulWidget {
  const FriendsScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _FriendsScreenState createState() => _FriendsScreenState();
}

class _FriendsScreenState extends State<FriendsScreen> {
  late Future<List<List<Map<String, dynamic>>>> _friendsData;

  @override
  void initState() {
    super.initState();
    _fetchFriendsData();
  }

  void _fetchFriendsData() {
    final authState = Provider.of<AuthenticationState>(context, listen: false);
    final currentUserId = authState.user?.uid;
    _friendsData = Future.wait([
      getFriendRequests(currentUserId!),
      getFriends(currentUserId),
      getSentFriendRequests(currentUserId),
    ]);
  }

  Future<List<Map<String, dynamic>>> getFriendRequests(
      String currentUserId) async {
    final firestore = FirebaseFirestore.instance;

    final userDoc =
        await firestore.collection('users').doc(currentUserId).get();
    final friendRequestsReceived =
        userDoc.data()?['friendRequestsReceived'] as List<dynamic>? ?? [];

    final List<Map<String, dynamic>> friendRequestDetails = [];
    for (var requestingUid in friendRequestsReceived) {
      final querySnapshot = await firestore
          .collection('users')
          .where('uid', isEqualTo: requestingUid)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        final userData = querySnapshot.docs.first.data();
        friendRequestDetails.add({
          'uid': requestingUid ?? 'Unknown UID',
          'profilePhotoURL': userData['profilePhotoURL'] ?? '',
          'firstName': userData['firstName'] ?? 'Unknown',
          'lastName': userData['lastName'] ?? '',
          'username': userData['username'] ?? 'Unknown Username',
        });
      }
    }

    return friendRequestDetails;
  }

  Future<List<Map<String, dynamic>>> getFriends(String currentUserId) async {
    final firestore = FirebaseFirestore.instance;

    final userDoc =
        await firestore.collection('users').doc(currentUserId).get();
    final friends = userDoc.data()?['friends'] as List<dynamic>? ?? [];

    final List<Map<String, dynamic>> friendDetails = [];
    for (var friendUid in friends) {
      final querySnapshot = await firestore
          .collection('users')
          .where('uid', isEqualTo: friendUid)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        final userData = querySnapshot.docs.first.data();
        friendDetails.add({
          'uid': friendUid ?? 'Unknown UID',
          'profilePhotoURL': userData['profilePhotoURL'] ?? '',
          'firstName': userData['firstName'] ?? 'Unknown',
          'lastName': userData['lastName'] ?? '',
          'username': userData['username'] ?? 'Unknown Username',
        });
      } else {
        // Handle case where the friend's document is missing
        friendDetails.add({
          'uid': friendUid ?? 'Unknown UID',
          'profilePhotoURL': '',
          'firstName': 'Unknown',
          'lastName': '',
          'username': 'Unknown Username',
        });
      }
    }

    return friendDetails;
  }

  Future<List<Map<String, dynamic>>> getSentFriendRequests(
      String currentUserId) async {
    final firestore = FirebaseFirestore.instance;

    final userDoc =
        await firestore.collection('users').doc(currentUserId).get();
    final sentRequests =
        userDoc.data()?['friendRequestsSent'] as List<dynamic>? ?? [];

    final List<Map<String, dynamic>> sentRequestDetails = [];
    for (var sentUid in sentRequests) {
      final querySnapshot = await firestore
          .collection('users')
          .where('uid', isEqualTo: sentUid)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        final userData = querySnapshot.docs.first.data();
        sentRequestDetails.add({
          'uid': sentUid ?? 'Unknown UID',
          'profilePhotoURL': userData['profilePhotoURL'] ?? '',
          'firstName': userData['firstName'] ?? 'Unknown',
          'lastName': userData['lastName'] ?? '',
          'username': userData['username'] ?? 'Unknown Username',
        });
      }
    }

    return sentRequestDetails;
  }

  @override
  Widget build(BuildContext context) {
    final authState = Provider.of<AuthenticationState>(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Text(
              'Friends',
              style: GoogleFonts.oi(color: Colors.white),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_add, color: Colors.white),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AddFriendPopup(
                  authState: authState,
                  onFriendRequestSent: () {
                    setState(() {
                      _fetchFriendsData();
                    });
                  },
                ),
              );
            },
          ),
        ],
      ),
      backgroundColor: Colors.black,
      body: FutureBuilder<List<List<Map<String, dynamic>>>>(
        future: _friendsData,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            );
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            final friendRequests = snapshot.data?[0] ?? [];
            final friends = snapshot.data?[1] ?? [];
            final sentRequests = snapshot.data?[2] ?? [];

            return ListView(
              children: [
                const SectionHeader(title: 'Friend Requests'),
                if (friendRequests.isEmpty)
                  const Padding(
                    padding:
                        EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                    child: Text(
                      'No friend requests',
                      style: TextStyle(color: Colors.orange),
                    ),
                  ),
                ...friendRequests.map((friend) => FriendTile(
                      uid: friend['uid'],
                      photoURL: friend['profilePhotoURL']!,
                      name: '${friend['firstName']} ${friend['lastName']}',
                      username: friend['username']!,
                      actions: [
                        TextButton(
                          onPressed: () async {
                            final requesterUid = friend['uid'];
                            if (requesterUid != null) {
                              // Call the acceptFriendRequest function
                              await authState.user
                                  ?.acceptFriendRequest(requesterUid);

                              // Update the local state immediately
                              setState(() {
                                // Remove the friend request from the friendRequests list
                                friendRequests.removeWhere((request) =>
                                    request['uid'] == requesterUid);

                                // Add the friend to the friends list
                                friends.add(friend);
                              });
                            } else {
                              print('Error: requesterUid is null');
                            }
                          },
                          child: const Text('Accept',
                              style: TextStyle(color: Colors.green)),
                        ),
                        TextButton(
                          onPressed: () => authState.user
                              ?.rejectFriendRequest(friend['uid']),
                          child: const Text('Reject',
                              style: TextStyle(color: Colors.red)),
                        ),
                      ],
                    )),
                const SectionHeader(title: 'Friends'),
                if (friends.isEmpty)
                  const Padding(
                    padding:
                        EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                    child: Text(
                      'No friends',
                      style: TextStyle(color: Colors.orange),
                    ),
                  ),
                ...friends.map((friend) => FriendTile(
                      uid: friend['uid'],
                      photoURL: friend['profilePhotoURL']!,
                      name: '${friend['firstName']} ${friend['lastName']}',
                      username: friend['username']!,
                      actions: [
                        TextButton(
                          onPressed: () =>
                              print('Message ${friend['username']}'),
                          child: const Text('Invite',
                              style: TextStyle(color: Colors.blue)),
                        ),
                        TextButton(
                          onPressed: () async {
                            final targetUid = friend['uid'];
                            if (targetUid != null) {
                              await authState.user?.removeFriend(targetUid);
                              setState(() {
                                _fetchFriendsData();
                              });
                            } else {
                              print('Error: targetUid is null');
                            }
                          },
                          child: const Text(
                            'Remove',
                            style: TextStyle(color: Colors.red),
                          ),
                        ),
                      ],
                    )),
                const SectionHeader(title: 'Sent Friend Requests'),
                if (sentRequests.isEmpty)
                  const Padding(
                    padding:
                        EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                    child: Text(
                      'No sent friend requests',
                      style: TextStyle(color: Colors.orange),
                    ),
                  ),
                ...sentRequests.map((friend) => FriendTile(
                      uid: friend['uid'],
                      photoURL: friend['profilePhotoURL']!,
                      name: '${friend['firstName']} ${friend['lastName']}',
                      username: friend['username']!,
                      actions: [
                        TextButton(
                          onPressed: () async {
                            final targetUid = friend['uid'];
                            print(
                                'Canceling friend request for UID: $targetUid');
                            if (targetUid != null) {
                              await authState.user
                                  ?.cancelFriendRequest(targetUid);
                              setState(() {
                                _fetchFriendsData();
                              });
                            } else {
                              print('Error: targetUid is null');
                            }
                          },
                          child: const Text(
                            'Cancel',
                            style: TextStyle(color: Colors.orange),
                          ),
                        ),
                      ],
                    )),
              ],
            );
          }
        },
      ),
    );
  }
}

class SectionHeader extends StatelessWidget {
  final String title;

  const SectionHeader({required this.title, super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: Text(
        title,
        style: const TextStyle(
            color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );
  }
}

class FriendTile extends StatelessWidget {
  final String uid;
  final String photoURL;
  final String name;
  final String username;
  final List<Widget> actions;

  const FriendTile({
    required this.uid,
    this.photoURL = '',
    this.name = 'Unknown',
    this.username = 'Unknown Username',
    required this.actions,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.grey[900],
      margin: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 16.0),
      child: ListTile(
        leading: CircleAvatar(
          backgroundImage: photoURL.isNotEmpty
              ? NetworkImage(photoURL)
              : const AssetImage('lib/assets/default_profile.png')
                  as ImageProvider,
        ),
        title: Text(
          name,
          style: const TextStyle(color: Colors.white),
        ),
        subtitle: Text(
          username,
          style: const TextStyle(color: Colors.grey),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: actions,
        ),
      ),
    );
  }
}
