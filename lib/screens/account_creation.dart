import 'package:firebase_auth/firebase_auth.dart';
import 'package:flavr/widgets/app_state_wrapper.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
// import 'package:firebase_storage/firebase_storage.dart';
import '../models/user.dart';
import '../providers/authentication_state.dart';

class AccountCreationScreen extends StatefulWidget {
  final UserCredential userCredential;

  const AccountCreationScreen({super.key, required this.userCredential});

  @override
  AccountCreationState createState() => AccountCreationState();
}

class AccountCreationState extends State<AccountCreationScreen> {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController bioController = TextEditingController();

  // Function to create the user account
  Future<void> createAccount() async {
    final uid = widget.userCredential.user?.uid;
    final email = widget.userCredential.user?.email;
    final profilePhotoUrl = widget.userCredential.user?.photoURL;

    if (uid == null || email == null) {
      _showSnackBar('Error: Missing user information');
      return;
    }

    if (usernameController.text.trim().isEmpty ||
        firstNameController.text.trim().isEmpty ||
        lastNameController.text.trim().isEmpty) {
      _showSnackBar('Error: All fields are required');
      return;
    }

    // Create the UserModel
    final userModel = UserModel(
      uid: uid,
      email: email,
      username: usernameController.text.trim(),
      firstName: firstNameController.text.trim(),
      lastName: lastNameController.text.trim(),
      bio: bioController.text.trim(),
      profilePhotoURL: profilePhotoUrl,
      accountCreationDatetime: DateTime.now(),
    );

    try {
      // Save the UserModel to Firestore
      await userModel.saveToFirestore();

      // Notify the AuthenticationState of the successful account creation
      if (!mounted) return;
      final authState =
          Provider.of<AuthenticationState>(context, listen: false);
      await authState.initializeAuthState();

      // Navigate to the main app screen
      if (!mounted) return;
      _navigateToMainScreen();
    } catch (e) {
      print('Error: $e');
      _showSnackBar('Error: $e');
    }
  }

  void _showSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    }
  }

  void _navigateToMainScreen() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => const AppStateWrapper()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:
            const Text('Create Account', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.black,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Complete Your Profile',
              style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: usernameController,
              decoration: const InputDecoration(
                labelText: 'Username',
                labelStyle: TextStyle(color: Colors.white),
              ),
              style: const TextStyle(color: Colors.white),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: firstNameController,
              decoration: const InputDecoration(
                labelText: 'First Name',
                labelStyle: TextStyle(color: Colors.white),
              ),
              style: const TextStyle(color: Colors.white),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: lastNameController,
              decoration: const InputDecoration(
                labelText: 'Last Name',
                labelStyle: TextStyle(color: Colors.white),
              ),
              style: const TextStyle(color: Colors.white),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: bioController,
              decoration: const InputDecoration(
                labelText: 'Bio',
                labelStyle: TextStyle(color: Colors.white),
              ),
              style: const TextStyle(color: Colors.white),
              maxLines: 3,
            ),
            const SizedBox(height: 20),
            const SizedBox(height: 20),
            Center(
              child: ElevatedButton(
                onPressed: createAccount,
                child: const Text('Create Account'),
              ),
            ),
          ],
        ),
      ),
      backgroundColor: Colors.black,
    );
  }
}
