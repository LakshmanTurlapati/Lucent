import 'package:flutter/material.dart';
import 'placeholder_card.dart';
import 'weather_widget.dart';
import 'battery_widget.dart';
import 'widget_stack.dart';

class LeftContentColumn extends StatelessWidget {
  const LeftContentColumn({super.key});

  @override
  Widget build(BuildContext context) {
    // Get theme colors
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    
    // Use consistent styling from other widgets
    final Color placeholderColor = isDarkMode ? const Color(0xFF3A3A3C) : const Color(0xFFE5E5EA);
    final BorderRadius placeholderBorderRadius = const BorderRadius.all(Radius.circular(16.0));
    final double placeholderSpacing = 12.0; // Reduced spacing

    return LayoutBuilder(
      builder: (context, constraints) {
        // Get the available height and width
        final double availableHeight = constraints.maxHeight;
        final double availableWidth = constraints.maxWidth;
        
        // Calculate widget sizes to fit perfectly within the available height
        // Battery widget is smaller, and the other two widgets share the remaining space evenly
        final double batteryHeight = availableHeight * 0.20; // Increased from 15% to 20% of total height
        
        // Calculate remaining height after battery widget and spacing
        final double remainingHeight = availableHeight - batteryHeight - (placeholderSpacing * 3);
        
        // Weather and widget stack each get about half of the remaining space
        final double weatherHeight = remainingHeight * 0.48; // 48% of remaining
        final double stackHeight = remainingHeight * 0.48; // 48% of remaining
        
        // Create the content column that fills the entire available height
        return Column(
          mainAxisSize: MainAxisSize.max, // Fill all available vertical space
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            // Battery widget at the top - takes less vertical space
            SizedBox(
              height: batteryHeight,
              width: availableWidth,
              child: const BatteryWidget(),
            ),
            SizedBox(height: placeholderSpacing),
            
            // Weather widget in the middle
            SizedBox(
              width: availableWidth,
              height: weatherHeight,
              child: const WeatherWidget(
                // Pass initial values that will show while loading
                initialTemperature: 72.0, 
                initialCondition: 'Partly Cloudy', 
                initialLocation: 'Richardson, TX',
                initialWeatherIcon: Icons.wb_cloudy,
              ),
            ),
            SizedBox(height: placeholderSpacing),
            
            // Widget stack at the bottom (replaces music player)
            SizedBox(
              width: availableWidth,
              height: stackHeight,
              child: Stack(
                clipBehavior: Clip.none, // Allow content to overflow outside the container
                children: [
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        color: isDarkMode ? const Color(0xFF171717) : const Color(0xFFE8E8E8),
                        borderRadius: BorderRadius.circular(16.0),
                      ),
                    ),
                  ),
                  const WidgetStack(), // Use the new WidgetStack
                ],
              ),
            ),
            
            // Small padding at the bottom for visual balance
            SizedBox(height: placeholderSpacing),
          ],
        );
      }
    );
  }
} 