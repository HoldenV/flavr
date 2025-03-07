import 'package:flutter/material.dart';

class AccountCreationScreen extends StatefulWidget {
  @override
  AccountCreationState createState() => AccountCreationState();
}

class AccountCreationState extends State<AccountCreationScreen> {
  final TextEditingController _usernameController = TextEditingController();

  void _createAccount() {
    String username = _usernameController.text;
    // Add the username to the user model here
    print('Username: $username');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Create Account'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            TextField(
              controller: _usernameController,
              decoration: InputDecoration(labelText: 'Username'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _createAccount,
              child: Text('Create Account'),
            ),
          ],
        ),
      ),
    );
  }
}
