import 'package:flutter/material.dart';

class SidebarWidget extends StatelessWidget {
  const SidebarWidget({super.key});

  @override
  Widget build(BuildContext context) {
    // Define colors based on the wireframe (dark theme)
    const Color sidebarColor = Color(0xFF2C2C2E); // Slightly off-black
    const Color cardColor = Color(0xFF3A3A3C); // Dark grey for cards
    const Color stackedCardColor = Color(0xFF636366); // Lighter grey for stacked cards
    const double cardSize = 70.0;
    const double cardSpacing = 15.0;
    const BorderRadius cardBorderRadius = BorderRadius.all(Radius.circular(16.0));
    // Define sidebar rounding
    const BorderRadius sidebarBorderRadius = BorderRadius.all(Radius.circular(20.0));

    return Container(
      width: 120.0, // Fixed width for the sidebar
      // Apply decoration for color and rounding
      decoration: BoxDecoration(
        color: sidebarColor,
        borderRadius: sidebarBorderRadius,
      ),
      padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 15.0),
      child: Column(
        children: [
          // Top Status Icon (e.g., 5G)
          Container(
            width: cardSize,
            height: cardSize,
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: cardBorderRadius,
            ),
            child: const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.signal_cellular_alt, color: Colors.white, size: 24),
                  Text("5G", style: TextStyle(color: Colors.white, fontSize: 12)),
                ],
              ),
            ),
          ),
          const SizedBox(height: cardSpacing),

          // App Icons Placeholder (3 vertically)
          _buildAppIconPlaceholder(cardColor, cardBorderRadius, cardSize),
          const SizedBox(height: cardSpacing),
          _buildAppIconPlaceholder(cardColor, cardBorderRadius, cardSize),
          const SizedBox(height: cardSpacing),
          _buildAppIconPlaceholder(cardColor, cardBorderRadius, cardSize),

          const Spacer(), // Pushes the bottom icon to the bottom

          // Bottom Icon (formerly stacked cards)
          _buildAppIconPlaceholder(stackedCardColor, cardBorderRadius, cardSize, Icons.layers),

          const SizedBox(height: cardSpacing), // Some padding at the bottom
        ],
      ),
    );
  }

  Widget _buildAppIconPlaceholder(Color color, BorderRadius borderRadius, double size, [IconData? iconData]) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        borderRadius: borderRadius,
      ),
      // In a real app, you'd have an Icon or Image here
      child: Icon(iconData ?? Icons.apps, color: Colors.white54, size: 30), // Placeholder icon
    );
  }
} 