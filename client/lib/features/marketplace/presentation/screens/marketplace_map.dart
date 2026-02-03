import 'package:animate_do/animate_do.dart';
import 'package:client/features/marketplace/presentation/blocs/map_view/map_view_cubit.dart';
import 'package:client/features/marketplace/presentation/blocs/map_view/map_view_state.dart';
import 'package:client/features/marketplace/presentation/widgets/map/cluster_marker.dart';
import 'package:client/features/marketplace/presentation/widgets/map/floating_search_bar.dart';
import 'package:client/features/marketplace/presentation/widgets/map/price_pill_marker.dart';
import 'package:client/features/marketplace/presentation/widgets/map/property_bottom_sheet.dart';
import 'package:client/features/marketplace/presentation/widgets/map/quick_filter_chips.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_marker_cluster/flutter_map_marker_cluster.dart';
import 'package:latlong2/latlong.dart';
import 'package:go_router/go_router.dart';
import 'package:geolocator/geolocator.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import '../../../../core/constants/app_colors.dart';
import '../../domain/listing_entity.dart';

class MarketplaceMap extends StatelessWidget {
  final List<ListingEntity> listings;
  final VoidCallback onShowFilters;

  const MarketplaceMap({
    super.key, 
    required this.listings,
    required this.onShowFilters,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => MapViewCubit(),
      child: _MarketplaceMapView(
        listings: listings,
        onShowFilters: onShowFilters,
      ),
    );
  }
}

class _MarketplaceMapView extends StatefulWidget {
  final List<ListingEntity> listings;
  final VoidCallback onShowFilters;

  const _MarketplaceMapView({
    required this.listings,
    required this.onShowFilters,
  });

  @override
  State<_MarketplaceMapView> createState() => _MarketplaceMapViewState();
}

class _MarketplaceMapViewState extends State<_MarketplaceMapView> with TickerProviderStateMixin {
  final MapController _mapController = MapController();
  final PanelController _panelController = PanelController();
  
  // Cache sorted listings to avoid re-sorting on every build frame if logic is heavy
  // But for <1000 items it's fast enough in build usually.
  
