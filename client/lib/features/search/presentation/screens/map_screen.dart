import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:glassmorphism/glassmorphism.dart';
import 'package:geolocator/geolocator.dart';
import '../../../../core/widgets/custom_app_bar.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/services/navigation_service.dart';
import '../../../../core/services/commute_service.dart';
import '../../data/models/search_result.dart';

class MapScreen extends StatefulWidget {
  final SearchResult? extra;

  const MapScreen({super.key, this.extra});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final NavigationService _navService = NavigationService();
  final MapController _mapController = MapController();
  
  LatLng? _userLocation;
  List<LatLng> _routePoints = [];
  CommuteResult? _routeInfo;
  bool _isNavigating = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _initLocation();
  }

  Future<void> _initLocation() async {
    try {
      final position = await _navService.getCurrentLocation();
      if (mounted) {
        setState(() {
          _userLocation = LatLng(position.latitude, position.longitude);
        });
      }
    } catch (e) {
      print('Location error: $e');
    }
  }

  Future<void> _startNavigation() async {
    setState(() => _isLoading = true);
    try {
      final destinationLat = widget.extra?.metadata['lat'] as double? ?? -1.2921;
      final destinationLng = widget.extra?.metadata['lon'] as double? ?? 36.8219;
      final destination = LatLng(destinationLat, destinationLng);

      final result = await _navService.getRouteTo(destination);
      
      if (result.polyline != null) {
        final polylinePoints = PolylinePoints();
        final decodedPoints = polylinePoints.decodePolyline(result.polyline!);
        
        setState(() {
          _routePoints = decodedPoints
              .map((p) => LatLng(p.latitude, p.longitude))
              .toList();
          _routeInfo = result;
          _isNavigating = true;
        });

        // Fit map bounds to show entire route
        final points = [_userLocation!, destination];
        _mapController.fitCamera(
          CameraFit.bounds(
            bounds: LatLngBounds.fromPoints(points),
            padding: const EdgeInsets.all(50),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Navigation failed: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final destLat = widget.extra?.metadata['lat'] as double? ?? -1.2921;
    final destLng = widget.extra?.metadata['lon'] as double? ?? 36.8219;
    final destination = LatLng(destLat, destLng);
    final center = _userLocation ?? destination;

    return Scaffold(
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: center,
              initialZoom: 15.0,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.kejapin.app',
              ),
              if (_routePoints.isNotEmpty)
                PolylineLayer(
                  polylines: [
                    Polyline(
                      points: _routePoints,
                      color: AppColors.champagne,
                      strokeWidth: 5,
                      borderColor: AppColors.structuralBrown.withOpacity(0.5),
                      borderStrokeWidth: 2,
                    ),
                  ],
                ),
              MarkerLayer(
                markers: [
                  // Destination Marker
                  Marker(
                    point: destination,
                    width: 50,
                    height: 50,
                    child: const Icon(Icons.location_on, color: Colors.red, size: 40),
                  ),
                  // User Location Marker
                  if (_userLocation != null)
                    Marker(
                      point: _userLocation!,
                      width: 40,
                      height: 40,
                      child: Container(
                        decoration: BoxDecoration(
                          color: AppColors.champagne.withOpacity(0.2),
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Container(
                            width: 15,
                            height: 15,
                            decoration: const BoxDecoration(
                              color: AppColors.champagne,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.white,
                                  blurRadius: 10,
                                  spreadRadius: 2,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ],

          ),

          // Custom Back Button Overlay
          Positioned(
            top: MediaQuery.of(context).padding.top + 10,
            left: 20,
            child: GestureDetector(
                onTap: () => Navigator.pop(context),
                child: GlassmorphicContainer(
                    width: 50,
                    height: 50,
                    borderRadius: 25,
                    blur: 20,
                    alignment: Alignment.center,
                    border: 2,
                    linearGradient: LinearGradient(colors: [Colors.black.withOpacity(0.6), Colors.black.withOpacity(0.4)]),
                    borderGradient: LinearGradient(colors: [AppColors.champagne.withOpacity(0.5), Colors.transparent]),
                    child: const Icon(Icons.arrow_back, color: AppColors.champagne),
                ),
            ),
          ),
          
          // Navigation Info Card
          if (_isNavigating && _routeInfo != null)
            Positioned(
              top: kToolbarHeight + 40,
              left: 20,
              right: 20,
              child: GlassmorphicContainer(
                width: double.infinity,
                height: 100,
                borderRadius: 20,
                blur: 20,
                alignment: Alignment.center,
                border: 2,
                linearGradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColors.structuralBrown.withOpacity(0.8),
                    AppColors.structuralBrown.withOpacity(0.6),
                  ],
                ),
                borderGradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColors.champagne.withOpacity(0.5),
                    AppColors.champagne.withOpacity(0.2),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.champagne.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.navigation_rounded,
                          color: AppColors.champagne,
                          size: 32,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _routeInfo!.formattedDuration,
                              style: const TextStyle(
                                color: AppColors.champagne,
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              '${_routeInfo!.formattedDistance} • Regular traffic',
                              style: TextStyle(
                                color: AppColors.champagne.withOpacity(0.7),
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () => setState(() => _isNavigating = false),
                        icon: const Icon(Icons.close, color: AppColors.champagne),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            // My Location Button
            Positioned(
              bottom: 100,
              right: 16,
              child: FloatingActionButton(
                heroTag: 'map_screen_location',
                onPressed: () async {
                   try {
                      final pos = await _navService.getCurrentLocation();
                      setState(() => _userLocation = LatLng(pos.latitude, pos.longitude));
                      _mapController.move(LatLng(pos.latitude, pos.longitude), 15);
                   } catch (e) {
                      if (e.toString().contains('permanently denied')) Geolocator.openAppSettings();
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e')));
                   }
                },
                backgroundColor: Colors.white,
                child: const Icon(Icons.my_location, color: AppColors.structuralBrown),
              ),
            ),
        ],
      ),
      floatingActionButton: _isNavigating
          ? null
          : FloatingActionButton.extended(
              onPressed: _isLoading ? null : _startNavigation,
              backgroundColor: AppColors.structuralBrown,
              icon: _isLoading 
                ? const SizedBox(
                    width: 20, 
                    height: 20, 
                    child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.champagne)
                  )
                : const Icon(Icons.directions, color: AppColors.champagne),
              label: Text(
                _isLoading ? 'Calculating...' : 'Get Directions',
                style: const TextStyle(color: AppColors.champagne),
              ),
            ),
    );
  }
}
