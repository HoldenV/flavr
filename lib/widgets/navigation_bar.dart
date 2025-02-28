import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flavr/providers/app_state.dart';
import 'package:flavr/screens/home.dart';
import 'package:flavr/screens/friends.dart';
import 'package:flavr/screens/inbox.dart';
import 'package:flavr/screens/profile.dart';

Widget useBottomNavigationBar(BuildContext context) {
  return Consumer<AppState>(
    builder: (context, appState, _) {
      return Container(
        decoration: BoxDecoration(
          color: Theme.of(context).bottomNavigationBarTheme.backgroundColor,
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 5,
              offset: const Offset(0, -1),
            ),
          ],
        ),
        child: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          currentIndex: appState.currentIndex,
          backgroundColor:
              Theme.of(context).bottomNavigationBarTheme.backgroundColor,
          selectedItemColor:
              Theme.of(context).bottomNavigationBarTheme.selectedItemColor,
          unselectedItemColor:
              Theme.of(context).bottomNavigationBarTheme.unselectedItemColor,
          onTap: (index) {
            switch (index) {
              case 0:
                appState.setCurrentScreen(HomeScreen(), index);
              case 1:
                appState.setCurrentScreen(const FriendsScreen(), index);
              case 2:
                appState.setCurrentScreen(const InboxScreen(), index);
              case 3:
                appState.setCurrentScreen(const ProfileScreen(), index);
            }
          },
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.people),
              label: 'Friends',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.inbox),
              label: 'Inbox',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person),
              label: 'Profile',
            ),
          ],
        ),
      );
    },
  );
}
