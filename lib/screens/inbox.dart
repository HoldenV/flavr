import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class InboxScreen extends StatelessWidget {
  const InboxScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Text(
              'Inbox',
              style: GoogleFonts.oi(),
            ),
          ],
        ),
      ),
      body: const Center(
        child: Text(
          'No new notifications!',
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }
}
