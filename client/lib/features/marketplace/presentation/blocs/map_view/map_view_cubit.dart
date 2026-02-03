import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:latlong2/latlong.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:client/features/marketplace/domain/listing_entity.dart';
import 'package:client/features/profile/domain/life_pin_model.dart';
import 'map_view_state.dart';

class MapViewCubit extends Cubit<MapViewState> {
  MapViewCubit() : super(const MapViewState()) {
    _loadViewedListings();
  }

  Future<void> _loadViewedListings() async {
    final prefs = await SharedPreferences.getInstance();
    final viewed = prefs.getStringList('viewed_listings') ?? [];
    emit(state.copyWith(viewedListingIds: viewed.toSet()));
  }

  Future<void> markAsViewed(String listingId) async {
    if (state.viewedListingIds.contains(listingId)) return;
    
    final newSet = Set<String>.from(state.viewedListingIds)..add(listingId);
    emit(state.copyWith(viewedListingIds: newSet));
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('viewed_listings', newSet.toList());
  }

  void selectListing(ListingEntity listing) {
    if (state.selectedListing?.id != listing.id) {
      markAsViewed(listing.id);
      emit(state.copyWith(
        selectedListing: listing,
        isBottomSheetOpen: true,
      ));
    }
  }

  void closeBottomSheet() {
    emit(state.copyWith(
      isBottomSheetOpen: false,
      selectedListing: null,
    ));
  }

  void updateMapCenter(LatLng center, double zoom) {
    emit(state.copyWith(mapCenter: center, zoom: zoom));
  }
  
  void setVisibleLifePins(List<LifePin> pins) {
    emit(state.copyWith(visibleLifePins: pins));
  }
  
  void toggleClosestToMe() {
    final newValue = !state.isClosestToMeActive;
    emit(state.copyWith(
      isClosestToMeActive: newValue,
      // If turning on closest, maybe turn off cheapest to avoid confusion, or allow combo?
      // User asked for combination "closest AND cheapest", so allow both.
    ));
  }
  
  void toggleCheapest() {
    emit(state.copyWith(isCheapestActive: !state.isCheapestActive));
  }
  
  void setSearchQuery(String query) {
    emit(state.copyWith(searchQuery: query));
  }

  void clearFilters() {
    emit(state.copyWith(
      isClosestToMeActive: false,
      isCheapestActive: false,
      searchQuery: null,
    ));
  }
}
