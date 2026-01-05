import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

void _signOut() => FirebaseAuth.instance.signOut();

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text('Settings Screen'),
    );
  }
}
