import 'package:flutter/material.dart';

class BatteryWidget extends StatelessWidget {
  const BatteryWidget({super.key});

  @override
  Widget build(BuildContext context) {
    // Get theme colors
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primaryTextColor = theme.textTheme.bodyLarge?.color ?? Colors.white;
    final secondaryTextColor = theme.textTheme.bodySmall?.color ?? Colors.white70;
    final cardColor = isDark ? const Color(0xFF3A3A3C) : Colors.white;
    final trackColor = isDark ? Colors.grey.shade800 : Colors.grey.shade300;
    
    // EV Battery Constants
    final batteryPercentage = 75.0; // 75% battery remaining
    final rangeLeftMiles = 249; // 249 miles remaining
    const energyPerMile = 40; // 40 Wh/mile
    const totalCapacity = 15.5; // 15.5 kWh total capacity
    
    // Colors
    final accentColor = isDark ? const Color(0xFFFF9500) : const Color(0xFF007AFF); // Orange in dark, blue in light
    final batteryLowColor = Colors.red.shade600;
    final batteryMedColor = Colors.yellow.shade700;
    final batteryHighColor = Colors.green.shade600;
    
    // Dynamic battery color based on percentage
    Color getBatteryColor(double percentage) {
      if (percentage <= 20) return batteryLowColor;
      if (percentage <= 50) return batteryMedColor;
      return batteryHighColor;
    }
    
    final batteryColor = getBatteryColor(batteryPercentage);

    return Container(
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16.0),
      ),
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 15.0),
      child: LayoutBuilder(
        builder: (context, constraints) {
          // With more vertical space, we can use slightly larger fonts
          const double headerFontSize = 14.0;
          const double valueFontSize = 11.0;
          const double labelFontSize = 9.0;
          const double batteryHeight = 8.0;
          
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header - Battery Percentage with larger icon
              Row(
                children: [
                  Text(
                    "Battery Status",
                    style: TextStyle(
                      color: primaryTextColor,
                      fontSize: headerFontSize,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    "${batteryPercentage.toInt()}%",
                    style: TextStyle(
                      color: batteryColor,
                      fontSize: headerFontSize,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    Icons.battery_charging_full,
                    color: batteryColor,
                    size: headerFontSize + 4,
                  ),
                ],
              ),
              
              const SizedBox(height: 10),
              
              // Battery Bar (thicker with more space)
              Container(
                height: batteryHeight,
                decoration: BoxDecoration(
                  color: trackColor,
                  borderRadius: BorderRadius.circular(batteryHeight / 2),
                ),
                child: Row(
                  children: [
                    // Filled portion
                    Flexible(
                      flex: batteryPercentage.toInt(),
                      child: Container(
                        decoration: BoxDecoration(
                          color: batteryColor,
                          borderRadius: BorderRadius.circular(batteryHeight / 2),
                        ),
                      ),
                    ),
                    // Empty portion
                    Flexible(
                      flex: (100 - batteryPercentage).toInt(),
                      child: Container(),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 12),
              
              // Battery stats with more spacing
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Range left
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "$rangeLeftMiles mi",
                        style: TextStyle(
                          color: primaryTextColor,
                          fontSize: valueFontSize,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        "Range",
                        style: TextStyle(
                          color: secondaryTextColor,
                          fontSize: labelFontSize,
                        ),
                      ),
                    ],
                  ),
                  
                  // Energy usage per mile
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        "$energyPerMile Wh/mi",
                        style: TextStyle(
                          color: primaryTextColor,
                          fontSize: valueFontSize,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        "Energy Usage",
                        style: TextStyle(
                          color: secondaryTextColor,
                          fontSize: labelFontSize,
                        ),
                      ),
                    ],
                  ),
                  
                  // Total capacity
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        "$totalCapacity kWh",
                        style: TextStyle(
                          color: primaryTextColor,
                          fontSize: valueFontSize,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        "Capacity",
                        style: TextStyle(
                          color: secondaryTextColor,
                          fontSize: labelFontSize,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          );
        }
      ),
    );
  }
} 