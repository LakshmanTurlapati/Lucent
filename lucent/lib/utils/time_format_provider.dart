import 'package:flutter/material.dart';

// A provider class to manage time format settings across the app
class TimeFormatProvider extends ChangeNotifier {
  // Singleton instance
  static final TimeFormatProvider _instance = TimeFormatProvider._internal();
  
  // Factory constructor to return the singleton instance
  factory TimeFormatProvider() {
    return _instance;
  }
  
  // Private constructor
  TimeFormatProvider._internal();
  
  // True for 24-hour format, false for 12-hour format
  bool _use24HourFormat = false;
  
  // Getter for current format setting
  bool get use24HourFormat => _use24HourFormat;
  
  // Method to toggle time format
  void toggleTimeFormat() {
    _use24HourFormat = !_use24HourFormat;
    notifyListeners();
  }
  
  // Method to explicitly set time format
  void setTimeFormat(bool use24Hour) {
    if (_use24HourFormat != use24Hour) {
      _use24HourFormat = use24Hour;
      notifyListeners();
    }
  }
  
  // Format a DateTime according to current settings
  String formatTime(DateTime time) {
    if (_use24HourFormat) {
      // 24-hour format: HH:MM
      final hour = time.hour.toString().padLeft(2, '0');
      final minute = time.minute.toString().padLeft(2, '0');
      return '$hour:$minute';
    } else {
      // 12-hour format: h:MM AM/PM
      final hour = time.hour > 12 ? time.hour - 12 : (time.hour == 0 ? 12 : time.hour);
      final minute = time.minute.toString().padLeft(2, '0');
      final period = time.hour >= 12 ? 'PM' : 'AM';
      return '$hour:$minute $period';
    }
  }
} 