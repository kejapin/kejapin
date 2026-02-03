import 'package:flutter/material.dart';
import 'package:client/features/marketplace/domain/listing_entity.dart';
import 'package:client/core/constants/app_colors.dart';
import 'package:cached_network_image/cached_network_image.dart';

class PropertyBottomSheetContent extends StatelessWidget {
  final ListingEntity listing;
  final ScrollController scrollController; // For scrolling list inside sheet
  final VoidCallback onChatTap;
  final VoidCallback onViewDetailsTap;

  const PropertyBottomSheetContent({
    super.key,
    required this.listing,
    required this.scrollController,
    required this.onChatTap,
    required this.onViewDetailsTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Drag Handle
          Center(
            child: Container(
              margin: const EdgeInsets.only(top: 12, bottom: 8),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          // Scrollable Content
          Expanded(
            child: ListView(
              controller: scrollController,
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              children: [
                // Header (Compatible with collapsed view)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Image
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: SizedBox(
                        width: 100,
                        height: 100,
                        child: CachedNetworkImage(
                          imageUrl: listing.photos.isNotEmpty ? listing.photos.first : '',
                          fit: BoxFit.cover,
                          placeholder: (context, url) => Container(color: Colors.grey[200]),
                          errorWidget: (context, url, error) => const Icon(Icons.error),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    // Details
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            listing.title,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'KSh ${(listing.priceAmount / 1000).toStringAsFixed(0)}k/mo',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppColors.structuralBrown,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Icon(Icons.star, color: AppColors.mutedGold, size: 16),
                              const SizedBox(width: 4),
                              const Text('4.8 (12 reviews)', style: TextStyle(fontSize: 12, color: Colors.grey)),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),
                
                // Quick Actions
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: onChatTap,
                        icon: const Icon(Icons.chat_bubble_outline),
                        label: const Text('Chat'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: AppColors.structuralBrown,
                          side: const BorderSide(color: AppColors.structuralBrown),
                          elevation: 0,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: onViewDetailsTap,
                        icon: const Icon(Icons.visibility_outlined),
                        label: const Text('View Details'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.structuralBrown,
                          foregroundColor: AppColors.champagne,
                          elevation: 0,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // Specs
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildSpecItem(Icons.king_bed_outlined, '${listing.bedrooms} Beds'),
                    _buildSpecItem(Icons.bathtub_outlined, '${listing.bathrooms} Baths'),
                    if (listing.sqft != null)
                      _buildSpecItem(Icons.square_foot, '${listing.sqft} m²'),
                  ],
                ),
                
                const SizedBox(height: 24),
                
                // Description Preview
                const Text(
                  'About this home',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  listing.description,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: Colors.grey[700], height: 1.5),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSpecItem(IconData icon, String text) {
    return Column(
      children: [
        Icon(icon, color: Colors.grey, size: 24),
        const SizedBox(height: 4),
        Text(text, style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.w500)),
      ],
    );
  }
}
