import 'dart:typed_data';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flavr/widgets/app_state_wrapper.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
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
  Uint8List? profilePhoto;

  final ImagePicker picker = ImagePicker();

  // Function to pick a profile photo
  Future<void> pickProfilePhoto() async {
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      final bytes = await image.readAsBytes();
      setState(() {
        profilePhoto = Uint8List.fromList(bytes);
      });
    }
  }

  // Function to create the user account
  Future<void> createAccount() async {
    final uid = widget.userCredential.user?.uid;
    final email = widget.userCredential.user?.email;

    if (uid == null || email == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error: Missing user information')),
      );
      return;
    }

    if (usernameController.text.trim().isEmpty ||
        firstNameController.text.trim().isEmpty ||
        lastNameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error: All fields are required')),
      );
      return;
    }

    String? profilePhotoUrl;

    // Upload profile photo to Firebase Storage if it exists
    // if (profilePhoto != null) {
    //   try {
    //     final storageRef = FirebaseStorage.instance
    //         .ref()
    //         .child('profile_photos/$uid.jpg'); // Use UID for unique naming
    //     final uploadTask = await storageRef.putData(profilePhoto!);
    //     profilePhotoUrl = await uploadTask.ref.getDownloadURL();
    //   } catch (e) {
    //     print('Error uploading profile photo: $e');
    //     // ignore: use_build_context_synchronously
    //     ScaffoldMessenger.of(context).showSnackBar(
    //       SnackBar(
    //           content: Text('Error uploading profile photo: ${e.toString()}')),
    //     );
    //     return;
    //   }
    // }

    // Create the UserModel
    final userModel = UserModel(
      uid: uid,
      email: email,
      username: usernameController.text.trim(),
      firstName: firstNameController.text.trim(),
      lastName: lastNameController.text.trim(),
      bio: bioController.text.trim(),
      profilePhotoURL: profilePhotoUrl,
    );

    try {
      // Save the UserModel to Firestore
      await userModel.saveToFirestore();

      // Reinitialize the AuthenticationState
      if (!mounted) return;
      final authState =
          Provider.of<AuthenticationState>(context, listen: false);
      await authState.initializeAuthState();

      // Navigate to the AppStateWrapper
      // ignore: use_build_context_synchronously
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const AppStateWrapper()),
      );
    } catch (e) {
      print('Error: $e');
    }
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
            // Row(
            //   children: [
            //     ElevatedButton(
            //       onPressed: pickProfilePhoto,
            //       child: const Text('Pick Profile Photo'),
            //     ),
            //     const SizedBox(width: 10),
            //     if (profilePhoto != null)
            //       const Text(
            //         'Photo Selected',
            //         style: TextStyle(color: Colors.green),
            //       ),
            //   ],
            // ),
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
