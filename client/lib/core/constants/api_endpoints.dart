import 'package:flutter/foundation.dart' show kIsWeb;

class ApiEndpoints {
  static String get baseUrl {
    // Live Server on Render
    return 'https://kejapin.onrender.com/api';
  }

  static String get login => '$baseUrl/auth/login';
  static String get register => '$baseUrl/auth/register';
  static String get messages => '$baseUrl/messaging/messages';
  static String get notifications => '$baseUrl/messaging/notifications';
  
  // Geo & Life Pins
  static String get locationSearch => '$baseUrl/geo/search';
  static String get nearbyAmenities => '$baseUrl/geo/nearby';
  static String get lifePins => '$baseUrl/lifepins';
  static String get verificationApply => '$baseUrl/verification/apply';
}
