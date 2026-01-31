import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flip_card/flip_card.dart';
import 'package:shimmer/shimmer.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../domain/listing_entity.dart';
import '../../../../core/widgets/glass_container.dart';
import 'package:google_fonts/google_fonts.dart';

class ListingCard extends StatefulWidget {
  final ListingEntity listing;

  const ListingCard({
    super.key,
    required this.listing,
  });

  @override
  State<ListingCard> createState() => _ListingCardState();
}

class _ListingCardState extends State<ListingCard> {
  final GlobalKey<FlipCardState> cardKey = GlobalKey<FlipCardState>();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 340, // Fixed height for consistent flipping
      child: FlipCard(
        key: cardKey,
        flipOnTouch: false, // We use a specific button to flip
        direction: FlipDirection.HORIZONTAL,
        side: CardSide.FRONT,
        front: _buildFrontSide(),
        back: _buildBackSide(),
      ),
    );
  }

  Widget _buildFrontSide() {
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
                
                // Top Overlay Gradient
                Positioned(
                  top: 0, left: 0, right: 0,
                  child: Container(
                    height: 80,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Colors.black.withOpacity(0.4), Colors.transparent],
                      ),
                    ),
                  ),
                ),

                // Verified Badge
                Positioned(
                  top: 16,
                  left: 16,
                  child: GlassContainer(
                    color: AppColors.mutedGold,
                    opacity: 0.8,
                    blur: 5,
                    borderRadius: BorderRadius.circular(20),
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    child: Row(
                      children: [
                        const Icon(Icons.verified, color: Colors.white, size: 14),
                        const SizedBox(width: 4),
                        Text(
                          'VERIFIED',
                          style: GoogleFonts.montserrat(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Map Flip Button
                Positioned(
                  top: 16,
                  right: 16,
                  child: GestureDetector(
                    onTap: () => cardKey.currentState?.toggleCard(),
                    child: GlassContainer(
                      color: Colors.black,
                      opacity: 0.4,
                      blur: 10,
                      borderRadius: BorderRadius.circular(30),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      child: Row(
                        children: [
                          const Icon(Icons.map_outlined, color: Colors.white, size: 16),
                          const SizedBox(width: 6),
                          Text(
                            'MAP',
                            style: GoogleFonts.montserrat(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
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
                          Text(
                            '★ 4.8', // Placeholder for rating
                            style: GoogleFonts.lato(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: AppColors.structuralBrown,
                            ),
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
                  
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'KES ${widget.listing.priceAmount.toInt()}',
                            style: GoogleFonts.montserrat(
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                              color: AppColors.sageGreen,
                            ),
                          ),
                          Text(
                            '/ month',
                            style: GoogleFonts.lato(
                              fontSize: 12,
                              color: Colors.grey[500],
                            ),
                          ),
                        ],
                      ),
                      ElevatedButton(
                        onPressed: () => context.push(
                          '/marketplace/listing/${widget.listing.id}', 
                          extra: {'listing': widget.listing, 'initialView': 'image'}
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.structuralBrown,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                          elevation: 0,
                        ),
                        child: Text(
                          'View',
                          style: GoogleFonts.montserrat(
                            color: AppColors.champagne,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
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

  Widget _buildBackSide() {
    return GlassContainer(
        borderRadius: BorderRadius.circular(16),
        blur: 10,
        opacity: 0.95,
        color: const Color(0xFFFDFBF7), // Map background color
        borderColor: AppColors.structuralBrown,
        padding: EdgeInsets.zero,
        child: Stack(
          children: [
            // Structural Map Pattern (Simplified for Card)
            Positioned.fill(
              child: Opacity(
                opacity: 0.15,
                child: Image.asset(
                   // Ideally use a static map image generator or a custom painter here
                   // Using the logo as placeholder for now if pattern asset not available
                   'assets/images/logo.png', 
                   repeat: ImageRepeat.repeat,
                   scale: 4,
                   color: AppColors.structuralBrown,
                ),
              ),
            ),
            
            // Map Content
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'LOCATION CONTEXT',
                        style: GoogleFonts.montserrat(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.5,
                          color: AppColors.structuralBrown.withOpacity(0.6),
                        ),
                      ),
                      GestureDetector(
                        onTap: () => cardKey.currentState?.toggleCard(),
                        child: const Icon(Icons.close, color: AppColors.structuralBrown),
                      ),
                    ],
                  ),
                  const Spacer(),
                  
                  // Central Pin Indicator
                  Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.location_on, size: 48, color: AppColors.brickRed),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 4)),
                            ],
                          ),
                          child: Text(
                            widget.listing.locationName,
                            style: GoogleFonts.lato(fontWeight: FontWeight.bold, fontSize: 12),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const Spacer(),

                  // Quick Stats / Life Pins (Mock Data for now)
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.8),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.structuralBrown.withOpacity(0.1)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildMapStat(Icons.work_outline, '15 min', 'to Work'),
                        _buildVerticalDivider(),
                        _buildMapStat(Icons.directions_bus, '5 min', 'to Stop'),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // View Full Map Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () => context.push(
                        '/marketplace/listing/${widget.listing.id}', 
                        extra: {'listing': widget.listing, 'initialView': 'map'}
                      ),
                      style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.structuralBrown,
                          foregroundColor: AppColors.champagne,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      icon: const Icon(Icons.map_outlined, size: 18),
                      label: const Text('VIEW IN FULL MAP'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
    );
  }

  Widget _buildMapStat(IconData icon, String value, String label) {
    return Column(
      children: [
        Icon(icon, size: 20, color: AppColors.structuralBrown),
        const SizedBox(height: 4),
        Text(
          value,
          style: GoogleFonts.montserrat(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.structuralBrown),
        ),
        Text(
          label,
          style: GoogleFonts.lato(fontSize: 10, color: Colors.grey[600]),
        ),
      ],
    );
  }

  Widget _buildVerticalDivider() {
    return Container(
      height: 30,
      width: 1,
      color: AppColors.structuralBrown.withOpacity(0.2),
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
