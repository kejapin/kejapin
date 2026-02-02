import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart' as gf;
import 'package:latlong2/latlong.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_map/flutter_map.dart'; // Ensure flutter_map is used for detailed view
import '../../../../core/constants/app_colors.dart';
import '../../../../core/services/commute_service.dart';
import '../../../../core/services/navigation_service.dart';
import 'package:geolocator/geolocator.dart';
import '../../../../core/widgets/custom_app_bar.dart';
import '../../../../core/widgets/glass_container.dart';
import '../../../profile/data/life_pin_repository.dart';
import '../../../profile/domain/life_pin_model.dart';
import '../../data/listings_repository.dart';
import '../../domain/listing_entity.dart';
import '../../../search/data/models/search_result.dart';
import '../../../../core/services/efficiency_service.dart';
import 'package:client/features/messages/data/notifications_repository.dart';
import '../../../../core/services/notification_service.dart';

class ListingDetailsScreen extends StatefulWidget {
  final String id;
  final SearchResult? extra;
  final String activeViewMode; // 'image' or 'map'

  const ListingDetailsScreen({
    super.key,
    required this.id,
    this.extra,
    this.activeViewMode = 'image',
  });

  @override
  State<ListingDetailsScreen> createState() => _ListingDetailsScreenState();
}

class _ListingDetailsScreenState extends State<ListingDetailsScreen> {
  final ListingsRepository _listingsRepo = ListingsRepository();
  final LifePinRepository _lifePinRepo = LifePinRepository();
  final NotificationsRepository _notificationsRepo = NotificationsRepository();
  final CommuteService _commuteService = CommuteService();
  final NavigationService _navService = NavigationService();
  final MapController _mapController = MapController();

  late Future<ListingEntity> _listingFuture;
  late Future<List<LifePin>> _lifePinsFuture;
  final Map<String, CommuteResult> _commuteResults = {};
  
  late bool _showMap;
  bool _isSaved = false;
  bool _isSaving = false;
  // Index and Controller moved to ListingImageGallery to prevent whole-screen rebuilds

  @override
  void initState() {
    super.initState();
    _showMap = widget.activeViewMode == 'map';
    _listingFuture = _listingsRepo.fetchListingById(widget.id);
    _lifePinsFuture = _lifePinRepo.getLifePins();
    _calculateCommutes();
    _checkSavedStatus();
  }

  @override
  void dispose() {
    // Controller disposal handled in ListingImageGallery
    super.dispose();
  }

