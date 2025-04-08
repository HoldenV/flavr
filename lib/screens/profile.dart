import 'package:flutter/material.dart'; // Import statement for Flutter material package
import 'package:provider/provider.dart'; // Import Provider
import '../providers/authentication_state.dart'; // Import AuthenticationState

//Future edits
//  logarithmic scaling for slider
//  style app bar (match other screens) --> chunky font top left
//  remove gradient, black and dark gray/orange ish fill ins
//  make the slider always editable?
// link with authentication file

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool isEditing = false; // Editing boolean

  final TextEditingController userName = TextEditingController();
  final TextEditingController emailName = TextEditingController();
  final TextEditingController phoneNumber = TextEditingController();
  final TextEditingController foodRestrictions = TextEditingController();
  double restaurantDistance = 10;

  @override
  void initState() {
    super.initState();
    final authState = Provider.of<AuthenticationState>(context, listen: false);
    userName.text = authState.user?.username ?? 'John Doe';
    emailName.text = authState.user?.email ?? 'header@gmail.com';
    foodRestrictions.text = 'GF \n Vegan \n Allergens';
  }

  void toggleEdit() {
    setState(() {
      isEditing = !isEditing;
    });
  }

  void saveProfile() {
    setState(() {
      isEditing = false;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Profile Saved')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authState = Provider.of<AuthenticationState>(context);
    final photoURL = authState.user?.profilePhotoURL;

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title:
            const Text('Your Profile', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          TextButton(
            onPressed: isEditing ? saveProfile : toggleEdit,
            child: Text(
              isEditing ? 'Save' : 'Edit',
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.orange, Colors.purple],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: ListView(
            children: [
              Center(
                child: CircleAvatar(
                  radius: 70,
                  backgroundImage: (photoURL != null && photoURL.isNotEmpty)
                      ? NetworkImage(photoURL)
                      : const AssetImage('lib/assets/default_profile.png')
                          as ImageProvider,
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: userName,
                decoration: InputDecoration(
                  labelText: 'Name',
                  labelStyle: const TextStyle(color: Colors.white),
                  border: const OutlineInputBorder(),
                  enabledBorder: const OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.white),
                  ),
                  focusedBorder: const OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.white),
                  ),
                ),
                style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white),
                readOnly: !isEditing,
              ),
              const SizedBox(height: 15),
              const Text(
                'User Information',
                style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Colors.white),
              ),
              const Divider(color: Colors.white, thickness: 2),
              const SizedBox(height: 20),
              TextField(
                controller: emailName,
                decoration: InputDecoration(
                  labelText: 'Email',
                  labelStyle: const TextStyle(color: Colors.white),
                  border: const OutlineInputBorder(),
                  enabledBorder: const OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.white),
                  ),
                  focusedBorder: const OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.white),
                  ),
                ),
                style: const TextStyle(color: Colors.white),
                readOnly: !isEditing,
              ),
              const SizedBox(height: 10),
              TextField(
                controller: phoneNumber,
                decoration: InputDecoration(
                  labelText: 'Phone Number',
                  labelStyle: const TextStyle(color: Colors.white),
                  border: const OutlineInputBorder(),
                  enabledBorder: const OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.white),
                  ),
                  focusedBorder: const OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.white),
                  ),
                ),
                style: const TextStyle(color: Colors.white),
                readOnly: !isEditing,
              ),
              const SizedBox(height: 20),
              const Text(
                'Preferences',
                style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Colors.white),
              ),
              const Divider(color: Colors.white, thickness: 2),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.white),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
                      controller: foodRestrictions,
                      decoration: InputDecoration(
                        labelText: 'Dietary Restrictions',
                        labelStyle: const TextStyle(color: Colors.white),
                        border: const OutlineInputBorder(),
                        enabledBorder: const OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.white),
                        ),
                        focusedBorder: const OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.white),
                        ),
                      ),
                      style: const TextStyle(color: Colors.white),
                      maxLines: 3,
                      readOnly: !isEditing,
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Restaurant Distance:', //rename this is this descriptive enough?
                      style: TextStyle(color: Colors.white),
                    ),
                    Slider(
                      value: restaurantDistance,
                      min: 1,
                      max: 200,
                      divisions: 5,
                      label: '${restaurantDistance.toInt()} miles',
                      onChanged: isEditing
                          ? (double value) {
                              setState(() {
                                restaurantDistance = value;
                              });
                            }
                          : null,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    final authState = Provider.of<AuthenticationState>(context,
                        listen: false);
                    authState.signOut();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 30, vertical: 15),
                  ),
                  child: const Text(
                    'Sign Out',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
