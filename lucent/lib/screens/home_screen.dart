import 'package:flutter/material.dart';
import '../widgets/sidebar_widget.dart';
import '../widgets/left_content_column.dart';
import '../widgets/main_content_widget.dart';
import '../widgets/settings_widget.dart';
import '../theme/app_themes.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Track whether settings are currently being shown
  bool _showSettings = false;

  @override
  Widget build(BuildContext context) {
    // Use theme colors instead of hardcoded colors
    final theme = Theme.of(context);
    final AppThemeExtension? themeExtension = theme.extension<AppThemeExtension>();
    
    return Scaffold(
      // Use theme background color
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        // SafeArea avoids status bar overlap etc.
        // Add padding to simulate the white border around the entire content area
        child: Padding(
          padding: const EdgeInsets.all(16.0),  // Slightly reduced padding for better fit
          child: Stack(
            children: [
              // Main layout
              Row(
                crossAxisAlignment: CrossAxisAlignment.stretch, // Stretch items to fill vertical space
                children: [
                  // 1. Left Sidebar with icons
                  SidebarWidget(
                    onSettingsTap: () {
                      setState(() {
                        _showSettings = true;
                      });
                    },
                  ),

                  const SizedBox(width: 16.0),  // Spacing between sidebar and content

                  // 2. Middle Column (Weather, Time, Music Player)
                  // Use Expanded with a smaller flex factor
                  const Expanded(
                    flex: 2, // Adjust flex factor as needed for desired width ratio
                    child: LeftContentColumn(),
                  ),

                  const SizedBox(width: 16.0),  // Spacing between columns

                  // 3. Right Column (Map) - DO NOT MODIFY this widget per requirements
                  // The map widget should remain untouched
                  const Expanded(
                    flex: 5, // Keep the map larger than the left content
                    child: MainContentWidget(), // This is the map widget that should not be modified
                  ),
                ],
              ),
              
              // Settings overlay
              if (_showSettings)
                Positioned.fill(
                  child: Container(
                    // Use theme overlay color
                    color: themeExtension?.overlayColor ?? Colors.black.withOpacity(0.7),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(106.0, 16.0, 16.0, 16.0), // Left padding after sidebar
                      child: SettingsWidget(
                        onClose: () {
                          setState(() {
                            _showSettings = false;
                          });
                        },
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
} 