import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/authentication_state.dart';

class AccountCreationScreen extends StatefulWidget {
  @override
  AccountCreationState createState() => AccountCreationState();
}

class AccountCreationState extends State<AccountCreationScreen> {
  final TextEditingController _usernameController = TextEditingController();

  void _createAccount() async {
    String username = _usernameController.text;
    final authState = Provider.of<AuthenticationState>(context, listen: false);
    if (authState.userModel != null) {
      await authState.userModel!.updateUsername(username);
      authState.checkUsernameAndNavigate(context, authState);
    }
    print('Username: $username');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Create Account'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              TextField(
                controller: _usernameController,
                decoration: InputDecoration(
                  labelText: 'Username',
                  labelStyle: TextStyle(color: Colors.white),
                ),
                style: TextStyle(color: Colors.white),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _createAccount,
                child: Text('Create Account'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
