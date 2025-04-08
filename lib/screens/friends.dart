import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class FriendsScreen extends StatelessWidget {
  const FriendsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Mock data for demonstration
    final friendRequests = [
      {
        'photo': 'lib/assets/user_images/user1.png',
        'name': 'John Doe',
        'username': '@johndoe'
      },
      {
        'photo': 'lib/assets/user_images/user2.png',
        'name': 'Jane Smith',
        'username': '@janesmith'
      },
    ];
    final currentFriends = [
      {
        'photo': 'lib/assets/user_images/user3.png',
        'name': 'Alice Johnson',
        'username': '@alicej'
      },
      {
        'photo': 'lib/assets/user_images/user4.png',
        'name': 'Bob Brown',
        'username': '@bobb'
      },
    ];
    final sentRequests = [
      {
        'photo': 'lib/assets/user_images/user5.png',
        'name': 'Charlie Davis',
        'username': '@charlied'
      },
    ];

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
              print('Person add icon pressed');
            },
          ),
        ],
      ),
      backgroundColor: Colors.black,
      body: ListView(
        children: [
          // Friend Requests Section
          if (friendRequests.isNotEmpty) ...[
            const SectionHeader(title: 'Friend Requests'),
            ...friendRequests.map((friend) => FriendTile(
                  photo: friend['photo']!,
                  name: friend['name']!,
                  username: friend['username']!,
                  actions: [
                    TextButton(
                      onPressed: () => print('Accepted ${friend['username']}'),
                      child: const Text('Accept',
                          style: TextStyle(color: Colors.green)),
                    ),
                    TextButton(
                      onPressed: () => print('Rejected ${friend['username']}'),
                      child: const Text('Reject',
                          style: TextStyle(color: Colors.red)),
                    ),
                  ],
                )),
          ],

          // Current Friends Section
          if (currentFriends.isNotEmpty) ...[
            const SectionHeader(title: 'Current Friends'),
            ...currentFriends.map((friend) => FriendTile(
                  photo: friend['photo']!,
                  name: friend['name']!,
                  username: friend['username']!,
                  actions: [
                    TextButton(
                      onPressed: () => print('Invited ${friend['username']}'),
                      child: const Text('Invite',
                          style: TextStyle(color: Colors.blue)),
                    ),
                  ],
                )),
          ],

          // Sent Requests Section
          if (sentRequests.isNotEmpty) ...[
            const SectionHeader(title: 'Sent Requests'),
            ...sentRequests.map((friend) => FriendTile(
                  photo: friend['photo']!,
                  name: friend['name']!,
                  username: friend['username']!,
                  actions: [
                    TextButton(
                      onPressed: () =>
                          print('Cancelled request to ${friend['username']}'),
                      child: const Text('Cancel',
                          style: TextStyle(color: Colors.orange)),
                    ),
                  ],
                )),
          ],
        ],
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
  final String photo;
  final String name;
  final String username;
  final List<Widget> actions;

  const FriendTile({
    required this.photo,
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
          backgroundImage: AssetImage(photo),
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