  Future<void> _checkSavedStatus() async {
    try {
      final isSaved = await _listingsRepo.isListingSaved(widget.id);
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
      await _listingsRepo.toggleSaveListing(widget.id, _isSaved);
      if (mounted) {
        setState(() {
          _isSaved = !_isSaved;
          _isSaving = false;
        });
        if (_isSaved) {
           _notificationsRepo.createNotification(
             title: 'Property Pinned! 📍',
             message: 'Selected property added to your life-path.',
             type: 'FAVORITE',
             route: '/saved',
           );
           NotificationService().showNotification(
             title: 'Property Pinned! 📍',
             body: 'Listing added to your life-path.',
           );
        } else {
           NotificationService().showNotification(
             title: 'Property Removed 🗑️',
             body: 'Listing removed from your life-path.',
           );
           _notificationsRepo.createNotification(
             title: 'Property Removed 🗑️',
             message: 'Selected property removed from your life-path.',
             type: 'SYSTEM',
           );
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_isSaved ? 'Property pinned to your life-path!' : 'Property unpinned.'),
            behavior: SnackBarBehavior.floating,
            backgroundColor: AppColors.structuralBrown,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSaving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  Future<void> _calculateCommutes() async {
    try {
      final listing = await _listingFuture;
      final pins = await _lifePinsFuture;

      for (final pin in pins) {
        final result = await _commuteService.calculateCommute(
          origin: LatLng(listing.latitude, listing.longitude),
          destination: LatLng(pin.latitude, pin.longitude),
          mode: pin.transportMode,
        );
        setState(() {
          _commuteResults[pin.id] = result;
        });
      }
    } catch (e) {
      print('Error calculating commutes: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.alabaster,
      appBar: const CustomAppBar(title: 'Property Details', showSearch: false),
      body: FutureBuilder(
        future: Future.wait([_listingFuture, _lifePinsFuture]),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final listing = snapshot.data![0] as ListingEntity;
          final lifePins = snapshot.data![1] as List<LifePin>;

          return Stack(
            children: [
              Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildHeader(listing, lifePins),
                          Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildTitleSection(listing),
                                const SizedBox(height: 24),
                                _buildCommuteSection(lifePins),
                                const SizedBox(height: 24),
                                _buildEfficiencySection(listing),
                                const SizedBox(height: 24),
                                _buildDescriptionSection(listing),
                                const SizedBox(height: 24),
                                _buildAmenitiesSection(listing),
                                const SizedBox(height: 20), // Extra padding for bottom list item
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  _buildBottomBar(listing),
                ],
              ),
              // Floating Toggle Button moved into Stack correctly if needed, or keep in header
              Positioned(
                 top: 16,
                 left: 0, 
                 right: 0,
                 child: Align(
                   alignment: Alignment.topCenter,
                   child: GestureDetector(
                     onTap: () {
                       setState(() {
                         _showMap = !_showMap;
                       });
                     },
                     child: Container(
                       padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                       decoration: BoxDecoration(
                         color: AppColors.structuralBrown,
                         borderRadius: BorderRadius.circular(30),
                         boxShadow: [
                           BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 8, offset: const Offset(0, 4)),
                         ],
                       ),
                       child: Row(
                         mainAxisSize: MainAxisSize.min,
                         children: [
                           Icon(_showMap ? Icons.image : Icons.map_outlined, color: AppColors.champagne, size: 18),
                           const SizedBox(width: 8),
                           Text(
                             _showMap ? "Show Photos" : "Show Map",
                             style: const TextStyle(
                               color: AppColors.champagne,
                               fontWeight: FontWeight.bold,
                             ),
                           ),
                         ],
                       ),
                     ),
                   ),
                 ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildHeader(ListingEntity listing, List<LifePin> lifePins) {
    if (_showMap) {
      return ClipRRect(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(32),
          topRight: Radius.circular(32),
        ),
        child: SizedBox(
          height: 400,
          child: FlutterMap(
          mapController: _mapController,
          options: MapOptions(
            initialCenter: LatLng(listing.latitude, listing.longitude),
            initialZoom: 14.0,
          ),
          children: [
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'com.kejapin.app',
            ),
            // Floating Navigation Button
            Positioned(
              bottom: 16,
              right: 16,
              child: FloatingActionButton.small(
                onPressed: () {
                  context.push('/map', extra: SearchResult(
                    id: listing.id,
                    title: listing.title,
                    subtitle: '${listing.city}, ${listing.county}',
                    type: SearchResultType.location,
                    metadata: {'lat': listing.latitude, 'lon': listing.longitude},
                  ));
                },
                backgroundColor: AppColors.structuralBrown,
                child: const Icon(Icons.navigation, color: AppColors.champagne),
              ),
            ),
            // My Location Button
            Positioned(
              bottom: 16,
              right: 80, // Left of navigation button
              child: FloatingActionButton.small(
                heroTag: 'listing_location',
                onPressed: () async {
                   try {
                      final pos = await _navService.getCurrentLocation();
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
            MarkerLayer(
              markers: [
                // Property Marker
                Marker(
                  point: LatLng(listing.latitude, listing.longitude),
                  width: 40,
                  height: 40,
                  child: const Icon(Icons.location_on, color: AppColors.brickRed, size: 40),
                ),
                // 10 Category Neural Visualization
                ...EfficiencyService().calculateScore(listing).categories.entries.map((entry) {
                   final offset = _getCategoryOffset(entry.key);
                   return Marker(
                     point: LatLng(listing.latitude + offset.latitude, listing.longitude + offset.longitude),
                     width: 28,
                     height: 28,
                     child: Container(
                       decoration: BoxDecoration(
                         color: _getCategoryColor(entry.key, entry.value),
                         shape: BoxShape.circle,
                         border: Border.all(color: Colors.white, width: 2),
                         boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 4)],
                       ),
                       child: Icon(_getEfficiencyIcon(entry.key), color: Colors.white, size: 12),
                     ),
                   );
                }),
                // Life Pins Markers
                ...lifePins.map((pin) => Marker(
                  point: LatLng(pin.latitude, pin.longitude),
                  width: 34,
                  height: 34,
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColors.structuralBrown,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                      boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 4)],
                    ),
                    child: Icon(_getIconForMode(pin.transportMode), color: Colors.white, size: 16),
                  ),
                )),
              ],
            ),
            PolylineLayer(
              polylines: [
                ...EfficiencyService().calculateScore(listing).categories.entries.map((entry) {
                  final offset = _getCategoryOffset(entry.key);
                  return Polyline(
                    points: [
                      LatLng(listing.latitude, listing.longitude),
                      LatLng(listing.latitude + offset.latitude, listing.longitude + offset.longitude),
                    ],
                    strokeWidth: 2,
                    color: _getCategoryColor(entry.key, entry.value).withOpacity(0.4),
                  );
                }),
              ],
            ),
          ],
        ),
      ),
    );
  }
  
    // Image Gallery View
    return ListingImageGallery(
      photos: listing.photos,
      isSaved: _isSaved,
      isSaving: _isSaving,
      onToggleSave: _toggleSave,
    );
  }

  LatLng _getCategoryOffset(String category) {
    switch (category) {
      case 'Life-Path Fit': return const LatLng(0.005, 0.003);
      case 'Stage Radar': return const LatLng(-0.004, -0.005);
      case 'Network Strength': return const LatLng(0.007, -0.002);
      case 'Water Reliability': return const LatLng(-0.006, 0.008);
      case 'Power Stability': return const LatLng(0.003, -0.009);
      case 'Security': return const LatLng(-0.003, 0.004);
      case 'Retail Density': return const LatLng(0.009, 0.006);
      case 'Healthcare': return const LatLng(-0.008, -0.004);
      case 'Wellness': return const LatLng(0.004, 0.008);
      case 'Vibe Match': return const LatLng(-0.002, -0.008);
      default: return const LatLng(0, 0);
    }
  }

  Color _getCategoryColor(String key, double val) {
    if (val > 0.8) return AppColors.sageGreen;
    if (val > 0.5) return AppColors.mutedGold;
    return AppColors.brickRed.withOpacity(0.6);
  }

  Widget _buildTitleSection(ListingEntity listing) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.mutedGold.withOpacity(0.2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                listing.propertyType,
                style: const TextStyle(color: AppColors.structuralBrown, fontWeight: FontWeight.bold, fontSize: 12),
              ),
            ),
            Text(
              'KES ${listing.priceAmount.toStringAsFixed(0)}',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.structuralBrown),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Text(
          listing.title,
          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            const Icon(Icons.location_on, size: 16, color: Colors.grey),
            const SizedBox(width: 4),
            Text(
              '${listing.city}, ${listing.county}',
              style: const TextStyle(color: Colors.grey),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            _buildIconInfo(Icons.star, '${listing.rating} (${listing.reviewCount} reviews)', color: AppColors.mutedGold),
            const SizedBox(width: 20),
            _buildIconInfo(Icons.king_bed, '${listing.bedrooms} Beds'),
            const SizedBox(width: 20),
            _buildIconInfo(Icons.bathtub, '${listing.bathrooms} Baths'),
            const SizedBox(width: 20),
            if (listing.sqft != null)
              _buildIconInfo(Icons.square_foot, '${listing.sqft} sqft'),
          ],
        ),
      ],
    );
  }

