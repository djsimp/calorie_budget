import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class SignOutButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: () async {
        bool confirmSignOut =
            await showDialog(context: context, builder: _alertDialog) ?? false;
        if (confirmSignOut) {
          await FirebaseAuth.instance.signOut();
          while (Navigator.of(context).canPop()) Navigator.of(context).pop();
        }
      },
      icon: Icon(Icons.logout),
    );
  }

  AlertDialog _alertDialog(BuildContext context) => AlertDialog(
        title: Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('NO'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('YES'),
          ),
        ],
      );
}
