import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../utils/time_format_provider.dart';
import '../utils/theme_provider.dart';
import '../theme/app_themes.dart';

class SettingsWidget extends StatefulWidget {
  final VoidCallback onClose;

  const SettingsWidget({
    super.key,
    required this.onClose,
  });

  @override
  State<SettingsWidget> createState() => _SettingsWidgetState();
}

class _SettingsWidgetState extends State<SettingsWidget> {
  // Currently selected settings page
  String _currentPage = 'General';

  // List of available settings pages
  final List<String> _settingsPages = [
    'General',
    'Display',
    'Battery',
    'Charging',
    'Driving',
    'Navigation',
    'Climate',
    'Safety',
    'Software',
    'Service',
  ];

  @override
  Widget build(BuildContext context) {
    // Get current theme
    final theme = Theme.of(context);
    final appThemeExtension = theme.extension<AppThemeExtension>();
    final isDarkMode = theme.brightness == Brightness.dark;
    
    return Container(
      decoration: BoxDecoration(
        color: theme.cardColor, // Use theme color instead of hardcoded
        borderRadius: BorderRadius.circular(16.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 10,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Row(
        children: [
          // Settings sidebar (black background)
          Container(
            width: 200,
            decoration: BoxDecoration(
              color: appThemeExtension?.settingsSidebarColor ?? 
                    (isDarkMode ? Colors.black : Colors.grey.shade200),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16.0),
                bottomLeft: Radius.circular(16.0),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Settings header
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      Icon(
                        Icons.settings,
                        color: theme.iconTheme.color,
                        size: 24,
                      ),
                      const SizedBox(width: 10),
                      Text(
                        'Settings',
                        style: TextStyle(
                          color: theme.textTheme.titleLarge?.color,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                Divider(color: theme.dividerColor, height: 1),
                
                // Settings menu items
                Expanded(
                  child: ListView.builder(
                    itemCount: _settingsPages.length,
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    itemBuilder: (context, index) {
                      final pageName = _settingsPages[index];
                      final isSelected = pageName == _currentPage;
                      
                      return Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () {
                            setState(() {
                              _currentPage = pageName;
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                            color: isSelected ? 
                                  (isDarkMode ? Colors.grey.shade900 : Colors.grey.shade300) : 
                                  Colors.transparent,
                            child: Row(
                              children: [
                                Icon(
                                  _getIconForPage(pageName),
                                  color: isSelected ? 
                                        theme.iconTheme.color : 
                                        theme.iconTheme.color?.withOpacity(0.7),
                                  size: 20,
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  pageName,
                                  style: TextStyle(
                                    color: isSelected ? 
                                          theme.textTheme.titleMedium?.color : 
                                          theme.textTheme.titleMedium?.color?.withOpacity(0.7),
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          
          // Content area
          Expanded(
            child: Stack(
              children: [
                // Page content
                Positioned.fill(
                  child: _buildPageContent(_currentPage),
                ),
                
                // Close button
                Positioned(
                  top: 16,
                  right: 16,
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(20),
                      onTap: widget.onClose,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: isDarkMode ? 
                                Colors.black.withOpacity(0.3) : 
                                Colors.grey.withOpacity(0.2),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.close,
                          color: theme.iconTheme.color,
                          size: 24,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  // Build content for the selected settings page
  Widget _buildPageContent(String pageName) {
    final theme = Theme.of(context);
    
    // Common placeholder widget with page-specific content
    return Container(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            pageName,
            style: TextStyle(
              color: theme.textTheme.titleLarge?.color,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Settings for ${pageName.toLowerCase()}',
            style: TextStyle(
              color: theme.textTheme.bodySmall?.color,
              fontSize: 14,
            ),
          ),
          Divider(color: theme.dividerColor, height: 32),
          
          Expanded(
            child: _getPageSpecificContent(pageName),
          ),
        ],
      ),
    );
  }
  
  // Get icons for sidebar menu items
  IconData _getIconForPage(String pageName) {
    switch (pageName) {
      case 'General':
        return Icons.settings_outlined;
      case 'Display':
        return Icons.brightness_6_outlined;
      case 'Battery':
        return Icons.battery_charging_full_outlined;
      case 'Charging':
        return Icons.electrical_services_outlined;
      case 'Driving':
        return Icons.drive_eta_outlined;
      case 'Navigation':
        return Icons.map_outlined;
      case 'Climate':
        return Icons.ac_unit_outlined;
      case 'Safety':
        return Icons.shield_outlined;
      case 'Software':
        return Icons.system_update_outlined;
      case 'Service':
        return Icons.home_repair_service_outlined;
      default:
        return Icons.settings_outlined;
    }
  }
  
  // Get page-specific placeholder content
  Widget _getPageSpecificContent(String pageName) {
    switch (pageName) {
      case 'General':
        return _buildGeneralSettings();
      case 'Display':
        return _buildDisplaySettings();
      case 'Battery':
        return _buildBatterySettings();
      case 'Charging':
        return _buildChargingSettings();
      default:
        return _buildDefaultContent(pageName);
    }
  }
  
  // Default content for pages without specific implementations
  Widget _buildDefaultContent(String pageName) {
    final theme = Theme.of(context);
    
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            _getIconForPage(pageName),
            color: theme.iconTheme.color?.withOpacity(0.5),
            size: 60,
          ),
          const SizedBox(height: 20),
          Text(
            '$pageName Settings',
            style: TextStyle(
              color: theme.textTheme.titleLarge?.color,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Placeholder for $pageName settings page',
            style: TextStyle(
              color: theme.textTheme.bodySmall?.color,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
  
  // Build General settings page placeholder
  Widget _buildGeneralSettings() {
    final theme = Theme.of(context);
    final timeFormatProvider = TimeFormatProvider();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: ListView(
            children: [
              _buildSettingItem('Language', 'English (US)', Icons.language),
              
              // Time format option using the same pattern as other settings
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 2.0),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () {
                      // Toggle time format when clicked
                      timeFormatProvider.toggleTimeFormat();
                      setState(() {}); // Refresh UI
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10.0),
                      child: Row(
                        children: [
                          Icon(Icons.access_time, color: theme.iconTheme.color?.withOpacity(0.7), size: 24),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Time Format',
                                  style: TextStyle(
                                    color: theme.textTheme.titleMedium?.color,
                                    fontSize: 15,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  timeFormatProvider.use24HourFormat ? '24-hour' : '12-hour',
                                  style: TextStyle(
                                    color: theme.textTheme.bodySmall?.color,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Icon(Icons.chevron_right, color: theme.iconTheme.color?.withOpacity(0.5), size: 20),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              
              _buildSettingItem('Units', 'Imperial', Icons.straighten),
              _buildSettingItem('Owner Manual', 'View manual', Icons.menu_book),
              _buildSettingItem('About', 'Version 2023.36.1', Icons.info_outline),
            ],
          ),
        ),
        
        // Footer - removed divider and made smaller
        Padding(
          padding: const EdgeInsets.only(top: 12.0, bottom: 6.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Divider removed
              Text(
                'LucentOS V1.6',
                style: TextStyle(
                  color: theme.textTheme.bodySmall?.color,
                  fontSize: 12, // Reduced from 14
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 2), // Reduced from 4
              RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  style: TextStyle(
                    color: theme.textTheme.bodySmall?.color?.withOpacity(0.8),
                    fontSize: 9, // Reduced from 10
                    fontStyle: FontStyle.italic,
                    fontWeight: FontWeight.w300,
                  ),
                  children: const [
                    TextSpan(text: 'Designed by '),
                    TextSpan(
                      text: 'Sysha Sharma',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    TextSpan(text: ', Engineered by '),
                    TextSpan(
                      text: 'Venkat L. Turlapati',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
  
  // Build Display settings page placeholder with theme option
  Widget _buildDisplaySettings() {
    final theme = Theme.of(context);
    final themeProvider = Provider.of<ThemeProvider>(context);
    final bool isDarkMode = themeProvider.isDarkMode;
    
    return ListView(
      children: [
        _buildSettingItem('Brightness', 'Auto', Icons.brightness_auto),
        _buildSettingItem('Night Mode', 'Auto', Icons.nightlight_round),
        
        // Theme setting - interactive
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 2.0),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                // Toggle theme
                themeProvider.toggleTheme();
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 10.0),
                child: Row(
                  children: [
                    Icon(
                      isDarkMode ? Icons.dark_mode : Icons.light_mode,
                      color: theme.iconTheme.color?.withOpacity(0.7),
                      size: 24
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Theme',
                            style: TextStyle(
                              color: theme.textTheme.titleMedium?.color,
                              fontSize: 15,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            isDarkMode ? 'Dark' : 'Light',
                            style: TextStyle(
                              color: theme.textTheme.bodySmall?.color,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Switch(
                      value: !isDarkMode, // Switch is ON for light mode
                      onChanged: (_) {
                        themeProvider.toggleTheme();
                      },
                      activeColor: theme.colorScheme.primary,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        
        _buildSettingItem('Screen Timeout', '30 seconds', Icons.timer),
      ],
    );
  }
  
  // Build Battery settings page placeholder
  Widget _buildBatterySettings() {
    final theme = Theme.of(context);
    
    return ListView(
      children: [
        _buildSettingItem('Battery Range Display', 'Percentage', Icons.battery_full),
        _buildSettingItem('Battery Saver Mode', 'On', Icons.eco),
        _buildSettingItem('Battery Health', 'Good (98%)', Icons.monitor_heart_outlined),
        _buildSettingItem('Low Battery Alert', '20%', Icons.warning_amber_outlined),
      ],
    );
  }
  
  // Build Charging settings page placeholder
  Widget _buildChargingSettings() {
    final theme = Theme.of(context);
    
    return ListView(
      children: [
        _buildSettingItem('Charging Limit', '90%', Icons.battery_charging_full),
        _buildSettingItem('Scheduled Charging', 'Off', Icons.schedule),
        _buildSettingItem('Fast Charging', 'On', Icons.flash_on),
        _buildSettingItem('Charging Stations', 'Show nearby', Icons.electrical_services),
      ],
    );
  }
  
  // Helper to build a settings item
  Widget _buildSettingItem(String title, String value, IconData icon) {
    final theme = Theme.of(context);
    
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            // Item click handler could be added here
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 10.0),
            child: Row(
              children: [
                Icon(icon, color: theme.iconTheme.color?.withOpacity(0.7), size: 24),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          color: theme.textTheme.titleMedium?.color,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        value,
                        style: TextStyle(
                          color: theme.textTheme.bodySmall?.color,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.chevron_right, color: theme.iconTheme.color?.withOpacity(0.5), size: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
} 