  Widget _buildIconInfo(IconData icon, String text, {Color? color}) {
    return Row(
      children: [
        Icon(icon, size: 20, color: color ?? AppColors.structuralBrown),
        const SizedBox(width: 6),
        Text(text, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13)),
      ],
    );
  }

  Widget _buildCommuteSection(List<LifePin> lifePins) {
    if (lifePins.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Your Life Path Commutes',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 100,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: lifePins.length,
            itemBuilder: (context, index) {
              final pin = lifePins[index];
              final commute = _commuteResults[pin.id];

              return Container(
                width: 160,
                margin: const EdgeInsets.only(right: 12),
                child: GlassContainer(
                  borderRadius: BorderRadius.circular(12),
                  blur: 10,
                  opacity: 0.1,
                  color: AppColors.structuralBrown,
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(_getIconForMode(pin.transportMode), size: 14, color: AppColors.structuralBrown),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                pin.label,
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        const Spacer(),
                        if (commute != null)
                          ...[
                            Text(
                              commute.formattedDuration,
                              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.structuralBrown),
                            ),
                            Text(
                              commute.formattedDistance,
                              style: const TextStyle(fontSize: 11, color: Colors.grey),
                            ),
                          ]
                        else
                          const Text('Calculating...', style: TextStyle(fontSize: 12, color: Colors.grey)),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildEfficiencySection(ListingEntity listing) {
    final efficiency = EfficiencyService().calculateScore(listing);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Living Efficiency',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Text(
                  efficiency.efficiencyLabel.toUpperCase(),
                  style: gf.GoogleFonts.montserrat(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: AppColors.mutedGold,
                    letterSpacing: 1.2,
                  ),
                ),
              ],
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.structuralBrown,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                'Prop Score: ${efficiency.totalScore.toInt()}/100',
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        GlassContainer(
          borderRadius: BorderRadius.circular(16),
          blur: 10,
          opacity: 0.05,
          color: AppColors.structuralBrown,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            children: [
              // Efficiency Pulse Chart Integration
              _buildEfficiencySpectrum(efficiency),
              const Divider(height: 32),
              ...efficiency.categories.entries.map((entry) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            _getEfficiencyIcon(entry.key),
                            size: 16,
                            color: AppColors.structuralBrown.withOpacity(0.7),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              entry.key,
                              style: gf.GoogleFonts.lato(fontWeight: FontWeight.bold, fontSize: 13),
                            ),
                          ),
                          Text(
                            '${(entry.value * 100).toInt()}%',
                            style: gf.GoogleFonts.lato(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.structuralBrown),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: entry.value,
                          backgroundColor: AppColors.structuralBrown.withOpacity(0.1),
                          valueColor: AlwaysStoppedAnimation<Color>(
                            _getCategoryColor(entry.key, entry.value)
                          ),
                          minHeight: 6,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDescriptionSection(ListingEntity listing) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Description',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Text(
          listing.description,
          style: const TextStyle(color: Colors.black87, height: 1.5),
        ),
      ],
    );
  }

  Widget _buildAmenitiesSection(ListingEntity listing) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Amenities',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: listing.amenities.map((amenity) => _buildAmenityTag(amenity)).toList(),
        ),
      ],
    );
  }

  Widget _buildAmenityTag(String amenity) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(amenity, style: const TextStyle(fontSize: 13)),
    );
  }

  Widget _buildBottomBar(ListingEntity listing) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -5)),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: () {
                context.push('/chat', extra: {
                  'otherUserId': listing.ownerId,
                  'otherUserName': listing.ownerName,
                  'avatarUrl': listing.ownerAvatar,
                  'propertyTitle': listing.title,
                  'propertyId': listing.id,
                });
              },
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                side: const BorderSide(color: AppColors.structuralBrown),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: const Text('Connect with Landlord', style: TextStyle(color: AppColors.structuralBrown)),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton(
              onPressed: () {
                 // Could be a specialized viewing request message
                 context.push('/chat', extra: {
                  'otherUserId': listing.ownerId,
                  'otherUserName': listing.ownerName,
                  'avatarUrl': listing.ownerAvatar,
                  'propertyTitle': listing.title,
                  'propertyId': listing.id,
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.structuralBrown,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: const Text('Book Viewing', style: TextStyle(color: Colors.white)),
            ),
          ),
        ],
      ),
    );
  }

  IconData _getIconForMode(String mode) {
    switch (mode) {
      case 'DRIVE':
        return Icons.directions_car;
      case 'WALK':
        return Icons.directions_walk;
      case 'CYCLE':
        return Icons.directions_bike;
      case 'PUBLIC_TRANSPORT':
        return Icons.directions_bus;
      default:
        return Icons.location_on;
    }
  }

  Widget _buildEfficiencySpectrum(EfficiencyScore efficiency) {
    return Container(
      height: 60,
      width: double.infinity,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: efficiency.categories.values.toList().asMap().entries.map((entry) {
          return _PulseBar(
            index: entry.key,
            value: entry.value,
            color: _getCategoryColor('', entry.value),
          );
        }).toList(),
      ),
    );
  }

  IconData _getEfficiencyIcon(String category) {
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
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          width: 8,
          height: (10 + (widget.value * 40)) * _animation.value,
          decoration: BoxDecoration(
            color: widget.color.withOpacity(0.9),
            borderRadius: BorderRadius.circular(4),
            boxShadow: [
              BoxShadow(
                color: widget.color.withOpacity(0.3),
                blurRadius: 10,
                spreadRadius: 1,
              ),
            ],
          ),
        );
      },
    );
  }
}

