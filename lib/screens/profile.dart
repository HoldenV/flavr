import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/authentication_state.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool isVeganOnly = false;
  bool isGFOnly = false;
  bool isAllergenFree = false;
  double restaurantDistance = 50;

  @override
  Widget build(BuildContext context) {
    final authState = Provider.of<AuthenticationState>(context);
    final photoURL = authState.user?.profilePhotoURL;
    final firstName = authState.user?.firstName ?? 'First';
    final lastName = authState.user?.lastName ?? 'Last';
    final username = authState.user?.username ?? 'username';

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Text(
              'Profile',
              style: GoogleFonts.oi(),
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
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
            Text(
              '$firstName $lastName',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              '@$username',
              style: const TextStyle(
                color: Colors.grey,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 30),
            const Divider(color: Colors.white, thickness: 1),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Vegan Only',
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
                Switch(
                  value: isVeganOnly,
                  onChanged: (value) {
                    setState(() {
                      isVeganOnly = value;
                    });
                  },
                  activeColor: Colors.orange,
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'GF Only',
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
                Switch(
                  value: isGFOnly,
                  onChanged: (value) {
                    setState(() {
                      isGFOnly = value;
                    });
                  },
                  activeColor: Colors.orange,
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Allergen Free',
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
                Switch(
                  value: isAllergenFree,
                  onChanged: (value) {
                    setState(() {
                      isAllergenFree = value;
                    });
                  },
                  activeColor: Colors.orange,
                ),
              ],
            ),
            const SizedBox(height: 20),
            const Text(
              'Maximum Travel Distance',
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
            Slider(
              value: restaurantDistance,
              min: 0,
              max: 100,
              divisions: 10,
              label: '${restaurantDistance.toInt()} miles',
              onChanged: (value) {
                setState(() {
                  restaurantDistance = value;
                });
              },
              activeColor: Colors.orange,
              inactiveColor: Colors.grey,
            ),
            const SizedBox(height: 30),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  final authState =
                      Provider.of<AuthenticationState>(context, listen: false);
                  authState.signOut();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
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
    );
  }
}
