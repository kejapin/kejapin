import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/services/commute_service.dart';
import '../../../../core/widgets/custom_app_bar.dart';
import '../../../../core/widgets/glass_container.dart';
import '../../../profile/data/life_pin_repository.dart';
import '../../../profile/domain/life_pin_model.dart';
import '../../data/listings_repository.dart';
import '../../domain/listing_entity.dart';
import '../../../search/data/models/search_result.dart';

class ListingDetailsScreen extends StatefulWidget {
  final String id;
  final SearchResult? extra;

  const ListingDetailsScreen({super.key, required this.id, this.extra});

  @override
  State<ListingDetailsScreen> createState() => _ListingDetailsScreenState();
}

class _ListingDetailsScreenState extends State<ListingDetailsScreen> {
  final ListingsRepository _listingsRepo = ListingsRepository();
  final LifePinRepository _lifePinRepo = LifePinRepository();
  final CommuteService _commuteService = CommuteService();

  late Future<ListingEntity> _listingFuture;
  late Future<List<LifePin>> _lifePinsFuture;
  final Map<String, CommuteResult> _commuteResults = {};

  @override
  void initState() {
    super.initState();
    _listingFuture = _listingsRepo.fetchListingById(widget.id);
    _lifePinsFuture = _lifePinRepo.getLifePins();
    _calculateCommutes();
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

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(listing),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildTitleSection(listing),
                      const SizedBox(height: 24),
                      _buildCommuteSection(lifePins),
                      const SizedBox(height: 24),
                      _buildDescriptionSection(listing),
                      const SizedBox(height: 24),
                      _buildAmenitiesSection(listing),
                      const SizedBox(height: 80), // Space for bottom action bar
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
      bottomSheet: _buildBottomBar(),
    );
  }

  Widget _buildHeader(ListingEntity listing) {
    return Container(
      height: 350,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.grey[300],
        image: listing.photos.isNotEmpty
            ? DecorationImage(
                image: NetworkImage(listing.photos[0]),
                fit: BoxFit.cover,
              )
            : null,
      ),
      child: Stack(
        children: [
          Positioned(
            top: 16,
            right: 16,
            child: FloatingActionButton.small(
              onPressed: () {},
              backgroundColor: Colors.white,
              child: const Icon(Icons.favorite_border, color: AppColors.structuralBrown),
            ),
          ),
        ],
      ),
    );
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
            _buildIconInfo(Icons.king_bed, '${listing.bedrooms} Beds'),
            const SizedBox(width: 20),
            _buildIconInfo(Icons.bathtub, '${listing.bathrooms} Baths'),
            const SizedBox(width: 20),
            _buildIconInfo(Icons.square_foot, '1,200 sqft'),
          ],
        ),
      ],
    );
  }

  Widget _buildIconInfo(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 20, color: AppColors.structuralBrown),
        const SizedBox(width: 6),
        Text(text, style: const TextStyle(fontWeight: FontWeight.w500)),
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
                        if (commute != null) ...[
                          Text(
                            commute.formattedDuration,
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.structuralBrown),
                          ),
                          Text(
                            commute.formattedDistance,
                            style: const TextStyle(fontSize: 11, color: Colors.grey),
                          ),
                        ] else
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

  Widget _buildBottomBar() {
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
              onPressed: () {},
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
              onPressed: () {},
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
}
