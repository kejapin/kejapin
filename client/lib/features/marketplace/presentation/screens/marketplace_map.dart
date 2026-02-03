import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/services/efficiency_service.dart';
import '../../domain/listing_entity.dart';
import 'package:client/l10n/app_localizations.dart';

class MarketplaceMap extends StatefulWidget {
  final List<ListingEntity> listings;

  const MarketplaceMap({
    super.key,
    required this.listings,
  });

  @override
  State<MarketplaceMap> createState() => _MarketplaceMapState();
}

class _MarketplaceMapState extends State<MarketplaceMap> {
  final MapController _mapController = MapController();
  final _efficiencyService = EfficiencyService();
  double _currentZoom = 13.0;

  @override
  Widget build(BuildContext context) {
    return FlutterMap(
      mapController: _mapController,
      options: MapOptions(
        initialCenter: const LatLng(-1.2921, 36.8219), // Nairobi
        initialZoom: 13.0,
        onPositionChanged: (position, hasGesture) {
          if (position.zoom != _currentZoom) {
            setState(() {
              _currentZoom = position.zoom ?? 13.0;
            });
          }
        },
      ),
      children: [
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'com.kejapin.client',
        ),
        MarkerLayer(
          markers: widget.listings.map((listing) {
            return _buildDynamicMarker(listing);
          }).toList(),
        ),
      ],
    );
  }

  Marker _buildDynamicMarker(ListingEntity listing) {
    final point = LatLng(listing.latitude, listing.longitude);
    final priceStr = "${(listing.priceAmount / 1000).toStringAsFixed(0)}k";

    const double highZoomThreshold = 15.5;
    const double mediumZoomThreshold = 12.0;

    Widget markerWidget;

    if (_currentZoom >= highZoomThreshold) {
      final efficiency = _efficiencyService.calculateScore(listing);
      markerWidget = _DetailedMarker(
        listing: listing, 
        price: priceStr,
        score: efficiency.totalScore,
      );
    } else if (_currentZoom >= mediumZoomThreshold) {
      markerWidget = _PriceBubbleMarker(price: priceStr);
    } else {
      markerWidget = _DotMarker();
    }

    return Marker(
      point: point,
      width: _currentZoom >= highZoomThreshold ? 180 : 80,
      height: _currentZoom >= highZoomThreshold ? 90 : 40,
      child: GestureDetector(
        onTap: () => context.push('/marketplace/listing/${listing.id}'),
        child: FadeIn(
          duration: const Duration(milliseconds: 300),
          child: markerWidget,
        ),
      ),
    );
  }
}

class _DetailedMarker extends StatelessWidget {
  final ListingEntity listing;
  final String price;
  final double score;

  const _DetailedMarker({required this.listing, required this.price, required this.score});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.horizontal(left: Radius.circular(12)),
            child: SizedBox(
              width: 60,
              height: 90,
              child: Image.network(
                listing.photos.first,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(color: Colors.grey),
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        price,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: AppColors.structuralBrown,
                        ),
                      ),
                      _SmallEfficiencyCircle(score: score),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _localizePropertyType(context, listing.propertyType),
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      const Icon(Icons.star, size: 10, color: AppColors.mutedGold),
                      const SizedBox(width: 2),
                      Text(
                        "4.8", 
                        style: TextStyle(fontSize: 10, color: Colors.grey[800]),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _localizePropertyType(BuildContext context, String type) {
    final l10n = AppLocalizations.of(context)!;
    switch (type) {
      case 'BEDSITTER': return l10n.bedsitter;
      case '1BHK': return l10n.oneBhk;
      case '2BHK': return l10n.twoBhk;
      case 'SQ': return l10n.sq;
      case 'BUNGALOW': return l10n.bungalow;
      default: return type;
    }
  }
}

class _SmallEfficiencyCircle extends StatelessWidget {
  final double score;

  const _SmallEfficiencyCircle({required this.score});

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(
            value: score,
            strokeWidth: 3,
            backgroundColor: Colors.grey[200],
            valueColor: AlwaysStoppedAnimation<Color>(
                score > 0.8 ? AppColors.sageGreen : AppColors.mutedGold
            ),
          ),
        ),
        Text(
          "${(score * 100).toInt()}",
          style: const TextStyle(fontSize: 8, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}

class _PriceBubbleMarker extends StatelessWidget {
  final String price;

  const _PriceBubbleMarker({required this.price});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.structuralBrown,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
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
    );
  }
}

class _DotMarker extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 12,
      height: 12,
      decoration: BoxDecoration(
        color: AppColors.mutedGold,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 4,
          ),
        ],
      ),
    );
  }
}
