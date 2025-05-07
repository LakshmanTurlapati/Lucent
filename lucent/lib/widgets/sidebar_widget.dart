import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import '../utils/asset_helper.dart';
import '../utils/time_format_provider.dart';
import '../theme/app_themes.dart';
import 'dart:async';

class SidebarWidget extends StatefulWidget {
  final VoidCallback? onSettingsTap;

  const SidebarWidget({
    super.key,
    this.onSettingsTap,
  });

  @override
  State<SidebarWidget> createState() => _SidebarWidgetState();
}

class _SidebarWidgetState extends State<SidebarWidget> {
  late DateTime _currentTime;
  late Timer _timer;
  // Get reference to the time format provider
  final TimeFormatProvider _timeFormatProvider = TimeFormatProvider();
  
  @override
  void initState() {
    super.initState();
    _currentTime = DateTime.now();
    
    // Listen for time format changes
    _timeFormatProvider.addListener(_onTimeFormatChanged);
    
    // Update time every minute
    _timer = Timer.periodic(const Duration(minutes: 1), (timer) {
      setState(() {
        _currentTime = DateTime.now();
      });
    });
  }
  
  @override
  void dispose() {
    _timer.cancel();
    _timeFormatProvider.removeListener(_onTimeFormatChanged);
    super.dispose();
  }
  
  // Update UI when time format changes
  void _onTimeFormatChanged() {
    setState(() {
      // Just trigger a rebuild
    });
  }

  @override
  Widget build(BuildContext context) {
    // Get theme colors
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    
    // Define colors from the theme
    final Color sidebarColor = isDarkMode ? const Color(0xFF2C2C2E) : const Color(0xFFE5E5EA);
    final Color stackedCardColor = isDarkMode ? const Color(0xFF636366) : const Color(0xFFB8B8BA);
    final Color textColor = theme.textTheme.bodyLarge?.color ?? (isDarkMode ? Colors.white : Colors.black);
    final Color secondaryTextColor = theme.textTheme.bodySmall?.color ?? (isDarkMode ? Colors.white70 : Colors.black54);
    
    const double iconSize = 37.4; // Increased by 10% from 34.0
    // Define sidebar rounding
    const BorderRadius sidebarBorderRadius = BorderRadius.all(Radius.circular(20.0));

    return Container(
      width: 90.0, // Narrower for better proportion without containers
      // Apply decoration for color and rounding
      decoration: BoxDecoration(
        color: sidebarColor,
        borderRadius: sidebarBorderRadius,
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final double availableHeight = constraints.maxHeight;
          
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 25.0, horizontal: 10.0),
            child: Column(
              children: [
                // Time widget instead of 5G
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _formatTime(_currentTime),
                      style: TextStyle(
                        color: textColor, 
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _formatDate(_currentTime),
                      style: TextStyle(
                        color: secondaryTextColor, 
                        fontSize: 10
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
                SizedBox(height: availableHeight * 0.05), // Proportional spacing
                
                // Phone app icon
                _buildAppIcon(
                  Icons.phone, // Fallback icon
                  "Phone",
                  Colors.green,
                  'phone', // Asset name
                  iconSize,
                ),
                SizedBox(height: availableHeight * 0.05), // Proportional spacing
                
                // Spotify app icon (replacing Messages)
                _buildAppIcon(
                  Icons.music_note, // Fallback icon
                  "Spotify",
                  Colors.green,
                  'spotify', // Asset name
                  iconSize,
                ),
                SizedBox(height: availableHeight * 0.05), // Proportional spacing
                
                // Maps app icon
                _buildAppIcon(
                  Icons.map, // Fallback icon
                  "Maps",
                  Colors.orange,
                  'maps', // Asset name
                  iconSize,
                ),
                
                const Spacer(), // Pushes the bottom icon to the bottom
                
                // Settings icon
                GestureDetector(
                  onTap: widget.onSettingsTap,
                  child: _buildAppIcon(
                    Icons.settings, // Fallback icon
                    "Settings",
                    Colors.white,
                    'settings', // Asset name
                    iconSize,
                  ),
                ),
                
                SizedBox(height: availableHeight * 0.02), // Small bottom padding
              ],
            ),
          );
        }
      ),
    );
  }

  // Simplified icon building method without container
  Widget _buildAppIcon(
    IconData fallbackIcon,
    String label,
    Color iconColor,
    String assetName,
    double size,
  ) {
    final theme = Theme.of(context);
    final textColor = theme.textTheme.bodyLarge?.color ?? Colors.white;
    
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Icon without background container
        SizedBox(
          width: size,
          height: size,
          child: AssetHelper.loadIconWithFallback(
            assetName: assetName,
            fallbackIcon: fallbackIcon,
            size: size,
            color: assetName.isEmpty ? iconColor : null,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: textColor,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
  
  String _formatTime(DateTime time) {
    // Use the provider to format time
    return _timeFormatProvider.formatTime(time);
  }
  
  String _formatDate(DateTime date) {
    // Format as abbreviated "Day, Month Day"
    final List<String> weekdays = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
    final List<String> months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 
                               'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    
    final weekday = weekdays[date.weekday % 7];
    final month = months[date.month - 1];
    final day = date.day;
    
    return '$weekday, $month $day';
  }
} 