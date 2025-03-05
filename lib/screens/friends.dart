import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class FriendsScreen extends StatelessWidget {
  const FriendsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Text(
              'Friends',
              style: GoogleFonts.oi(),
            ),
          ],
        ),
      ),
      body: const Center(
        child: Text('Add some friends!'),
      ),
    );
  }
}