class _GalleryViewer extends StatelessWidget {
  final List<String> photos;
  final PageController controller;
  final int currentIndex;
  final Function(int) onPageChanged;

  const _GalleryViewer({
    required this.photos,
    required this.controller,
    required this.currentIndex,
    required this.onPageChanged,
  });

  @override
  Widget build(BuildContext context) {
    if (photos.isEmpty) {
      return Container(
        color: Colors.grey[200],
        child: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.image_not_supported_outlined, size: 50, color: Colors.grey),
              SizedBox(height: 8),
              Text('No photos available', style: TextStyle(color: Colors.grey)),
            ],
          ),
        ),
      );
    }

    return PageView.builder(
      physics: const BouncingScrollPhysics(),
      key: const PageStorageKey('listing_gallery'),
      controller: controller,
      itemCount: photos.length,
      onPageChanged: onPageChanged,
      itemBuilder: (context, index) {
        return Image.network(
          photos[index],
          key: ValueKey('${photos[index]}_$index'),
          fit: BoxFit.cover,
          gaplessPlayback: true, // Prevents flickering
          loadingBuilder: (ctx, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return Center(
              child: CircularProgressIndicator(
                value: loadingProgress.expectedTotalBytes != null
                    ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                    : null,
                color: AppColors.structuralBrown,
              ),
            );
          },
          errorBuilder: (ctx, _, __) => Container(
            color: Colors.grey[200],
            child: const Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.broken_image, size: 40, color: Colors.grey),
                SizedBox(height: 8),
                Text('Image unavailable', style: TextStyle(color: Colors.grey)),
              ],
            ),
          ),
        );
      },
    );
  }
}

