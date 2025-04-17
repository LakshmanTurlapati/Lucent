import 'package:flutter/material.dart';
import '../widgets/sidebar_widget.dart';
import '../widgets/left_content_column.dart';
import '../widgets/main_content_widget.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Use a dark background color similar to the wireframe overall background
    const Color backgroundColor = Color(0xFF1C1C1E); 

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        // SafeArea avoids status bar overlap etc.
        // Add padding to simulate the white border around the entire content area
        child: Padding(
          padding: const EdgeInsets.all(20.0),  // Increase overall page padding
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start, // Align items to the top
            children: [
              // 1. Left Sidebar
              SidebarWidget(),

              const SizedBox(width: 20.0),  // Increase horizontal spacing

              // 2. Middle Column (Placeholders)
              // Use Expanded with a smaller flex factor
              Expanded(
                flex: 2, // Adjust flex factor as needed for desired width ratio
                child: LeftContentColumn(),
              ),

              const SizedBox(width: 20.0),  // Increase horizontal spacing

              // 3. Right Column (Map)
              // Use Expanded with a larger flex factor
              Expanded(
                flex: 5,
                child: MainContentWidget(),
              ),
            ],
          ),
        ),
      ),
    );
  }
} 