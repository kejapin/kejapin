import 'dart:math';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flip_card/flip_card.dart';
import 'package:shimmer/shimmer.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:animate_do/animate_do.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/services/efficiency_service.dart';
import '../../../../core/widgets/glass_container.dart';
import '../../domain/listing_entity.dart';
import '../../data/listings_repository.dart';
import 'package:client/features/messages/data/notifications_repository.dart';
import '../../../../core/services/notification_service.dart';

class ListingCard extends StatefulWidget {
  final ListingEntity listing;
  final List<ListingEntity>? marketContext;

  const ListingCard({
    super.key,
    required this.listing,
    this.marketContext,
  });

  @override
  State<ListingCard> createState() => _ListingCardState();
}

class _ListingCardState extends State<ListingCard> {
  final GlobalKey<FlipCardState> cardKey = GlobalKey<FlipCardState>();
  final _repository = ListingsRepository();
  final _notificationsRepo = NotificationsRepository();
  String _backViewMode = 'stats'; // 'stats' or 'map'
  Position? _currentPosition;
  bool _showLegend = false;
  bool _isSaved = false;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _determinePosition();
    _checkSavedStatus();
  }

  Future<void> _checkSavedStatus() async {
    try {
      final isSaved = await _repository.isListingSaved(widget.listing.id);
      if (mounted) {
        setState(() => _isSaved = isSaved);
      }
    } catch (e) {
      debugPrint("Error checking saved status: $e");
    }
  }

  Future<void> _toggleSave() async {
    if (_isSaving) return;
    
    setState(() => _isSaving = true);
    
    try {
      await _repository.toggleSaveListing(widget.listing.id, _isSaved);
      if (mounted) {
        setState(() {
          _isSaved = !_isSaved;
          _isSaving = false;
        });
        
        if (_isSaved) {
          _notificationsRepo.createNotification(
            title: 'Property Pinned! 📍',
            message: 'You pinned "${widget.listing.title}" to your life-path.',
            type: 'FAVORITE',
            route: '/saved',
          );
          NotificationService().showNotification(
            title: 'Listing Saved 📍',
            body: 'You saved "${widget.listing.title}"',
          );
        } else {
          NotificationService().showNotification(
            title: 'Listing Removed 🗑️',
            body: 'You removed "${widget.listing.title}" from your saved list.',
          );
          _notificationsRepo.createNotification(
            title: 'Property Removed 🗑️',
            message: 'You removed "${widget.listing.title}" from your life-path.',
            type: 'SYSTEM',
          );
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_isSaved ? 'Listing saved!' : 'Listing removed.'),
            duration: const Duration(seconds: 1),
            behavior: SnackBarBehavior.floating,
            backgroundColor: AppColors.structuralBrown,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSaving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    }
  }

  Future<void> _determinePosition() async {
    try {
      bool serviceEnabled;
      LocationPermission permission;

      serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) return;

      permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) return;
      }
      
      if (permission == LocationPermission.deniedForever) return;

      final position = await Geolocator.getCurrentPosition();
      if (mounted) {
        setState(() {
          _currentPosition = position;
        });
      }
    } catch (e) {
      debugPrint("Error getting location: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final efficiency = EfficiencyService().calculateScore(
      widget.listing,
      marketContext: widget.marketContext,
    );
    
    return SizedBox(
      height: 400, 
      child: FlipCard(
        key: cardKey,
        flipOnTouch: false,
        direction: FlipDirection.HORIZONTAL,
        side: CardSide.FRONT,
        front: GestureDetector(
          onTap: () {
            context.push(
              '/marketplace/listing/${widget.listing.id}', 
              extra: {'listing': widget.listing, 'initialView': 'image'}
            );
          },
          child: _buildFrontSide(efficiency),
        ),
        back: GestureDetector(
          onTap: () {
            context.push(
              '/marketplace/listing/${widget.listing.id}', 
              extra: {'listing': widget.listing, 'initialView': 'image'}
            );
          },
          child: _buildBackSide(efficiency),
        ),
      ),
    );
  }

  Widget _buildFrontSide(EfficiencyScore efficiency) {
    return GlassContainer(
        borderRadius: BorderRadius.circular(16),
        blur: 10,
        opacity: 0.95,
        color: Colors.white,
        padding: EdgeInsets.zero,
        child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image Section
          Expanded(
            flex: 3,
            child: Stack(
              fit: StackFit.expand,
              children: [
                widget.listing.photos.isNotEmpty
                    ? CachedNetworkImage(
                        imageUrl: widget.listing.photos.first,
                        fit: BoxFit.cover,
                        fadeInDuration: const Duration(milliseconds: 300),
                        placeholder: (context, url) => _ShimmerPlaceholder(),
                        errorWidget: (context, url, error) => Container(
                          color: Colors.grey[200],
                          child: const Icon(Icons.broken_image, color: Colors.grey),
                        ),
                      )
                    : Container(color: Colors.grey[200]),
                
                // Favorite Button
                Positioned(
                  top: 16,
                  left: 16,
                  child: GestureDetector(
                    onTap: _toggleSave,
                    child: GlassContainer(
                      color: Colors.white,
                      opacity: 0.8,
                      blur: 10,
                      borderRadius: BorderRadius.circular(30),
                      padding: const EdgeInsets.all(8),
                      child: _isSaving 
                        ? const SizedBox(
                            width: 20, 
                            height: 20, 
                            child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.structuralBrown)
                          )
                        : Icon(
                            _isSaved ? Icons.favorite : Icons.favorite_border,
                            color: _isSaved ? AppColors.brickRed : AppColors.structuralBrown,
                            size: 20,
                          ),
                    ),
                  ),
                ),

                // Efficiency Badge
                Positioned(
                  bottom: 12,
                  left: 12,
                  child: GlassContainer(
                    color: AppColors.structuralBrown,
                    opacity: 0.8,
                    blur: 10,
                    borderRadius: BorderRadius.circular(12),
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    child: Row(
                      children: [
                        CircularScoreIndicator(score: efficiency.totalScore / 100, size: 24),
                        const SizedBox(width: 8),
                        Text(
                          '${efficiency.totalScore.toInt()}',
                          style: GoogleFonts.montserrat(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Market Percentile Badge
                Positioned(
                  bottom: 12,
                  right: 12,
                  child: GlassContainer(
                    color: AppColors.sageGreen,
                    opacity: 0.8,
                    blur: 10,
                    borderRadius: BorderRadius.circular(12),
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    child: Text(
                      'TOP ${max(1, ((1 - efficiency.percentileComparedToMarket) * 100).toInt())}%',
                      style: GoogleFonts.montserrat(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),

                // Top Actions (Stats & Map)
                Positioned(
                  top: 16,
                  right: 16,
                  child: Row(
                    children: [
                      _buildMiniIconButton(
                        icon: Icons.bar_chart_rounded,
                        label: 'STATS',
                        onTap: () {
                          setState(() => _backViewMode = 'stats');
                          cardKey.currentState?.toggleCard();
                        },
                      ),
                      const SizedBox(width: 8),
                      _buildMiniIconButton(
                        icon: Icons.map_outlined,
                        label: 'MAP',
                        onTap: () {
                          setState(() => _backViewMode = 'map');
                          cardKey.currentState?.toggleCard();
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          // Content Section
          Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Flexible(
                            child: Text(
                              widget.listing.title,
                              style: GoogleFonts.montserrat(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: AppColors.structuralBrown,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                'KES ${widget.listing.priceAmount.toInt()}',
                                style: GoogleFonts.montserrat(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.sageGreen,
                                ),
                              ),
                              Text(
                                widget.listing.isForRent ? '/ ${widget.listing.rentPeriod.toLowerCase()}' : 'Full Price',
                                style: GoogleFonts.lato(fontSize: 10, color: Colors.grey),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        widget.listing.locationName,
                        style: GoogleFonts.lato(
                          fontSize: 13,
                          color: Colors.grey[600],
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                  
                  // Animated Efficiency Pulse (Fills the marked space)
                  _buildEfficiencyPulse(efficiency),
                  
                  // Amenity Icons Row & Ratings
                  Row(
                    children: [
                      _AmenityIcon(icon: Icons.star, label: '${widget.listing.rating}', color: AppColors.mutedGold),
                      const SizedBox(width: 12),
                      _AmenityIcon(icon: Icons.bed, label: '${widget.listing.bedrooms}'),
                      const SizedBox(width: 12),
                      if (widget.listing.amenities.any((a) => a.toLowerCase().contains('wifi'))) ...[
                        const _AmenityIcon(icon: Icons.wifi, label: ''),
                        const SizedBox(width: 8),
                      ],
                      if (widget.listing.amenities.any((a) => a.toLowerCase().contains('cctv') || a.toLowerCase().contains('security'))) ...[
                        const _AmenityIcon(icon: Icons.security, label: ''),
                        const SizedBox(width: 8),
                      ],
                      if (widget.listing.sqft != null)
                        _AmenityIcon(icon: Icons.square_foot, label: '${widget.listing.sqft}ft²'),
                      
                      const Spacer(),
                      ElevatedButton(
                        onPressed: () => context.push(
                          '/marketplace/listing/${widget.listing.id}', 
                          extra: {'listing': widget.listing, 'initialView': 'image'}
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.structuralBrown,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          elevation: 0,
                        ),
                        child: const Text('View', style: TextStyle(color: Colors.white)),
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

  Widget _buildEfficiencyPulse(EfficiencyScore efficiency) {
    return FadeIn(
      delay: const Duration(milliseconds: 400),
      child: Container(
        height: 40,
        decoration: BoxDecoration(
          color: AppColors.structuralBrown.withOpacity(0.03),
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Row(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'SPATIAL PULSE',
                  style: GoogleFonts.montserrat(
                    fontSize: 8,
                    fontWeight: FontWeight.w900,
                    color: AppColors.structuralBrown.withOpacity(0.5),
                    letterSpacing: 1.5,
                  ),
                ),
                Text(
                  efficiency.efficiencyLabel.toUpperCase(),
                  style: GoogleFonts.montserrat(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: AppColors.sageGreen,
                  ),
                ),
              ],
            ),
            const Spacer(),
            // The Pulse Bars
            ...efficiency.categories.values.toList().asMap().entries.map((entry) {
              final index = entry.key;
              final val = entry.value;
              return _PulseBar(
                index: index,
                value: val,
                color: _getColorForCategory('', val).withOpacity(0.8),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildMiniIconButton({required IconData icon, required String label, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: GlassContainer(
        color: Colors.black,
        opacity: 0.4,
        blur: 10,
        borderRadius: BorderRadius.circular(30),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        child: Row(
          children: [
            Icon(icon, color: Colors.white, size: 14),
            const SizedBox(width: 4),
            Text(
              label,
              style: GoogleFonts.montserrat(
                fontSize: 9,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBackSide(EfficiencyScore efficiency) {
    return GlassContainer(
        borderRadius: BorderRadius.circular(16),
        blur: 10,
        opacity: 0.95,
        color: const Color(0xFFFDFBF7),
        borderColor: AppColors.structuralBrown,
        padding: _backViewMode == 'map' ? EdgeInsets.zero : const EdgeInsets.all(16),
        child: _backViewMode == 'stats' 
          ? _buildStatsView(efficiency)
          : _buildMapView(efficiency),
    );
  }

  Widget _buildStatsView(EfficiencyScore efficiency) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  efficiency.efficiencyLabel.toUpperCase(),
                  style: GoogleFonts.montserrat(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.structuralBrown,
                  ),
                ),
                Text(
                  '10-DIMENSIONAL ANALYSIS',
                  style: GoogleFonts.lato(fontSize: 10, letterSpacing: 1.2, color: Colors.grey),
                ),
              ],
            ),
            GestureDetector(
              onTap: () => cardKey.currentState?.toggleCard(),
              child: GlassContainer(
                padding: const EdgeInsets.all(4),
                borderRadius: BorderRadius.circular(20),
                color: AppColors.structuralBrown.withOpacity(0.1),
                child: const Icon(Icons.close, color: AppColors.structuralBrown, size: 20),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        
        // Stats Grid (10 items) - Optimized to fill space
        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: efficiency.categories.entries.map((entry) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: Row(
                  children: [
                    Icon(
                      _getIconForCategory(entry.key),
                      size: 14,
                      color: AppColors.structuralBrown.withOpacity(0.7),
                    ),
                    const SizedBox(width: 8),
                    SizedBox(
                      width: 95,
                      child: Text(
                        entry.key,
                        style: GoogleFonts.lato(fontSize: 11, fontWeight: FontWeight.bold),
                      ),
                    ),
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: entry.value,
                          backgroundColor: AppColors.structuralBrown.withOpacity(0.05),
                          valueColor: AlwaysStoppedAnimation<Color>(
                            _getColorForCategory(entry.key, entry.value)
                          ),
                          minHeight: 5,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    SizedBox(
                      width: 25,
                      child: Text(
                        '${(entry.value * 100).toInt()}',
                        textAlign: TextAlign.right,
                        style: GoogleFonts.lato(fontSize: 11, fontWeight: FontWeight.w900, color: AppColors.structuralBrown),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
        
        const SizedBox(height: 16),
        
        // Dynamic Quick Stats with Glass styling
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildQuickStat('Prop Score', '${efficiency.totalScore.toInt()}', AppColors.structuralBrown),
            _buildQuickStat('Market %', 'Top ${((1-efficiency.percentileComparedToMarket)*100).toInt()}%', AppColors.sageGreen),
            _buildQuickStat('Fit', efficiency.efficiencyLabel.split(' ').first, AppColors.mutedGold),
          ],
        ),
        
        const SizedBox(height: 16),
        
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () => context.push(
              '/marketplace/listing/${widget.listing.id}', 
              extra: {'listing': widget.listing, 'initialView': 'image'}
            ),
            style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.structuralBrown,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                padding: const EdgeInsets.symmetric(vertical: 14),
                elevation: 0,
            ),
            child: Text(
              'VIEW FULL KEJAPIN BLUEPRINT', 
              style: GoogleFonts.montserrat(fontWeight: FontWeight.w800, fontSize: 12, letterSpacing: 0.5)
            ),
          ),
        ),
      ],
    );
  }

  IconData _getIconForCategory(String category) {
    switch (category) {
      case 'Life-Path Fit': return Icons.route;
      case 'Stage Radar': return Icons.directions_bus;
      case 'Network Strength': return Icons.wifi;
      case 'Water Reliability': return Icons.water_drop;
      case 'Power Stability': return Icons.bolt;
      case 'Security': return Icons.security;
      case 'Retail Density': return Icons.shopping_bag;
      case 'Healthcare': return Icons.local_hospital;
      case 'Wellness': return Icons.spa;
      case 'Vibe Match': return Icons.celebration;
      default: return Icons.star;
    }
  }

  Color _getColorForCategory(String key, double val) {
    if (val > 0.8) return AppColors.sageGreen;
    if (val > 0.5) return AppColors.mutedGold;
    return AppColors.brickRed.withOpacity(0.6);
  }

  Color _getCategoryStandardColor(String category) {
    switch (category) {
      case 'Life-Path Fit': return Colors.blue;
      case 'Stage Radar': return Colors.orange;
      case 'Network Strength': return Colors.purple;
      case 'Water Reliability': return Colors.cyan;
      case 'Power Stability': return Colors.amber;
      case 'Security': return Colors.red;
      case 'Retail Density': return Colors.green;
      case 'Healthcare': return Colors.pink;
      case 'Wellness': return Colors.teal;
      case 'Vibe Match': return Colors.indigo;
      default: return Colors.grey;
    }
  }

  Widget _buildQuickStat(String label, String value, Color color) {
    return Expanded(
      child: Column(
        children: [
          Text(
            value, 
            style: GoogleFonts.montserrat(
              fontSize: 15, 
              fontWeight: FontWeight.w900, 
              color: color
            )
          ),
          Text(
            label, 
            style: GoogleFonts.lato(
              fontSize: 10, 
              fontWeight: FontWeight.bold,
              color: Colors.grey[600]
            )
          ),
        ],
      ),
    );
  }

  Widget _buildMapView(EfficiencyScore efficiency) {
    final destination = LatLng(widget.listing.latitude, widget.listing.longitude);
    double distance = 0;
    if (_currentPosition != null) {
      distance = Geolocator.distanceBetween(
        _currentPosition!.latitude, 
        _currentPosition!.longitude, 
        destination.latitude, 
        destination.longitude
      ) / 1000.0;
    }

    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: FlutterMap(
            options: MapOptions(
              initialCenter: destination,
              initialZoom: 14.5,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.kejapin.client',
              ),
              PolylineLayer<Object>(
              polylines: [
                  if (_currentPosition != null)
                  Polyline(
                      points: [
                      LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
                      destination,
                      ],
                      strokeWidth: 3,
                      color: AppColors.structuralBrown.withOpacity(0.5),
                  ),
                  // 10 Category Lines
                  ...efficiency.categories.entries.map((entry) {
                      final offset = _getOffsetForCategory(entry.key);
                      return _buildAmenityRoute(destination, offset.dy, offset.dx, _getCategoryStandardColor(entry.key));
                  }).toList(),
              ],
              ),
              MarkerLayer(
                markers: [
                  Marker(
                    point: destination,
                    width: 140,
                    height: 50,
                    child: _MiniListingMarker(listing: widget.listing, score: efficiency.totalScore),
                  ),
                  if (_currentPosition != null)
                    Marker(
                      point: LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
                      width: 24,
                      height: 24,
                      child: Container(
                        decoration: BoxDecoration(
                          color: AppColors.sageGreen,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                          boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 4)],
                        ),
                        child: const Icon(Icons.person, color: Colors.white, size: 12),
                      ),
                    ),
                  // 10 Category Markers
                  ...efficiency.categories.entries.map((entry) {
                      final offset = _getOffsetForCategory(entry.key);
                      return _buildAmenityMarker(
                          destination, 
                          offset.dy, 
                          offset.dx, 
                          _getCategoryStandardColor(entry.key), 
                          _getIconForCategory(entry.key)
                      );
                  }).toList(),
                ],
              ),
            ],
          ),
        ),
        
        // Map Overlays
        Positioned(
          top: 12,
          left: 12,
          right: 12,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GlassContainer(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                borderRadius: BorderRadius.circular(20),
                color: Colors.white,
                opacity: 0.85,
                child: Text(
                  '${distance.toStringAsFixed(1)} km from you',
                  style: GoogleFonts.lato(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.structuralBrown),
                ),
              ),
              GestureDetector(
                onTap: () => cardKey.currentState?.toggleCard(),
                child: GlassContainer(
                  padding: const EdgeInsets.all(6),
                  borderRadius: BorderRadius.circular(20),
                  color: Colors.white,
                  opacity: 0.85,
                  child: const Icon(Icons.close, size: 16, color: AppColors.structuralBrown),
                ),
              ),
            ],
          ),
        ),

        // Legend Dropdown
        Positioned(
            top: 50,
            right: 12,
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                    GestureDetector(
                        onTap: () => setState(() => _showLegend = !_showLegend),
                        child: GlassContainer(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            borderRadius: BorderRadius.circular(12),
                            color: AppColors.structuralBrown,
                            opacity: 0.9,
                            child: Row(
                                children: [
                                    Text(
                                        'LEGEND', 
                                        style: GoogleFonts.montserrat(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.white)
                                    ),
                                    const SizedBox(width: 4),
                                    Icon(_showLegend ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down, size: 14, color: Colors.white),
                                ],
                            ),
                        ),
                    ),
                    if (_showLegend)
                        FadeInRight(
                            duration: const Duration(milliseconds: 200),
                            child: Padding(
                                padding: const EdgeInsets.only(top: 8),
                                child: GlassContainer(
                                    width: 160,
                                    padding: const EdgeInsets.all(8),
                                    borderRadius: BorderRadius.circular(12),
                                    color: Colors.white,
                                    opacity: 0.95,
                                    child: Column(
                                        children: efficiency.categories.entries.map((e) => _buildLegendItem(e.key, e.value)).toList(),
                                    ),
                                ),
                            ),
                        ),
                ],
            ),
        ),
        
        Positioned(
          bottom: 12,
          right: 12,
          child: FloatingActionButton.small(
            onPressed: () => context.push(
              '/marketplace/listing/${widget.listing.id}', 
              extra: {'listing': widget.listing, 'initialView': 'map'}
            ),
            backgroundColor: AppColors.structuralBrown,
            child: const Icon(Icons.open_in_new, color: Colors.white, size: 18),
          ),
        ),
      ],
    );
  }

  Widget _buildLegendItem(String category, double score) {
      return Padding(
          padding: const EdgeInsets.symmetric(vertical: 2),
          child: Row(
              children: [
                  Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                          color: _getCategoryStandardColor(category),
                          shape: BoxShape.circle,
                      ),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                      child: Text(
                          category, 
                          style: GoogleFonts.lato(fontSize: 9, fontWeight: FontWeight.bold),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                      )
                  ),
                  Text(
                      '${(score * 100).toInt()}', 
                      style: GoogleFonts.lato(fontSize: 9, fontWeight: FontWeight.w900, color: AppColors.structuralBrown)
                  ),
              ],
          ),
      );
  }

  Offset _getOffsetForCategory(String category) {
      // Return unique offsets to spread markers around the property
      switch (category) {
          case 'Life-Path Fit': return const Offset(0.005, 0.003);
          case 'Stage Radar': return const Offset(-0.004, -0.005);
          case 'Network Strength': return const Offset(0.007, -0.002);
          case 'Water Reliability': return const Offset(-0.006, 0.008);
          case 'Power Stability': return const Offset(0.003, -0.009);
          case 'Security': return const Offset(-0.003, 0.004);
          case 'Retail Density': return const Offset(0.009, 0.006);
          case 'Healthcare': return const Offset(-0.008, -0.004);
          case 'Wellness': return const Offset(0.004, 0.008);
          case 'Vibe Match': return const Offset(-0.002, -0.008);
          default: return const Offset(0, 0);
      }
  }

  Marker _buildAmenityMarker(LatLng base, double offLat, double offLng, Color color, IconData icon) {
    return Marker(
      point: LatLng(base.latitude + offLat, base.longitude + offLng),
      width: 24,
      height: 24,
      child: FadeIn(
          duration: const Duration(milliseconds: 500),
          child: Container(
            decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 1.5),
                boxShadow: [BoxShadow(color: color.withOpacity(0.3), blurRadius: 4, spreadRadius: 1)],
            ),
            child: Icon(icon, color: Colors.white, size: 10),
          ),
      ),
    );
  }

  Polyline _buildAmenityRoute(LatLng base, double offLat, double offLng, Color color) {
    return Polyline(
      points: [
        base,
        LatLng(base.latitude + offLat, base.longitude + offLng),
      ],
      strokeWidth: 1.5,
      color: color.withOpacity(0.35),
    );
  }
}

class _MiniListingMarker extends StatelessWidget {
    final ListingEntity listing;
    final double score;

    const _MiniListingMarker({required this.listing, required this.score});

    @override
    Widget build(BuildContext context) {
        return Container(
            decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.structuralBrown.withOpacity(0.2)),
                boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 4)),
                ],
            ),
            child: Row(
                children: [
                    ClipRRect(
                        borderRadius: const BorderRadius.horizontal(left: Radius.circular(9)),
                        child: SizedBox(
                            width: 45,
                            height: 50,
                            child: listing.photos.isNotEmpty 
                                ? CachedNetworkImage(imageUrl: listing.photos.first, fit: BoxFit.cover)
                                : Container(color: Colors.grey),
                        ),
                    ),
                    Expanded(
                        child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                    Text(
                                        'KES ${(listing.priceAmount / 1000).toStringAsFixed(0)}k', 
                                        style: GoogleFonts.montserrat(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.structuralBrown)
                                    ),
                                    const SizedBox(height: 2),
                                    Row(
                                        children: [
                                            Container(
                                                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                                                decoration: BoxDecoration(
                                                    color: AppColors.structuralBrown.withOpacity(0.1),
                                                    borderRadius: BorderRadius.circular(4),
                                                ),
                                                child: Text(
                                                    '${score.toInt()}', 
                                                    style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: AppColors.structuralBrown)
                                                ),
                                            ),
                                            const SizedBox(width: 4),
                                            const Icon(Icons.star, size: 8, color: AppColors.mutedGold),
                                            Text(' ${listing.rating}', style: const TextStyle(fontSize: 8, color: Colors.grey)),
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
}

class _AmenityIcon extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color? color;

  const _AmenityIcon({required this.icon, required this.label, this.color});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: color ?? Colors.grey[600]),
        if (label.isNotEmpty) ...[
          const SizedBox(width: 4),
          Text(
            label,
            style: GoogleFonts.lato(fontSize: 12, color: Colors.grey[600], fontWeight: FontWeight.bold),
          ),
        ],
      ],
    );
  }
}

class CircularScoreIndicator extends StatelessWidget {
  final double score;
  final double size;

  const CircularScoreIndicator({super.key, required this.score, required this.size});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CircularProgressIndicator(
        value: score,
        strokeWidth: 4,
        backgroundColor: Colors.white24,
        valueColor: AlwaysStoppedAnimation<Color>(
          score > 0.8 ? AppColors.sageGreen : AppColors.mutedGold
        ),
      ),
    );
  }
}

class _ShimmerPlaceholder extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      period: const Duration(milliseconds: 1200),
      child: Container(color: Colors.grey[300]),
    );
  }
}

class _PulseBar extends StatefulWidget {
  final int index;
  final double value;
  final Color color;

  const _PulseBar({required this.index, required this.value, required this.color});

  @override
  State<_PulseBar> createState() => _PulseBarState();
}

class _PulseBarState extends State<_PulseBar> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 1500 + _random.nextInt(1000)),
    );

    _animation = Tween<double>(
      begin: 0.85,
      end: 1.15,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOutSine,
    ));

    // Stagger the start
    Future.delayed(Duration(milliseconds: widget.index * 100), () {
      if (mounted) _controller.repeat(reverse: true);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: FadeInUp(
        delay: Duration(milliseconds: 100 * widget.index),
        from: 15,
        child: AnimatedBuilder(
          animation: _animation,
          builder: (context, child) {
            return Container(
              width: 4,
              height: (12 + (widget.value * 18)) * _animation.value,
              decoration: BoxDecoration(
                color: widget.color,
                borderRadius: BorderRadius.circular(2),
              ),
            );
          },
        ),
      ),
    );
  }
}
