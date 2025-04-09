import 'package:flavr/providers/authentication_state.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';

class FriendsScreen extends StatelessWidget {
  const FriendsScreen({super.key});

  Future<List<Map<String, dynamic>>> getFriendRequests(
      String currentUserId) async {
    final firestore = FirebaseFirestore.instance;

    // Retrieve the current user's friend requests (array of uids)
    final userDoc =
        await firestore.collection('users').doc(currentUserId).get();
    final friendRequests =
        userDoc.data()?['friendRequests'] as List<dynamic>? ?? [];

    // Fetch details of each user in the friendRequests array
    final List<Map<String, dynamic>> friendRequestDetails = [];
    for (var requestingUid in friendRequests) {
      // Query the user by username or uid
      final querySnapshot = await firestore
          .collection('users')
          .where('uid', isEqualTo: requestingUid)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        final userData = querySnapshot.docs.first.data();
        friendRequestDetails.add({
          'profilePhotoURL': userData['profilePhotoURL'],
          'firstName': userData['firstName'],
          'lastName': userData['lastName'],
          'username': userData['username'],
        });
      }
    }

    return friendRequestDetails;
  }

  Future<List<Map<String, dynamic>>> getFriends(String currentUserId) async {
    final firestore = FirebaseFirestore.instance;

    // Retrieve the current user's friends (array of uids)
    final userDoc =
        await firestore.collection('users').doc(currentUserId).get();
    final friends = userDoc.data()?['friends'] as List<dynamic>? ?? [];

    // Fetch details of each user in the friends array
    final List<Map<String, dynamic>> friendDetails = [];
    for (var friendUid in friends) {
      final querySnapshot = await firestore
          .collection('users')
          .where('uid', isEqualTo: friendUid)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        final userData = querySnapshot.docs.first.data();
        friendDetails.add({
          'profilePhotoURL': userData['profilePhotoURL'],
          'firstName': userData['firstName'],
          'lastName': userData['lastName'],
          'username': userData['username'],
        });
      }
    }

    return friendDetails;
  }

  Future<List<Map<String, dynamic>>> getSentFriendRequests(
      String currentUserId) async {
    final firestore = FirebaseFirestore.instance;

    // Retrieve the current user's sent friend requests (array of uids)
    final userDoc =
        await firestore.collection('users').doc(currentUserId).get();
    final sentRequests =
        userDoc.data()?['friendRequestsSent'] as List<dynamic>? ?? [];

    // Fetch details of each user in the sentRequests array
    final List<Map<String, dynamic>> sentRequestDetails = [];
    for (var sentUid in sentRequests) {
      final querySnapshot = await firestore
          .collection('users')
          .where('uid', isEqualTo: sentUid)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        final userData = querySnapshot.docs.first.data();
        sentRequestDetails.add({
          'profilePhotoURL': userData['profilePhotoURL'],
          'firstName': userData['firstName'],
          'lastName': userData['lastName'],
          'username': userData['username'],
        });
      }
    }

    return sentRequestDetails;
  }

  @override
  Widget build(BuildContext context) {
    final authState = Provider.of<AuthenticationState>(context);
    final currentUserId = authState.user?.uid;

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
                builder: (context) => AddFriendPopup(authState: authState),
              );
            },
          ),
        ],
      ),
      backgroundColor: Colors.black,
      body: FutureBuilder<List<List<Map<String, dynamic>>>>(
        future: Future.wait([
          getFriendRequests(currentUserId!),
          getFriends(currentUserId),
          getSentFriendRequests(currentUserId),
        ]),
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
            final friendRequests = snapshot.data![0];
            final friends = snapshot.data![1];
            final sentRequests = snapshot.data![2];

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
                      photoURL: friend['profilePhotoURL']!,
                      name: '${friend['firstName']} ${friend['lastName']}',
                      username: friend['username']!,
                      actions: [
                        TextButton(
                          onPressed: () => authState.user
                              ?.acceptFriendRequest(friend['uid']),
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
                      photoURL: friend['profilePhotoURL']!,
                      name: '${friend['firstName']} ${friend['lastName']}',
                      username: friend['username']!,
                      actions: [
                        TextButton(
                          onPressed: () async {
                            final targetUid =
                                friend['uid']; // Ensure this is not null
                            if (targetUid != null) {
                              await authState.user
                                  ?.cancelFriendRequest(targetUid);
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
  final String photoURL;
  final String name;
  final String username;
  final List<Widget> actions;

  const FriendTile({
    required this.photoURL,
    required this.name,
    required this.username,
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
          backgroundImage: NetworkImage(photoURL),
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

class AddFriendPopup extends StatefulWidget {
  final AuthenticationState authState;

  const AddFriendPopup({required this.authState, super.key});

  @override
  // ignore: library_private_types_in_public_api
  _AddFriendPopupState createState() => _AddFriendPopupState();
}

class _AddFriendPopupState extends State<AddFriendPopup> {
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _searchResults = [];
  bool _isLoading = false;

  Future<void> _searchUsers(String username) async {
    // Remove the '@' symbol if it exists at the beginning of the username
    if (username.startsWith('@')) {
      username = username.substring(1);
    }

    if (username.isEmpty) {
      setState(() {
        _searchResults = [];
      });
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final firestore = FirebaseFirestore.instance;
    final currentUserId = widget.authState.user?.uid;
    final querySnapshot = await firestore
        .collection('users')
        .where('username', isGreaterThanOrEqualTo: username)
        .where('username', isLessThanOrEqualTo: '$username\uf8ff')
        .get();

    setState(() {
      _searchResults = querySnapshot.docs
          .where((doc) => doc['uid'] != currentUserId)
          .map((doc) => {
                'uid': doc['uid'],
                'profilePhotoURL': doc['profilePhotoURL'],
                'firstName': doc['firstName'],
                'lastName': doc['lastName'],
                'username': doc['username'],
              })
          .toList();
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.grey[900],
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _searchController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: '@username',
                hintStyle: const TextStyle(color: Colors.grey),
                filled: true,
                fillColor: Colors.grey[800],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                  borderSide: BorderSide.none,
                ),
                prefixIcon: const Icon(Icons.search, color: Colors.white),
              ),
              onChanged: _searchUsers,
            ),
            const SizedBox(height: 8.0),
            const Text(
              '*case sensitive',
              style: TextStyle(color: Colors.orange, fontSize: 12.0),
            ),
            const SizedBox(height: 16.0),
            if (_isLoading)
              const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            else if (_searchResults.isEmpty)
              const Text(
                'No results found',
                style: TextStyle(color: Colors.orange),
              )
            else
              ..._searchResults.map((user) => ListTile(
                    leading: CircleAvatar(
                      backgroundImage: NetworkImage(user['profilePhotoURL']),
                    ),
                    title: Text(
                      '${user['firstName']} ${user['lastName']}',
                      style: const TextStyle(color: Colors.white),
                    ),
                    subtitle: Text(
                      '@${user['username']}',
                      style: const TextStyle(color: Colors.grey),
                    ),
                    trailing: TextButton(
                      onPressed: () {
                        widget.authState.user?.sendFriendRequest(user['uid']);
                        Navigator.of(context).pop();
                      },
                      child: const Text(
                        'Add Friend',
                        style: TextStyle(color: Colors.blue),
                      ),
                    ),
                  )),
          ],
        ),
      ),
    );
  }
}


// this is a good and working state...