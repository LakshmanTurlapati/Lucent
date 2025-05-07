import 'package:flutter/material.dart';
import 'package:lucent/screens/home_screen.dart'; // Import the new home screen
import 'package:provider/provider.dart';
import 'utils/music_service.dart';
import 'utils/theme_provider.dart';
import 'theme/app_themes.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => MusicService()),
        ChangeNotifierProvider(create: (context) => ThemeProvider()),
      ],
      child: const LucentApp(),
    ),
  );
}

class LucentApp extends StatelessWidget {
  const LucentApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Get current theme mode from provider
    final themeProvider = Provider.of<ThemeProvider>(context);
    
    return MaterialApp(
      title: 'Lucent',
      theme: AppThemes.getLightTheme(), // Light theme
      darkTheme: AppThemes.getDarkTheme(), // Dark theme
      themeMode: themeProvider.themeMode, // Current theme mode
      debugShowCheckedModeBanner: false, // Remove debug banner
      home: const HomeScreen(), // Set HomeScreen as the home
    );
  }
}

// The default MyHomePage and _MyHomePageState classes can be removed.
