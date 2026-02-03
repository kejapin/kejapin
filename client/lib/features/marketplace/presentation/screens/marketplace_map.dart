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
import '../../domain/listing_entity.dart';
import '../../../profile/domain/life_pin_model.dart';
import '../../../profile/data/life_pin_repository.dart';

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
  final LifePinRepository _lifePinRepo = LifePinRepository();
  
  double _currentZoom = 13.0;
  LatLng? _userLocation;
  List<LifePin> _lifePins = [];
  ListingEntity? _lastSelectedListing; // Track for re-centering on dismiss

  @override
  void initState() {
    super.initState();
    _fetchLocation();
    _fetchLifePins();
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

  Future<void> _fetchLifePins() async {
    try {
      final pins = await _lifePinRepo.getLifePins();
      if (mounted) {
        setState(() {
          _lifePins = pins;
        });
      }
    } catch (e) {
      debugPrint("Life Pins error: $e");
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

        // Handle Listing Selection (Modal Open)
        if (state.selectedListing != null) {
          _lastSelectedListing = state.selectedListing;
          _panelController.open();
          
          // Center pin in TOP HALF of visible area (above sheet)
          // Sheet takes 60% from bottom. Visible area is top 40%.
          // We want pin centered in that top 40%, which is at 20% from top of screen.
          final pin = LatLng(state.selectedListing!.latitude, state.selectedListing!.longitude);
          
          _mapController.fitCamera(
            CameraFit.coordinates(
              coordinates: [pin],
              padding: EdgeInsets.only(
                bottom: screenHeight * 0.5, // Push content up
                top: screenHeight * 0.1, // Some top padding
                left: 20,
                right: 20,
              ),
              maxZoom: _currentZoom < 14 ? 15.0 : _currentZoom.clamp(14.0, 17.0),
            ),
          );
        } else if (_lastSelectedListing != null) {
           // Modal dismissed - re-center the pin normally (lines will disappear via rebuild)
           final pin = LatLng(_lastSelectedListing!.latitude, _lastSelectedListing!.longitude);
           _mapController.move(pin, _currentZoom < 14 ? 14.0 : _currentZoom);
           _lastSelectedListing = null;
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
                    
                    // Polylines Layer (Only when selected)
                    if (state.selectedListing != null)
                      PolylineLayer(
                        polylines: [
                          // Line from user to listing
                          if (_userLocation != null)
                            Polyline(
                              points: [
                                _userLocation!,
                                LatLng(state.selectedListing!.latitude, state.selectedListing!.longitude)
                              ],
                              color: AppColors.structuralBrown,
                              strokeWidth: 3.0,
                            ),
                          
                          // Lines from listing to each Life Pin
                          ..._lifePins.map((pin) {
                            return Polyline(
                              points: [
                                LatLng(state.selectedListing!.latitude, state.selectedListing!.longitude),
                                LatLng(pin.latitude, pin.longitude),
                              ],
                              color: _getColorForLifePin(pin.label),
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
                    
                    // Life Pin Markers (Only when listing selected)
                    if (state.selectedListing != null && _lifePins.isNotEmpty)
                      MarkerLayer(
                        markers: _lifePins.map((pin) {
                          return Marker(
                            point: LatLng(pin.latitude, pin.longitude),
                            width: 30,
                            height: 30,
                            child: Container(
                              decoration: BoxDecoration(
                                color: _getColorForLifePin(pin.label),
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.white, width: 2),
                                boxShadow: const [BoxShadow(blurRadius: 4, color: Colors.black26)],
                              ),
                              child: Icon(
                                _getIconForLifePin(pin.label),
                                color: Colors.white,
                                size: 14,
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
                      
                      // Reset Filters Button (only show if any filter is active)
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
  
  Color _getColorForLifePin(String label) {
    final lower = label.toLowerCase();
    if (lower.contains('work') || lower.contains('office')) return Colors.blue;
    if (lower.contains('school') || lower.contains('university')) return Colors.purple;
    if (lower.contains('gym') || lower.contains('fitness')) return Colors.orange;
    if (lower.contains('home')) return AppColors.sageGreen;
    return AppColors.mutedGold;
  }

  IconData _getIconForLifePin(String label) {
    final lower = label.toLowerCase();
    if (lower.contains('work') || lower.contains('office')) return Icons.work;
    if (lower.contains('school') || lower.contains('university')) return Icons.school;
    if (lower.contains('gym') || lower.contains('fitness')) return Icons.fitness_center;
    if (lower.contains('home')) return Icons.home;
    return Icons.place;
  }
}

