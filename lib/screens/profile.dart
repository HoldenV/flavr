//code for the profile page on the UI

import 'package:flutter/material.dart'; //import statement for Flutter material package

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Flavr Profile'),
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
            const Center(
              child: Text(
                'John Doe',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
            ),

            const SizedBox(height: 10),
            const Text(
              'User Information',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
            ),
            const Divider( //line to divide up sections
              color: Colors.black, thickness: 2,
            ),

            const SizedBox(height: 10),
            const Text(
              'Preferences',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
            ),
            const Divider( //line to divide up sections
              color: Colors.black, thickness: 2,
            ),
          ]
        ),
      )
    );
  }
}