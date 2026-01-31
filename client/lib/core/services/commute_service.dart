import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';

class CommuteResult {
  final double durationSeconds;
  final double distanceMeters;
  final String? polyline;

  CommuteResult({
    required this.durationSeconds,
    required this.distanceMeters,
    this.polyline,
  });

  String get formattedDuration {
    final minutes = (durationSeconds / 60).round();
    if (minutes < 60) return '$minutes min';
    final hours = minutes ~/ 60;
    final remainingMinutes = minutes % 60;
    return '${hours}h ${remainingMinutes}m';
  }

  String get formattedDistance {
    final km = distanceMeters / 1000;
    return '${km.toStringAsFixed(1)} km';
  }
}

class CommuteService {
  final String baseUrl;

  CommuteService({this.baseUrl = 'https://router.project-osrm.org'});

  Future<CommuteResult> calculateCommute({
    required LatLng origin,
    required LatLng destination,
    String mode = 'driving',
  }) async {
    // OSRM Public API Profiles: driving, walking, cycling
    // Our internal values: DRIVE, WALK, CYCLE, PUBLIC_TRANSPORT
    String osrmProfile = 'driving';
    if (mode == 'WALK') osrmProfile = 'walking';
    if (mode == 'CYCLE') osrmProfile = 'cycling';
    // Note: OSRM public doesn't support 'public_transport' easily without a complex engine

    final url = '$baseUrl/route/v1/$osrmProfile/${origin.longitude},${origin.latitude};${destination.longitude},${destination.latitude}?overview=full&geometries=polyline';

    try {
      final response = await http.get(Uri.parse(url));
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['code'] == 'Ok' && data['routes'] != null && (data['routes'] as List).isNotEmpty) {
          final route = data['routes'][0];
          return CommuteResult(
            durationSeconds: (route['duration'] as num).toDouble(),
            distanceMeters: (route['distance'] as num).toDouble(),
            polyline: route['geometry'] as String?,
          );
        }
      }
      throw Exception('Failed to calculate commute: ${response.body}');
    } catch (e) {
      print('Commute calculation error: $e');
      rethrow;
    }
  }
}
