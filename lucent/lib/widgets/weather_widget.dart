import 'package:flutter/material.dart';
import '../utils/asset_helper.dart';
import '../utils/weather_service.dart';
import 'dart:async';

class WeatherWidget extends StatefulWidget {
  final double? initialTemperature;
  final String? initialCondition;
  final String? initialLocation;
  final IconData? initialWeatherIcon;
  
  const WeatherWidget({
    super.key,
    this.initialTemperature,
    this.initialCondition,
    this.initialLocation,
    this.initialWeatherIcon,
  });

  @override
  State<WeatherWidget> createState() => _WeatherWidgetState();
}

class _WeatherWidgetState extends State<WeatherWidget> {
  double? _temperature;
  String? _condition;
  String? _location;
  IconData? _weatherIcon;
  List<Map<String, dynamic>> _forecast = [];
  bool _isLoading = true;
  bool _loadError = false;
  late Timer _timer;
  late DateTime _currentTime;

  @override
  void initState() {
    super.initState();
    // Set initial values from widget parameters
    _temperature = widget.initialTemperature ?? 72.0;
    _condition = widget.initialCondition ?? 'Partly Cloudy';
    _location = widget.initialLocation ?? 'Richardson, TX';
    _weatherIcon = widget.initialWeatherIcon ?? Icons.wb_cloudy;
    _currentTime = DateTime.now();
    
    // Create placeholder forecast based on current time
    _createPlaceholderForecast();
    
    // Fetch real weather data
    _fetchWeatherData();
    
    // Update current time every minute
    _timer = Timer.periodic(const Duration(minutes: 1), (timer) {
      setState(() {
        _currentTime = DateTime.now();
      });
    });
  }
  
  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }
  
  // Create placeholder forecast based on current time
  void _createPlaceholderForecast() {
    final now = DateTime.now();
    _forecast = [];
    
    // Add current hour as "Now"
    _forecast.add({
      'time': now,
      'temp': _temperature,
      'condition': _condition ?? 'partly cloudy',
      'icon': _weatherIcon ?? Icons.wb_cloudy,
      'isNow': true,
    });
    
    // Add next 4 hours
    for (int i = 1; i <= 4; i++) {
      final nextHour = DateTime(now.year, now.month, now.day, now.hour + i);
      final temp = (_temperature ?? 72.0) + (i * 1.5); // Fake increase per hour
      final condition = i > 2 ? 'clear' : 'partly cloudy'; // Fake weather change
      
      _forecast.add({
        'time': nextHour,
        'temp': temp,
        'condition': condition,
        'icon': _getWeatherIcon(condition),
        'isNow': false,
      });
    }
  }

  // Fetch weather data based on location
  Future<void> _fetchWeatherData() async {
    try {
      // Get current location
      final position = await WeatherService.getCurrentLocation();
      
      if (position != null) {
        // Get city name
        final cityName = await WeatherService.getCityName(
          position.latitude,
          position.longitude,
        );
        
        // Get current weather
        final weatherData = await WeatherService.getWeatherData(
          position.latitude,
          position.longitude,
        );
        
        // Get forecast
        final forecastData = await WeatherService.getWeatherForecast(
          position.latitude,
          position.longitude,
        );
        
        if (weatherData != null && forecastData != null) {
          // Process current weather
          final temp = weatherData['main']['temp'].toDouble();
          final weatherCondition = weatherData['weather'][0]['description'];
          final iconCode = weatherData['weather'][0]['icon'];
          final conditionString = WeatherService.getWeatherCondition(iconCode);
          
          // Process forecast data (next few hours)
          final List<dynamic> forecastList = forecastData['list'];
          final List<Map<String, dynamic>> processedForecast = [];
          
          // Current time
          final now = DateTime.now();
          
          // First create a "now" forecast with current weather
          processedForecast.add({
            'time': now,
            'temp': temp,
            'condition': conditionString,
            'icon': _getWeatherIcon(conditionString),
            'isNow': true,
          });
          
          // Add the next 4 forecasts based on API data
          int forecastsAdded = 0;
          
          // Sort forecasts by time
          forecastList.sort((a, b) {
            final timeA = DateTime.fromMillisecondsSinceEpoch(a['dt'] * 1000);
            final timeB = DateTime.fromMillisecondsSinceEpoch(b['dt'] * 1000);
            return timeA.compareTo(timeB);
          });
          
          for (int i = 0; i < forecastList.length && forecastsAdded < 4; i++) {
            final forecast = forecastList[i];
            final forecastTime = DateTime.fromMillisecondsSinceEpoch(forecast['dt'] * 1000);
            
            // Only include forecasts in the future
            if (forecastTime.isAfter(now)) {
              final forecastTemp = forecast['main']['temp'].toDouble();
              final forecastIconCode = forecast['weather'][0]['icon'];
              final forecastCondition = WeatherService.getWeatherCondition(forecastIconCode);
              
              processedForecast.add({
                'time': forecastTime,
                'temp': forecastTemp,
                'condition': forecastCondition,
                'icon': _getWeatherIcon(forecastCondition),
                'isNow': false,
              });
              
              forecastsAdded++;
            }
          }
          
          // If we don't have enough forecasts from the API, generate some
          if (processedForecast.length < 5) {
            int missingForecasts = 5 - processedForecast.length;
            
            // Get the last forecast time, or use current time if no forecasts
            DateTime lastTime = now;
            if (processedForecast.length > 1) {
              lastTime = processedForecast.last['time'];
            }
            
            // Add missing forecasts with increasing hours
            for (int i = 0; i < missingForecasts; i++) {
              // Add 1 hour to last forecast time
              final nextHour = DateTime(
                lastTime.year, 
                lastTime.month, 
                lastTime.day, 
                lastTime.hour + 1 + i
              );
              
              // Use last known temperature with slight increase
              final lastTemp = processedForecast.last['temp'];
              final nextTemp = lastTemp + 1.0;
              
              // Use same condition as last forecast
              final lastCondition = processedForecast.last['condition'];
              
              processedForecast.add({
                'time': nextHour,
                'temp': nextTemp,
                'condition': lastCondition,
                'icon': _getWeatherIcon(lastCondition),
                'isNow': false,
              });
            }
          }
          
          // Update state with real data
          if (mounted) {
            setState(() {
              _temperature = temp;
              _condition = weatherCondition;
              _location = cityName ?? _location;
              _weatherIcon = _getWeatherIcon(conditionString);
              _forecast = processedForecast;
              _isLoading = false;
              _currentTime = now;
            });
          }
        } else {
          // Handle error - use default values
          if (mounted) {
            setState(() {
              _isLoading = false;
              _loadError = true;
            });
          }
        }
      } else {
        // Handle location error - use default values
        if (mounted) {
          setState(() {
            _isLoading = false;
            _loadError = true;
          });
        }
      }
    } catch (e) {
      print("Error fetching weather: $e");
      // Handle error - use default values
      if (mounted) {
        setState(() {
          _isLoading = false;
          _loadError = true;
        });
      }
    }
  }
  
  // Helper method to get the appropriate weather icon
  IconData _getWeatherIcon(String condition) {
    switch (condition.toLowerCase()) {
      case 'clear':
        return Icons.wb_sunny;
      case 'partly cloudy':
        return Icons.wb_cloudy;
      case 'cloudy':
        return Icons.cloud;
      case 'rain':
        return Icons.water_drop;
      case 'thunderstorm':
        return Icons.thunderstorm;
      case 'snow':
        return Icons.ac_unit;
      default:
        return Icons.wb_cloudy;
    }
  }
  
  // Format forecast time for display
  String _formatForecastTime(DateTime time, bool isNow) {
    if (isNow) return 'Now';
    
    // Format hour with AM/PM
    final hour = time.hour % 12 == 0 ? 12 : time.hour % 12;
    final amPm = time.hour >= 12 ? 'PM' : 'AM';
    return '$hour $amPm';
  }

  @override
  Widget build(BuildContext context) {
    // Get theme colors
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    
    // Define theme-aware colors
    final primaryTextColor = theme.textTheme.bodyLarge?.color ?? Colors.white;
    final secondaryTextColor = theme.textTheme.bodySmall?.color ?? Colors.grey[400];
    final cardColor = isDarkMode ? const Color(0xFF2C2C2E) : const Color(0xFFFFFFFF);
    
    return Container(
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16.0),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          // Get available width and height
          final width = constraints.maxWidth;
          final height = constraints.maxHeight;
          
          // Size text based on available space
          final locationFontSize = height * 0.08; // Reduce from 0.095
          final tempFontSize = height * 0.18; // Reduce from 0.22
          final conditionFontSize = height * 0.07; // Reduce from 0.085
          
          // Calculate weather icon size based on height
          final weatherIconSize = height * 0.18; // Reduce from 0.2
          
          // Show either default state or loading state
          if (_isLoading && _forecast.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 40, height: 40,
                    child: CircularProgressIndicator(
                      color: primaryTextColor,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Loading weather...',
                    style: TextStyle(
                      color: secondaryTextColor,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            );
          }
          
          // Format temperature
          final tempDisplay = '${_temperature?.round() ?? 0}°';
          
          return Padding(
            padding: const EdgeInsets.fromLTRB(20.0, 16.0, 20.0, 12.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Location at the top
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        _location ?? 'Loading location...',
                        style: TextStyle(
                          color: primaryTextColor,
                          fontSize: locationFontSize,
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                
                // Weather icon with temperature and condition
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Weather icon
                    Padding(
                      padding: const EdgeInsets.only(right: 10.0),
                      child: AssetHelper.loadWeatherIcon(
                        condition: _condition?.toLowerCase() ?? 'unknown',
                        fallbackIcon: _weatherIcon ?? Icons.wb_cloudy,
                        size: weatherIconSize,
                        color: primaryTextColor,
                      ),
                    ),
                    
                    // Main temperature and condition
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          tempDisplay,
                          style: TextStyle(
                            color: primaryTextColor,
                            fontSize: tempFontSize,
                            fontWeight: FontWeight.w300,
                          ),
                        ),
                        Text(
                          _condition ?? 'Loading weather...',
                          style: TextStyle(
                            color: secondaryTextColor,
                            fontSize: conditionFontSize,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                
                // Hourly forecast row
                SizedBox(
                  height: height * 0.25, // Limit the height of the forecast row
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: _buildHourlyForecast(
                      height * 0.04, // Reduce font size for time
                      height * 0.045  // Reduce font size for temperature
                    ),
                  ),
                ),
              ],
            ),
          );
        }
      ),
    );
  }
  
  // Build forecast item with theme-aware colors
  Widget _buildForecastItem(String time, IconData icon, String temp, double iconSize, String condition) {
    // Get theme colors
    final theme = Theme.of(context);
    final primaryTextColor = theme.textTheme.bodyLarge?.color ?? Colors.white;
    final secondaryTextColor = theme.textTheme.bodySmall?.color ?? Colors.white70;
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            time,
            style: TextStyle(
              color: secondaryTextColor,
              fontSize: iconSize * 0.6, // Proportional to icon size
            ),
          ),
          const SizedBox(height: 4.0),
          AssetHelper.loadWeatherIcon(
            condition: condition,
            fallbackIcon: icon,
            size: iconSize,
            color: primaryTextColor,
          ),
          const SizedBox(height: 4.0),
          Text(
            temp,
            style: TextStyle(
              color: primaryTextColor,
              fontSize: iconSize * 0.7, // Proportional to icon size
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildHourlyForecast(double hourlyFontSize, double tempFontSize) {
    // Get theme colors
    final theme = Theme.of(context);
    final primaryTextColor = theme.textTheme.bodyLarge?.color ?? Colors.white;
    final secondaryTextColor = theme.textTheme.bodySmall?.color ?? Colors.grey[400];
    
    if (_forecast.isEmpty) {
      // Create default forecast if no data
      return List.generate(5, (index) {
        String time = index == 0 ? 'Now' : '${(DateTime.now().hour + index) % 24}:00';
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min, // Make smaller
          children: [
            // Time
            Text(
              time,
              style: TextStyle(
                color: secondaryTextColor,
                fontSize: hourlyFontSize,
              ),
            ),
            
            // Weather icon - smaller size and padding
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 4.0),
              child: AssetHelper.loadWeatherIcon(
                condition: 'cloudy',
                fallbackIcon: Icons.wb_cloudy,
                size: hourlyFontSize * 1.2, // Smaller icon
                color: primaryTextColor,
              ),
            ),
            
            // Temperature
            Text(
              '${(_temperature ?? 72.0 + index).round()}°',
              style: TextStyle(
                color: primaryTextColor,
                fontSize: tempFontSize,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        );
      });
    }
    
    return _forecast.map((forecast) {
      final time = _formatForecastTime(forecast['time'], forecast['isNow'] ?? false);
      final temp = '${forecast['temp'].round()}°';
      
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min, // Make smaller
        children: [
          // Time
          Text(
            time,
            style: TextStyle(
              color: secondaryTextColor,
              fontSize: hourlyFontSize,
            ),
          ),
          
          // Weather icon - smaller size and padding
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4.0),
            child: AssetHelper.loadWeatherIcon(
              condition: forecast['condition'],
              fallbackIcon: forecast['icon'],
              size: hourlyFontSize * 1.2, // Smaller icon
              color: primaryTextColor,
            ),
          ),
          
          // Temperature
          Text(
            temp,
            style: TextStyle(
              color: primaryTextColor,
              fontSize: tempFontSize,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      );
    }).toList();
  }
} 