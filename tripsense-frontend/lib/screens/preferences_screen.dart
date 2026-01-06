import 'package:flutter/material.dart';

class PreferencesScreen extends StatelessWidget {
  static const routeName = '/preferences';
  const PreferencesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Your Preferences')),
      body: const SafeArea(
        child: Center(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.explore, size: 64),
                SizedBox(height: 16),
                Text(
                  'Welcome to TripSense',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
                ),
                SizedBox(height: 8),
                Text(
                  'This is a placeholder preferences page. After successful login, you\'ll land here to set travel interests and preferences.',
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
