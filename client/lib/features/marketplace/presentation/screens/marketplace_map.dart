import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../../../core/constants/app_colors.dart';
import '../../domain/listing_entity.dart';

class MarketplaceMap extends StatelessWidget {
  final List<ListingEntity> listings;

  const MarketplaceMap({
    super.key,
    required this.listings,
  });

  @override
  Widget build(BuildContext context) {
    return FlutterMap(
      options: const MapOptions(
        initialCenter: LatLng(-1.2921, 36.8219), // Nairobi
        initialZoom: 13.0,
      ),
      children: [
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'com.kejapin.client',
        ),
        MarkerLayer(
          markers: listings.map((listing) {
            return _buildPriceMarker(
              LatLng(listing.latitude, listing.longitude),
              "${(listing.priceAmount / 1000).toStringAsFixed(0)}k",
            );
          }).toList(),
        ),
      ],
    );
  }

  Marker _buildPriceMarker(LatLng point, String price) {
    return Marker(
      point: point,
      width: 80,
      height: 40,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.structuralBrown,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.2),
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Center(
          child: Text(
            price,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ),
      ),
    );
  }
}
