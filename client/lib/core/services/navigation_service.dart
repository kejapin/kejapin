import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'commute_service.dart';

class NavigationService {
  final CommuteService _commuteService = CommuteService();

  /// Gets the current location of the user.
  /// Handles permission requests.
  Future<Position> getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location service is not enabled');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }
    
    if (permission == LocationPermission.deniedForever) {
      return Future.error('Location permissions are permanently denied');
    } 

    return await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        timeLimit: Duration(seconds: 10),
      ),
    );
  }

  /// Calculates a route from the current location to the destination.
  Future<CommuteResult> getRouteTo(LatLng destination, {String mode = 'driving'}) async {
    final position = await getCurrentLocation();
    final origin = LatLng(position.latitude, position.longitude);
    
    return await _commuteService.calculateCommute(
      origin: origin,
      destination: destination,
      mode: mode,
    );
  }

  /// Streams the user's location.
  Stream<Position> getLocationStream() {
    return Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10,
      ),
    );
  }
}
