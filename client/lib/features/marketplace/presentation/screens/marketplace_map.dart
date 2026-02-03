import 'package:animate_do/animate_do.dart';
import 'package:client/features/marketplace/presentation/blocs/map_view/map_view_cubit.dart';
import 'package:client/features/marketplace/presentation/blocs/map_view/map_view_state.dart';
import 'package:client/features/marketplace/presentation/widgets/map/cluster_marker.dart';
import 'package:client/features/marketplace/presentation/widgets/map/floating_search_bar.dart';
import 'package:client/features/marketplace/presentation/widgets/map/price_pill_marker.dart';
import 'package:client/features/marketplace/presentation/widgets/map/small_card_marker.dart';
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
import '../../../../core/services/geo_service.dart';
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
  
  double _currentZoom = 13.0;
  LatLng? _userLocation;
  Map<String, NearbyAmenity> _nearbyAmenities = {};
  ListingEntity? _lastSelectedListing;

  @override
  void initState() {
    super.initState();
    _fetchLocation();
  }

  Future<void> _fetchLocation() async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      
      if (permission == LocationPermission.whileInUse || permission == LocationPermission.always) {
        final pos = await Geolocator.getCurrentPosition();
        if (mounted) {
          setState(() {
            _userLocation = LatLng(pos.latitude, pos.longitude);
          });
        }
      }
    } catch (e) {
      debugPrint("Location error: $e");
    }
  }

  Future<void> _fetchNearbyAmenities(ListingEntity listing) async {
    try {
      final amenities = await GeoService.getNearbyAmenities(
        latitude: listing.latitude,
        longitude: listing.longitude,
        radiusMeters: 1500,
      );
      
      if (mounted) {
        setState(() {
          _nearbyAmenities = amenities;
        });
      }
    } catch (e) {
      debugPrint("Amenities fetch error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<MapViewCubit>();
    final screenHeight = MediaQuery.of(context).size.height;

    return BlocListener<MapViewCubit, MapViewState>(
      listenWhen: (previous, current) {
         return previous.selectedListing != current.selectedListing ||
                previous.isClosestToMeActive != current.isClosestToMeActive;
      },
      listener: (context, state) async {
        // Handle Closest To Me Activation
        if (state.isClosestToMeActive && !state.isBottomSheetOpen) {
           _handleClosestToMe(state);
        }

        // Handle Listing Selection
        if (state.selectedListing != null) {
          _lastSelectedListing = state.selectedListing;
          _panelController.open();
          
          // Fetch nearby amenities for this listing
          await _fetchNearbyAmenities(state.selectedListing!);
          
          // Center pin in visible area
          final pin = LatLng(state.selectedListing!.latitude, state.selectedListing!.longitude);
          
          _mapController.fitCamera(
            CameraFit.coordinates(
              coordinates: [pin],
              padding: EdgeInsets.only(
                bottom: screenHeight * 0.5,
                top: screenHeight * 0.1,
                left: 20,
                right: 20,
              ),
              maxZoom: _currentZoom < 14 ? 15.0 : _currentZoom.clamp(14.0, 17.0),
            ),
          );
        } else if (_lastSelectedListing != null) {
           // Modal dismissed - re-center and clear amenities
           final pin = LatLng(_lastSelectedListing!.latitude, _lastSelectedListing!.longitude);
           _mapController.move(pin, _currentZoom < 14 ? 14.0 : _currentZoom);
           _lastSelectedListing = null;
           setState(() {
             _nearbyAmenities = {};
           });
           _panelController.close();
        }
      },
      child: BlocBuilder<MapViewCubit, MapViewState>(
        builder: (context, state) {
          final displayListings = _processListings(widget.listings, state);

          return SlidingUpPanel(
            controller: _panelController,
            minHeight: 0, 
            maxHeight: screenHeight * 0.6,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            parallaxEnabled: true,
            parallaxOffset: 0.5,
            backdropEnabled: false,
            
            panelBuilder: (scrollController) {
              if (state.selectedListing == null) return const SizedBox.shrink();
              return PropertyBottomSheetContent(
                listing: state.selectedListing!,
                scrollController: scrollController,
                onChatTap: () {
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
              cubit.closeBottomSheet();
            },

            body: Stack(
              children: [
                FlutterMap(
                  mapController: _mapController,
                  options: MapOptions(
                    initialCenter: const LatLng(-1.2921, 36.8219),
                    initialZoom: 13.0,
                    onPositionChanged: (pos, _) {
                       if (pos.zoom != null && pos.zoom != _currentZoom) {
                          setState(() => _currentZoom = pos.zoom!);
                       }
                    },
                    onTap: (_, __) {
                      cubit.closeBottomSheet();
                    },
                  ),
                  children: [
                    TileLayer(
                      urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'com.kejapin.client',
                    ),
                    
                    // Polylines Layer - Lines to amenities
                    if (state.selectedListing != null && _nearbyAmenities.isNotEmpty)
                      PolylineLayer(
                        polylines: [
                          // Line from user to listing (main connection)
                          if (_userLocation != null)
                            Polyline(
                              points: [
                                _userLocation!,
                                LatLng(state.selectedListing!.latitude, state.selectedListing!.longitude)
                              ],
                              color: AppColors.structuralBrown,
                              strokeWidth: 3.0,
                            ),
                          
                          // Lines from listing to each nearby amenity
                          ..._nearbyAmenities.entries.map((entry) {
                            final amenity = entry.value;
                            return Polyline(
                              points: [
                                LatLng(state.selectedListing!.latitude, state.selectedListing!.longitude),
                                amenity.position,
                              ],
                              color: _getColorForAmenityType(entry.key).withOpacity(0.6),
                              strokeWidth: 2.0,
                            );
                          }).toList(),
                        ],
                      ),
                    
                    // User Location Marker
                    if (_userLocation != null)
                      MarkerLayer(
                        markers: [
                          Marker(
                            point: _userLocation!,
                            width: 24,
                            height: 24,
                            child: Container(
                              decoration: BoxDecoration(
                                color: AppColors.sageGreen,
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.white, width: 2),
                                boxShadow: const [BoxShadow(blurRadius: 5, color: Colors.black26)],
                              ),
                              child: const Icon(Icons.person, color: Colors.white, size: 12),
                            ),
                          ),
                        ],
                      ),
                    
                    // Amenity Markers (only when listing selected)
                    if (state.selectedListing != null && _nearbyAmenities.isNotEmpty)
                      MarkerLayer(
                        markers: _nearbyAmenities.entries.map((entry) {
                          final amenity = entry.value;
                          return Marker(
                            point: amenity.position,
                            width: 32,
                            height: 32,
                            child: FadeIn(
                              duration: const Duration(milliseconds: 400),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: _getColorForAmenityType(entry.key),
                                  shape: BoxShape.circle,
                                  border: Border.all(color: Colors.white, width: 2.5),
                                  boxShadow: [
                                    BoxShadow(
                                      color: _getColorForAmenityType(entry.key).withOpacity(0.4),
                                      blurRadius: 6,
                                      spreadRadius: 2,
                                    )
                                  ],
                                ),
                                child: Icon(
                                  _getIconForAmenityType(entry.key),
                                  color: Colors.white,
                                  size: 16,
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    
                    // Property Markers Layer
                    MarkerClusterLayerWidget(
                      options: MarkerClusterLayerOptions(
                        maxClusterRadius: 100,
                        size: const Size(100, 60),
                        alignment: Alignment.center,
                        padding: const EdgeInsets.all(50),
                        markers: displayListings.map((listing) {
                          return Marker(
                            point: LatLng(listing.latitude, listing.longitude),
                            width: _currentZoom > 15.5 ? 160 : 80,
                            height: _currentZoom > 15.5 ? 70 : 40,
                            child: _buildProgressiveMarker(listing, state),
                          );
                        }).toList(),
                        builder: (context, markers) {
                           return ClusterMarker(
                             count: markers.length,
                             onTap: () {},
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
                             cubit.setSearchQuery(val);
                          },
                          onFilterTap: widget.onShowFilters,
                        ),
                      ),
                      
                      SizedBox(
                        height: 50,
                        child: QuickFilterChips(
                          isClosestActive: state.isClosestToMeActive,
                          isCheapestActive: state.isCheapestActive,
                          onClosestTap: () => cubit.toggleClosestToMe(),
                          onCheapestTap: () => cubit.toggleCheapest(),
                          onFilterTap: (filter) {
                             widget.onShowFilters();
                          },
                        ),
                      ),
                      
                      // Reset Filters Button
                      if (state.isClosestToMeActive || state.isCheapestActive || 
                          (state.searchQuery != null && state.searchQuery!.isNotEmpty))
                        Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: GestureDetector(
                            onTap: () => cubit.clearFilters(),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    blurRadius: 4,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.clear, size: 14, color: AppColors.structuralBrown),
                                  const SizedBox(width: 4),
                                  Text(
                                    'Clear Filters',
                                    style: TextStyle(
                                      color: AppColors.structuralBrown,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
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
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildProgressiveMarker(ListingEntity listing, MapViewState state) {
    if (_currentZoom < 12.0) {
      return GestureDetector(
        onTap: () => context.read<MapViewCubit>().selectListing(listing),
        child: Container(
          decoration: BoxDecoration(
             color: AppColors.mutedGold,
             shape: BoxShape.circle,
             border: Border.all(color: Colors.white, width: 2),
             boxShadow: const [BoxShadow(blurRadius: 3, color: Colors.black26)],
          ),
          width: 15,
          height: 15,
        ),
      );
    }
    
    if (_currentZoom > 15.5) {
      return SmallCardMarker(
        listing: listing,
        isSelected: state.selectedListing?.id == listing.id,
        onTap: () => context.read<MapViewCubit>().selectListing(listing),
      );
    }

    return PricePillMarker(
      price: 'KSh ${(listing.priceAmount / 1000).toStringAsFixed(0)}k',
      isSelected: state.selectedListing?.id == listing.id,
      isViewed: state.viewedListingIds.contains(listing.id),
      onTap: () {
        context.read<MapViewCubit>().selectListing(listing);
      },
    );
  }

  void _handleClosestToMe(MapViewState state) {
     if (_userLocation == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Getting your location...')),
        );
        return;
     }
     
     ListingEntity? closest;
     double minDistance = double.infinity;
     
     final candidates = _processListings(widget.listings, state);
     if (candidates.isEmpty) return;
     
     for (var listing in candidates) {
        final d = Geolocator.distanceBetween(
           _userLocation!.latitude, _userLocation!.longitude, 
           listing.latitude, listing.longitude
        );
        if (d < minDistance) {
           minDistance = d;
           closest = listing;
        }
     }
     
     if (closest != null) {
        context.read<MapViewCubit>().selectListing(closest);
     }
  }

  List<ListingEntity> _processListings(List<ListingEntity> listings, MapViewState state) {
    if (listings.isEmpty) return [];

    List<ListingEntity> filtered = List.from(listings);

    // Text Search
    if (state.searchQuery != null && state.searchQuery!.isNotEmpty) {
      final q = state.searchQuery!.toLowerCase();
      filtered = filtered.where((l) => 
        l.locationName.toLowerCase().contains(q) || 
        l.city.toLowerCase().contains(q) ||
        l.title.toLowerCase().contains(q)
      ).toList();
    }

    // Sorting
    if (state.isCheapestActive && !state.isClosestToMeActive) {
       filtered.sort((a, b) => a.priceAmount.compareTo(b.priceAmount));
    } else if (state.isClosestToMeActive && _userLocation != null) {
       filtered.sort((a, b) {
          final da = Geolocator.distanceBetween(_userLocation!.latitude, _userLocation!.longitude, a.latitude, a.longitude);
          final db = Geolocator.distanceBetween(_userLocation!.latitude, _userLocation!.longitude, b.latitude, b.longitude);
          return da.compareTo(db);
       });
    } else if (state.isClosestToMeActive && state.isCheapestActive && _userLocation != null) {
          filtered.sort((a, b) {
            final da = Geolocator.distanceBetween(_userLocation!.latitude, _userLocation!.longitude, a.latitude, a.longitude);
            final db = Geolocator.distanceBetween(_userLocation!.latitude, _userLocation!.longitude, b.latitude, b.longitude);
            return da.compareTo(db);
         });
    }

    return filtered;
  }
  
  Color _getColorForAmenityType(String type) {
    switch (type) {
      case AmenityCategory.healthcare:
        return const Color(0xFFE53935); // Red
      case AmenityCategory.education:
        return const Color(0xFF7E57C2); // Purple
      case AmenityCategory.shopping:
        return const Color(0xFF26A69A); // Teal
      case AmenityCategory.parking:
        return const Color(0xFF5C6BC0); // Indigo
      case AmenityCategory.restaurant:
        return const Color(0xFFFF7043); // Deep Orange
      case AmenityCategory.bank:
        return const Color(0xFF66BB6A); // Green
      case AmenityCategory.public_transport:
        return const Color(0xFF42A5F5); // Blue
      case AmenityCategory.gym:
        return const Color(0xFFEC407A); // Pink
      case AmenityCategory.entertainment:
        return const Color(0xFFAB47BC); // Deep Purple
      case AmenityCategory.security:
        return const Color(0xFF8D6E63); // Brown
      default:
        return AppColors.mutedGold;
    }
  }

  IconData _getIconForAmenityType(String type) {
    switch (type) {
      case AmenityCategory.healthcare:
        return Icons.local_hospital;
      case AmenityCategory.education:
        return Icons.school;
      case AmenityCategory.shopping:
        return Icons.shopping_cart;
      case AmenityCategory.parking:
        return Icons.local_parking;
      case AmenityCategory.restaurant:
        return Icons.restaurant;
      case AmenityCategory.bank:
        return Icons.account_balance;
      case AmenityCategory.public_transport:
        return Icons.directions_bus;
      case AmenityCategory.gym:
        return Icons.fitness_center;
      case AmenityCategory.entertainment:
        return Icons.theaters;
      case AmenityCategory.security:
        return Icons.security;
      default:
        return Icons.place;
    }
  }
}

