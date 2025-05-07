import 'package:flutter/material.dart';
import 'dart:io';

/// A helper class for loading assets in the app.
/// This centralizes asset path handling and provides fallback options.
class AssetHelper {
  /// Load an icon from assets with a fallback Material icon
  static Widget loadIconWithFallback({
    required String assetName,
    required IconData fallbackIcon,
    double size = 24.0,
    Color? color,
  }) {
    if (assetName.isEmpty) {
      return Icon(fallbackIcon, color: color, size: size);
    }
    
    // Try to load the PNG image from icons directory
    try {
      return Image.asset(
        'assets/icons/$assetName.png', 
        width: size, 
        height: size, 
        color: color,
      );
    } catch (e) {
      // If loading fails, use fallback icon
      return Icon(
        fallbackIcon,
        color: color,
        size: size,
      );
    }
  }
  
  /// Method to load album art for the music player
  static Widget loadAlbumArt({
    required String artPath,
    double width = 60.0,
    double height = 60.0,
    Color? placeholderColor,
    IconData placeholderIcon = Icons.music_note,
  }) {
    try {
      // Try to load the album art image
      return ClipRRect(
        borderRadius: BorderRadius.circular(8.0),
        child: Image.asset(
          'assets/Music/$artPath.jpg',
          width: width,
          height: height,
          fit: BoxFit.cover,
        ),
      );
    } catch (_) {
      // Use placeholder if image loading fails
      return Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8.0),
          color: placeholderColor ?? Colors.grey[800],
        ),
        child: Icon(
          placeholderIcon,
          color: Colors.white54,
        ),
      );
    }
  }
  
  /// Method to load weather icons - using stock icons instead of assets
  static Widget loadWeatherIcon({
    required String condition,
    required IconData fallbackIcon,
    double size = 32.0,
    Color? color,
  }) {
    // Map weather condition to appropriate icon
    IconData iconData;
    switch (condition.toLowerCase()) {
      case 'sunny':
      case 'clear':
        iconData = Icons.wb_sunny;
        break;
      case 'partly cloudy':
        iconData = Icons.wb_cloudy;
        break;
      case 'cloudy':
        iconData = Icons.cloud;
        break;
      case 'rain':
      case 'rainy':
        iconData = Icons.water_drop;
        break;
      case 'thunderstorm':
        iconData = Icons.thunderstorm;
        break;
      case 'snow':
      case 'snowy':
        iconData = Icons.ac_unit;
        break;
      default:
        iconData = fallbackIcon;
    }
    
    return Icon(
      iconData,
      color: color,
      size: size,
    );
  }
} 