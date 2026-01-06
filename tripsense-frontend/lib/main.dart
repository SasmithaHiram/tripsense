import 'package:flutter/material.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/preferences_screen.dart';
import 'screens/location_screen.dart';
import 'screens/dates_screen.dart';
import 'screens/constraints_screen.dart';
import 'screens/dashboard_screen.dart';
import 'screens/profile_screen.dart';

void main() {
  runApp(const TripSenseApp());
}

class TripSenseApp extends StatelessWidget {
  const TripSenseApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TripSense',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        useMaterial3: true,
      ),
      initialRoute: LoginScreen.routeName,
      routes: {
        LoginScreen.routeName: (_) => const LoginScreen(),
        RegisterScreen.routeName: (_) => const RegisterScreen(),
        PreferencesScreen.routeName: (_) => const PreferencesScreen(),
        LocationScreen.routeName: (_) => const LocationScreen(),
        DatesScreen.routeName: (_) => const DatesScreen(),
        ConstraintsScreen.routeName: (_) => const ConstraintsScreen(),
        DashboardScreen.routeName: (_) => const DashboardScreen(),
        ProfileScreen.routeName: (_) => const ProfileScreen(),
      },
    );
  }
}
