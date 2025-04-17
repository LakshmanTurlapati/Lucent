import 'package:flutter/material.dart';
import 'package:lucent/screens/home_screen.dart'; // Import the new home screen

void main() {
  runApp(const LucentApp());
}

class LucentApp extends StatelessWidget {
  const LucentApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Lucent',
      theme: ThemeData(
        // Use a base dark theme
        brightness: Brightness.dark,
        // Define primary swatch or seed color if needed, though brightness: dark handles a lot
        // colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue, brightness: Brightness.dark),
        scaffoldBackgroundColor: const Color(0xFF1C1C1E), // Match HomeScreen background
        // Ensure text is visible on dark backgrounds
        textTheme: ThemeData.dark().textTheme.apply(
              bodyColor: Colors.white,
              displayColor: Colors.white,
            ),
        useMaterial3: true,
      ),
      debugShowCheckedModeBanner: false, // Remove debug banner
      home: const HomeScreen(), // Set HomeScreen as the home
    );
  }
}

// The default MyHomePage and _MyHomePageState classes can be removed.
