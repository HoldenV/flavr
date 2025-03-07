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
          borderRadius: BorderRadius.vertical(top: Radius.circular(0.0)),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.vertical(top: Radius.circular(0.0)),
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
            items: [
              _buildBottomNavigationBarItem(
                  context, Icons.home, 'Home', appState.currentIndex == 0),
              _buildBottomNavigationBarItem(
                  context, Icons.people, 'Friends', appState.currentIndex == 1),
              _buildBottomNavigationBarItem(
                  context, Icons.inbox, 'Inbox', appState.currentIndex == 2),
              _buildBottomNavigationBarItem(
                  context, Icons.person, 'Profile', appState.currentIndex == 3),
            ],
          ),
        ),
      );
    },
  );
}

BottomNavigationBarItem _buildBottomNavigationBarItem(
    BuildContext context, IconData icon, String label, bool isSelected) {
  return BottomNavigationBarItem(
    icon: Container(
      decoration: BoxDecoration(
        color: isSelected ? Colors.orange : Colors.transparent,
        shape: BoxShape.circle,
      ),
      padding: const EdgeInsets.all(8.0),
      child: Icon(
        icon,
        size: 20.0, // Icon size
        color: Colors.white,
      ),
    ),
    label: label,
  );
}
