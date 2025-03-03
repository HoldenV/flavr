//code for the profile page on the UI

import 'package:flutter/material.dart'; //import statement for Flutter material package

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final TextEditingController userName = TextEditingController(); //handle user input

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Profile'),
      ),

      body: Padding(
        padding: const EdgeInsets.all(15.0), //15 pixels
        child: Column(
          children: [
            const Center(
              child: CircleAvatar( //circle for profile image to fill
                radius: 70,
                backgroundImage: AssetImage('lib/assets/default_profile.png'),
                //not loading correctly, try new path --> update pubspec.yaml assets to fix
              )
            ),
            
            const SizedBox(height: 10), //space between pic and text for name
            TextField (
              controller: userName,
              decoration: const InputDecoration(
                labelText: 'Name', //label
                border: OutlineInputBorder(),
              ),
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 10),
            const Text(
              'User Information',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
            ),
            const Divider( //line to divide up sections
              color: Colors.black, thickness: 2,
            ),
            Expanded(
              child: ListView(
                children: const [
                  ListTile(
                    title: Text('Username:'),
                    subtitle: Text('thisismyusername'),
                  ),
                  ListTile(
                    title: Text('Phone Number:'),
                    subtitle: Text('913-579-2305'),
                  ),
                ]
              ),
            ),

            const SizedBox(height: 10),
            const Text(
              'Preferences',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
            ),
            const Divider( //line to divide up sections
              color: Colors.black, thickness: 2,
            ),
            Expanded(
              child: ListView(
                children: const [
                  ListTile(
                    title: Text('Dietary Restrictions:'),
                    subtitle: Text(
                      "can't eat here",
                      style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
                    ),
                  ),
                  ListTile(
                    title: Text('Restaurant Distance:'),
                    subtitle: Text(
                      'slider here eventually',
                      style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
                    ),
                  ),
                ]
              ),
            ),
          ]
        ),
      )
    );
  }
}