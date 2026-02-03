import 'package:http/http.dart' as http;
import 'dart:convert';
import '../constants/api_endpoints.dart';
import 'package:latlong2/latlong.dart';

class NearbyAmenity {
  final String id;
  final String type; // 'hospital', 'school', 'restaurant', 'parking', etc.
  final String name;
  final double latitude;
  final double longitude;
  final double distance; // in meters

  NearbyAmenity({
    required this.id,
    required this.type,
    required this.name,
    required this.latitude,
    required this.longitude,
    required this.distance,
  });

  factory NearbyAmenity.fromJson(Map<String, dynamic> json) {
    return NearbyAmenity(
      id: json['id'] ?? '',
      type: json['type'] ?? '',
      name: json['name'] ?? '',
      latitude: (json['latitude'] ?? 0.0).toDouble(),
      longitude: (json['longitude'] ?? 0.0).toDouble(),
      distance: (json['distance'] ?? 0.0).toDouble(),
    );
  }

  LatLng get position => LatLng(latitude, longitude);
}

class AmenityCategory {
  static const healthcare = 'healthcare';
  static const education = 'education';
  static const shopping = 'shopping';
  static const parking = 'parking';
  static const restaurant = 'restaurant';
  static const bank = 'bank';
  static const public_transport = 'public_transport';
  static const gym = 'gym';
  static const entertainment = 'entertainment';
  static const security = 'security';
}

class GeoService {
  static Future<Map<String, NearbyAmenity>> getNearbyAmenities({
    required double latitude,
    required double longitude,
    double radiusMeters = 1500, // 1.5km radius
  }) async {
    try {
      final uri = Uri.parse(ApiEndpoints.nearbyAmenities).replace(
        queryParameters: {
          'lat': latitude.toString(),
          'lng': longitude.toString(),
          'radius': radiusMeters.toString(),
        },
      );

      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        // Expecting response like:
        // {
        //   "healthcare": { "id": "...", "name": "...", "lat": ..., "lng": ..., "distance": ... },
        //   "education": { ... },
        //   ...
        // }
        
        Map<String, NearbyAmenity> amenities = {};
        
        if (data is Map) {
          data.forEach((key, value) {
            if (value != null && value is Map<String, dynamic>) {
              amenities[key] = NearbyAmenity.fromJson({
                ...value,
                'type': key,
              });
            }
          });
        }
        
        return amenities;
      } else {
        // Return mock data for development if API fails
        return _getMockNearbyAmenities(latitude, longitude);
      }
    } catch (e) {
      // Return mock data on error
      return _getMockNearbyAmenities(latitude, longitude);
    }
  }

  // Mock data generator for development/fallback
  static Map<String, NearbyAmenity> _getMockNearbyAmenities(double baseLat, double baseLng) {
    return {
      AmenityCategory.healthcare: NearbyAmenity(
        id: 'mock_hospital',
        type: AmenityCategory.healthcare,
        name: 'Nearby Hospital',
        latitude: baseLat + 0.005,
        longitude: baseLng + 0.003,
        distance: 550,
      ),
      AmenityCategory.education: NearbyAmenity(
        id: 'mock_school',
        type: AmenityCategory.education,
        name: 'Nearby School',
        latitude: baseLat - 0.004,
        longitude: baseLng - 0.005,
        distance: 620,
      ),
      AmenityCategory.shopping: NearbyAmenity(
        id: 'mock_shop',
        type: AmenityCategory.shopping,
        name: 'Supermarket',
        latitude: baseLat + 0.007,
        longitude: baseLng - 0.002,
        distance: 450,
      ),
      AmenityCategory.parking: NearbyAmenity(
        id: 'mock_parking',
        type: AmenityCategory.parking,
        name: 'Parking',
        latitude: baseLat - 0.006,
        longitude: baseLng + 0.008,
        distance: 800,
      ),
      AmenityCategory.restaurant: NearbyAmenity(
        id: 'mock_restaurant',
        type: AmenityCategory.restaurant,
        name: 'Restaurant',
        latitude: baseLat + 0.003,
        longitude: baseLng - 0.009,
        distance: 340,
      ),
      AmenityCategory.public_transport: NearbyAmenity(
        id: 'mock_transport',
        type: AmenityCategory.public_transport,
        name: 'Bus Stop',
        latitude: baseLat - 0.003,
        longitude: baseLng + 0.004,
        distance: 280,
      ),
      AmenityCategory.gym: NearbyAmenity(
        id: 'mock_gym',
        type: AmenityCategory.gym,
        name: 'Fitness Center',
        latitude: baseLat + 0.009,
        longitude: baseLng + 0.006,
        distance: 950,
      ),
      AmenityCategory.bank: NearbyAmenity(
        id: 'mock_bank',
        type: AmenityCategory.bank,
        name: 'Bank',
        latitude: baseLat - 0.008,
        longitude: baseLng - 0.004,
        distance: 720,
      ),
    };
  }
}
