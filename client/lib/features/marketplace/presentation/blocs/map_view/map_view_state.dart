import 'package:equatable/equatable.dart';
import '../../../../domain/listing_entity.dart';
import '../../../../profile/domain/life_pin_model.dart';
import 'package:latlong2/latlong.dart';

class MapViewState extends Equatable {
  final ListingEntity? selectedListing;
  final bool isBottomSheetOpen;
  final Set<String> viewedListingIds;
  final Map<String, dynamic> activeFilters;
  final LatLng? mapCenter; // For "closest to me" logic
  final double? zoom;
  final List<LifePin> visibleLifePins;
  // Smart filters state
  final bool isClosestToMeActive;
  final bool isCheapestActive;
  final String? searchQuery;

  const MapViewState({
    this.selectedListing,
    this.isBottomSheetOpen = false,
    this.viewedListingIds = const {},
    this.activeFilters = const {},
    this.mapCenter,
    this.zoom,
    this.visibleLifePins = const [],
    this.isClosestToMeActive = false,
    this.isCheapestActive = false,
    this.searchQuery,
  });

  MapViewState copyWith({
    ListingEntity? selectedListing,
    bool? isBottomSheetOpen,
    Set<String>? viewedListingIds,
    Map<String, dynamic>? activeFilters,
    LatLng? mapCenter,
    double? zoom,
    List<LifePin>? visibleLifePins,
    bool? isClosestToMeActive,
    bool? isCheapestActive,
    String? searchQuery,
  }) {
    return MapViewState(
      selectedListing: selectedListing ?? this.selectedListing,
      isBottomSheetOpen: isBottomSheetOpen ?? this.isBottomSheetOpen,
      viewedListingIds: viewedListingIds ?? this.viewedListingIds,
      activeFilters: activeFilters ?? this.activeFilters,
      mapCenter: mapCenter ?? this.mapCenter,
      zoom: zoom ?? this.zoom,
      visibleLifePins: visibleLifePins ?? this.visibleLifePins,
      isClosestToMeActive: isClosestToMeActive ?? this.isClosestToMeActive,
      isCheapestActive: isCheapestActive ?? this.isCheapestActive,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }

  @override
  List<Object?> get props => [
        selectedListing,
        isBottomSheetOpen,
        viewedListingIds,
        activeFilters,
        mapCenter,
        zoom,
        visibleLifePins,
        isClosestToMeActive,
        isCheapestActive,
        searchQuery,
      ];
}
