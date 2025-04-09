import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flavr/providers/authentication_state.dart';
import 'package:flutter/material.dart';

class AddFriendPopup extends StatefulWidget {
  final AuthenticationState authState;
  final VoidCallback onFriendRequestSent; // Add this callback

  const AddFriendPopup({
    required this.authState,
    required this.onFriendRequestSent, // Pass the callback
    super.key,
  });

  @override
  // ignore: library_private_types_in_public_api
  _AddFriendPopupState createState() => _AddFriendPopupState();
}

class _AddFriendPopupState extends State<AddFriendPopup> {
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _searchResults = [];
  bool _isLoading = false;

  Future<void> _searchUsers(String username) async {
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

    // Fetch the current user's friends list
    final currentUserDoc =
        await firestore.collection('users').doc(currentUserId).get();
    final currentUserFriends =
        List<String>.from(currentUserDoc.data()?['friends'] ?? []);

    final querySnapshot = await firestore
        .collection('users')
        .where('username', isGreaterThanOrEqualTo: username)
        .where('username', isLessThanOrEqualTo: '$username\uf8ff')
        .get();

    setState(() {
      _searchResults = querySnapshot.docs
          .where((doc) =>
              doc['uid'] != currentUserId && // Exclude the current user
              !currentUserFriends.contains(doc['uid'])) // Exclude friends
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
                        widget.onFriendRequestSent(); // Trigger the callback
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