  @override
  Widget build(BuildContext context) {
    return BlocListener<MapViewCubit, MapViewState>(
      listenWhen: (previous, current) => previous.selectedListing != current.selectedListing,
      listener: (context, state) {
        if (state.selectedListing != null) {
          _panelController.open();
          // Center map on selection? user preference usually. 
          // _mapController.move(LatLng(state.selectedListing!.latitude, state.selectedListing!.longitude), 15);
        } else {
          _panelController.close();
        }
      },
      child: BlocBuilder<MapViewCubit, MapViewState>(
        builder: (context, state) {
          // 1. Filter and Sort Listings based on active Smart Filters
          final displayListings = _processListings(widget.listings, state);

          return SlidingUpPanel(
            controller: _panelController,
            minHeight: 0, // Hidden by default
            maxHeight: MediaQuery.of(context).size.height * 0.6, // 60% screen
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            parallaxEnabled: true,
            parallaxOffset: 0.5,
            backdropEnabled: true, // Dim map when sheet open
            color: Colors.transparent, // We handle content decoration
            boxShadow: const [], // Custom shadow in content
            
            panelBuilder: (scrollController) {
              if (state.selectedListing == null) return const SizedBox.shrink();
              return PropertyBottomSheetContent(
                listing: state.selectedListing!,
                scrollController: scrollController,
                onChatTap: () {
                   // Navigate to chat
                   context.push(
                    '/chat',
                    extra: {
                      'otherUserId': state.selectedListing!.ownerId,
                      'otherUserName': state.selectedListing!.ownerName,
                      'avatarUrl': state.selectedListing!.ownerAvatar,
                      'propertyTitle': state.selectedListing!.title,
                      'propertyId': state.selectedListing!.id,
                    },
                   );
                },
                onViewDetailsTap: () {
                  context.push('/marketplace/listing/${state.selectedListing!.id}');
                },
              );
            },
            
            onPanelClosed: () {
              context.read<MapViewCubit>().closeBottomSheet();
            },

            body: Stack(
              children: [
                // Map Layer
                FlutterMap(
                  mapController: _mapController,
                  options: MapOptions(
                    initialCenter: const LatLng(-1.2921, 36.8219), // Nairobi
                    initialZoom: 13.0,
                    onTap: (_, __) {
                      context.read<MapViewCubit>().closeBottomSheet();
                    },
                    interactionOptions: const InteractionOptions(
                      flags: InteractiveFlag.all & ~InteractiveFlag.rotate,
                    ),
                  ),
                  children: [
                    TileLayer(
                      urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'com.kejapin.client',
                    ),
                    
                    // Smart Clustering Layer
                    MarkerClusterLayerWidget(
                      options: MarkerClusterLayerOptions(
                        maxClusterRadius: 120,
                        size: const Size(100, 60),
                        alignment: Alignment.center,
                        padding: const EdgeInsets.all(50),
                        markers: displayListings.map((listing) {
                          return Marker(
                            point: LatLng(listing.latitude, listing.longitude),
                            width: 80,
                            height: 40,
                            child: PricePillMarker(
                              price: 'KSh ${(listing.priceAmount / 1000).toStringAsFixed(0)}k',
                              isSelected: state.selectedListing?.id == listing.id,
                              isViewed: state.viewedListingIds.contains(listing.id),
                              onTap: () {
                                context.read<MapViewCubit>().selectListing(listing);
                              },
                            ),
                          );
                        }).toList(),
                        builder: (context, markers) {
                           // Calculate count and avg
                           // Getting markers list, but they are generic Markers. 
                           // For average price we need listing data. 
                           // Simplification: Just count for now as extracting data from Widget Markers is hard unless we map.
                           // Actually we can map by point lookup or passing data-rich markers if package supported.
                           // For now just show Count.
                           return ClusterMarker(
                             count: markers.length,
                             onTap: () {
                               // Zoom to cluster handled by package by default usually?
                               // Default behavior is zoom.
                             },
                           );
                        },
                      ),
                    ),
                  ],
                ),

                // Floating UI Layer
                SafeArea(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                        child: FloatingSearchBar(
                          onSearchChanged: (val) {
                             // Implement search logic if needed or pass to Cubit
                             context.read<MapViewCubit>().setSearchQuery(val);
                          },
                          onFilterTap: () {
                            widget.onShowFilters();
                          },
                        ),
                      ),
                      
                      SizedBox(
                        height: 50,
                        child: QuickFilterChips(
                          isClosestActive: state.isClosestToMeActive,
                          isCheapestActive: state.isCheapestActive,
                          onClosestTap: () => context.read<MapViewCubit>().toggleClosestToMe(),
                          onCheapestTap: () => context.read<MapViewCubit>().toggleCheapest(),
                          onFilterTap: (filter) {
                             // Handle standard filters
                          },
                        ),
                      ),
                    ],
                  ),
                ),

                // Map/List Toggle (Optional, if we want to keep it consistent with plan)
                // Positioned(bottom: 20, left: 0, right: 0, ...)
              ],
            ),
          );
        },
      ),
    );
  }

  // Smart Filter Logic
  List<ListingEntity> _processListings(List<ListingEntity> listings, MapViewState state) {
    if (listings.isEmpty) return [];

    List<ListingEntity> filtered = List.from(listings);

    // 1. Text Search filtering (local)
    if (state.searchQuery != null && state.searchQuery!.isNotEmpty) {
      final q = state.searchQuery!.toLowerCase();
      filtered = filtered.where((l) => 
        l.locationName.toLowerCase().contains(q) || 
        l.city.toLowerCase().contains(q) ||
        l.title.toLowerCase().contains(q)
      ).toList();
    }

    // 2. Sorting (Closest / Cheapest)
    // Note: To sort by distance we need current location.
    // For now we use Map Center or Nairobi default if not provided, or better: async location?
    // Sorting inside Build is synchronous. We can't wait for location here.
    // Ideally user location should be in State.
    // Assuming for now simple sorting if we had location in Cubit.
    // Since we don't hold user location strictly yet in this simple Cubit, we'll skip precise distance sort 
    // OR we assume (0,0) or check if we can get it.
    
    // For "Cheapest":
    if (state.isCheapestActive && !state.isClosestToMeActive) {
       filtered.sort((a, b) => a.priceAmount.compareTo(b.priceAmount));
    }
    
    // For "Combined":
    /*
    if (state.isCheapestActive && state.isClosestToMeActive) {
       // logic...
    }
    */
    
    return filtered;
  }
}

