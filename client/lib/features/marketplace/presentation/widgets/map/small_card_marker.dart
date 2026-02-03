import 'package:flutter/material.dart';
import 'package:client/core/constants/app_colors.dart';
import 'package:client/features/marketplace/domain/listing_entity.dart';
import 'package:cached_network_image/cached_network_image.dart';

class SmallCardMarker extends StatelessWidget {
  final ListingEntity listing;
  final bool isSelected;
  final VoidCallback onTap;

  const SmallCardMarker({
    super.key,
    required this.listing,
    this.isSelected = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 160,
        height: 70, // Compact height
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: isSelected ? Border.all(color: AppColors.structuralBrown, width: 2) : null,
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
            // Thumbnail
            ClipRRect(
              borderRadius: const BorderRadius.horizontal(left: Radius.circular(12)),
              child: SizedBox(
                width: 70,
                height: 70,
                child: CachedNetworkImage(
                  imageUrl: listing.photos.firstOrNull ?? '',
                  fit: BoxFit.cover,
                  errorWidget: (_,__,___) => Container(color: Colors.grey[200]),
                ),
              ),
            ),
            // Info
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'KSh ${(listing.priceAmount/1000).toStringAsFixed(0)}k',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: AppColors.structuralBrown,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${listing.bedrooms} bds • ${listing.bathrooms} ba',
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.grey[700],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