class ListingImageGallery extends StatefulWidget {
  final List<String> photos;
  final bool isSaved;
  final bool isSaving;
  final VoidCallback onToggleSave;

  const ListingImageGallery({
    super.key,
    required this.photos,
    required this.isSaved,
    required this.isSaving,
    required this.onToggleSave,
  });

  @override
  State<ListingImageGallery> createState() => _ListingImageGalleryState();
}

class _ListingImageGalleryState extends State<ListingImageGallery> {
  int _currentImageIndex = 0;
  final PageController _pageController = PageController();

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.only(
        topLeft: Radius.circular(32),
        topRight: Radius.circular(32),
      ),
      child: SizedBox(
        height: 400,
        width: MediaQuery.of(context).size.width,
        child: Stack(
          children: [
            // 1. Swipeable Image Gallery
            _GalleryViewer(
              photos: widget.photos,
              controller: _pageController,
              currentIndex: _currentImageIndex,
              onPageChanged: (index) {
                if (_currentImageIndex != index) {
                  setState(() => _currentImageIndex = index);
                }
              },
            ),

            // 2. Cinematic Gradient Overlay (Bottom)
            Positioned.fill(
              child: IgnorePointer(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withOpacity(0.2), // Slight top shadow for buttons
                        Colors.transparent,
                        Colors.transparent,
                        Colors.black.withOpacity(0.6), // Stronger bottom shadow for text
                      ],
                      stops: const [0.0, 0.2, 0.7, 1.0],
                    ),
                  ),
                ),
              ),
            ),

// 3. Thumbnail Strip (Interactive)
if (widget.photos.length > 1)
  Positioned(
    bottom: 16,
    left: 0,
    right: 0,
    child: SizedBox(
      height: 60,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: widget.photos.length,
        itemBuilder: (context, index) {
          final isSelected = index == _currentImageIndex;
          return GestureDetector(
            onTap: () {
              if (_currentImageIndex != index) {
                _pageController.jumpToPage(index);
                // setState will be called by onPageChanged callback
              }
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.only(right: 10),
              width: isSelected ? 60 : 50,
              height: isSelected ? 60 : 50,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                border: isSelected 
                  ? Border.all(color: AppColors.champagne, width: 2) 
                  : Border.all(color: Colors.white.withOpacity(0.5), width: 1),
                boxShadow: isSelected 
                  ? [BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 4, offset: const Offset(0, 2))] 
                  : null,
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(isSelected ? 6 : 7),
                child: Image.network(
                  widget.photos[index],
                  fit: BoxFit.cover,
                  color: isSelected ? null : Colors.black.withOpacity(0.3),
                  colorBlendMode: isSelected ? null : BlendMode.darken,
                ),
              ),
            ),
          );
        },
      ),
    ),
  ),

            // 4. Save Button
            Positioned(
              top: 16,
              right: 16,
              child: GestureDetector(
                onTap: widget.onToggleSave,
                child: GlassContainer(
                  padding: const EdgeInsets.all(10),
                  borderRadius: BorderRadius.circular(30),
                  color: Colors.white,
                  opacity: 0.9,
                  blur: 10,
                  child: widget.isSaving
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.structuralBrown),
                        )
                      : Icon(
                          widget.isSaved ? Icons.favorite : Icons.favorite_border,
                          color: widget.isSaved ? AppColors.brickRed : AppColors.structuralBrown,
                          size: 24,
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
