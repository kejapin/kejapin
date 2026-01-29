import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/widgets/custom_app_bar.dart';
import '../../data/models/search_result.dart';

class MapScreen extends StatelessWidget {
  final SearchResult? extra;

  const MapScreen({super.key, this.extra});

  @override
  Widget build(BuildContext context) {
    final lat = extra?.metadata['lat'] as double? ?? -1.2921;
    final lng = extra?.metadata['lng'] as double? ?? 36.8219;
    final center = LatLng(lat, lng);

    return Scaffold(
      appBar: const CustomAppBar(title: 'Location', showSearch: false),
      body: FlutterMap(
        options: MapOptions(
          initialCenter: center,
          initialZoom: 15.0,
        ),
        children: [
          TileLayer(
            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
            userAgentPackageName: 'com.kejapin.app',
          ),
          MarkerLayer(
            markers: [
              Marker(
                point: center,
                width: 80,
                height: 80,
                child: const Icon(Icons.location_on, color: Colors.red, size: 40),
              ),
            ],
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // Navigate to marketplace filtered by this location (mock behavior)
          context.push('/marketplace?query=Westlands'); // Example: using location name
        },
        label: const Text('View Listings'),
        icon: const Icon(Icons.list),
      ),
    );
  }
}
