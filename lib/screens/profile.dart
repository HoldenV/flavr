//code for the profile page on the UI

import 'package:flutter/material.dart'; //import statement for Flutter material package

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

//New screen or just changes mode, flit around with

class _ProfileScreenState extends State<ProfileScreen> {
  bool isEditing = false; //track whether editing or viewing by user
  final TextEditingController userName = TextEditingController(); //handle user input for username
  final TextEditingController emailName = TextEditingController(); //handle user input for email
  final TextEditingController phoneNumber = TextEditingController(); //handle user input for phone number
  final TextEditingController foodRestrictions = TextEditingController(); //handle user input for food restrictions

  @override
  void initState() {
    super.initState(); //default info from UI mock up
    userName.text = 'John Doe';
    emailName.text = 'header@gmail.com';
    phoneNumber.text = '913-000-0000';
    foodRestrictions.text = 'GF \n Vegan \n Allergens';
  }

  void changeEdit() {
    setState(() {
      isEditing = !isEditing;
    });
  }

  void saveProfile() {
    setState(() {
      isEditing = false; //once saved bool = false
    });
    ScaffoldMessenger.of(context).showSnackBar( //snackbar kinda like a pop up
      SnackBar(content: Text('Profile Saved')),
    );
  }

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
                    subtitle: Text('thisismyusername',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 15, color: Colors.white),
                    ),
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
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white),
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
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                  ),
                  ListTile(
                    title: Text('Restaurant Distance:'),
                    subtitle: Text(
                      'slider here eventually',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
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