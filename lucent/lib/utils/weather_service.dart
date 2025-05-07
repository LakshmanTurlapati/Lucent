import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

class WeatherService {
  // OpenWeatherMap API - free tier
  static const String apiKey = "b8dfad74db0b3be3441095a9c1c9b1aa"; // Replace with your own API key
  static const String baseUrl = "https://api.openweathermap.org/data/2.5";

  // Get user's current location
  static Future<Position?> getCurrentLocation() async {
    // Check location permission
    bool serviceEnabled;
    LocationPermission permission;

    try {
      // Test if location services are enabled
      serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        // Location services are not enabled
        return null;
      }

      // Request permission
      permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          // Permissions are denied
          return null;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        // Permissions are denied forever
        return null;
      }

      // Get the current position
      return await Geolocator.getCurrentPosition();
    } catch (e) {
      print("Error getting location: $e");
      return null;
    }
  }

  // Get city name from coordinates
  static Future<String?> getCityName(double latitude, double longitude) async {
    final String url = "$baseUrl/weather?lat=$latitude&lon=$longitude&appid=$apiKey";
    
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['name'];
      }
      return null;
    } catch (e) {
      print("Error getting city name: $e");
      return null;
    }
  }

  // Get weather data for a specific location
  static Future<Map<String, dynamic>?> getWeatherData(double latitude, double longitude) async {
    final String url = "$baseUrl/weather?lat=$latitude&lon=$longitude&units=imperial&appid=$apiKey";
    
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
      return null;
    } catch (e) {
      print("Error getting weather data: $e");
      return null;
    }
  }

  // Get weather forecast for a specific location
  static Future<Map<String, dynamic>?> getWeatherForecast(double latitude, double longitude) async {
    final String url = "$baseUrl/forecast?lat=$latitude&lon=$longitude&units=imperial&appid=$apiKey";
    
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
      return null;
    } catch (e) {
      print("Error getting forecast data: $e");
      return null;
    }
  }

  // Helper function to get the appropriate weather icon
  static String getWeatherCondition(String? iconCode) {
    if (iconCode == null) return 'unknown';
    
    // Map OpenWeatherMap icon codes to our condition strings
    switch (iconCode) {
      case '01d': 
      case '01n': return 'clear';
      
      case '02d':
      case '02n': 
      case '03d':
      case '03n': return 'partly cloudy';
      
      case '04d':
      case '04n': return 'cloudy';
      
      case '09d':
      case '09n': 
      case '10d':
      case '10n': return 'rain';
      
      case '11d':
      case '11n': return 'thunderstorm';
      
      case '13d':
      case '13n': return 'snow';
      
      default: return 'unknown';
    }
  }
} 