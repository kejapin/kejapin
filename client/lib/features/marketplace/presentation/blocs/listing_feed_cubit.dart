import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/listings_repository.dart';
import '../../domain/listing_entity.dart';

// States
abstract class ListingFeedState {}

class ListingFeedInitial extends ListingFeedState {}

class ListingFeedLoading extends ListingFeedState {}

class ListingFeedLoaded extends ListingFeedState {
  final List<ListingEntity> listings;
  ListingFeedLoaded(this.listings);
}

class ListingFeedError extends ListingFeedState {
  final String message;
  ListingFeedError(this.message);
}

// Cubit
class ListingFeedCubit extends Cubit<ListingFeedState> {
  final ListingsRepository _repository;
  StreamSubscription? _subscription;

  ListingFeedCubit(this._repository) : super(ListingFeedInitial());

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }

  Future<void> loadListings({
    String? propertyType,
    bool isRefresh = false,
    String? searchQuery,
    Map<String, dynamic>? filters,
  }) async {
    // Cancel existing real-time subscription when changing filters/fetching manually
    _subscription?.cancel();

    if (!isRefresh) {
      emit(ListingFeedLoading());
    }

    try {
      // If viewing "All" with no specific search/filters, use real-time stream
      if ((propertyType == null || propertyType == 'All') && 
          (searchQuery == null || searchQuery.isEmpty) && 
          (filters == null || filters.isEmpty)) {
        
        _subscription = _repository.getListingsStream().listen((listings) {
          emit(ListingFeedLoaded(listings));
        }, onError: (e) {
          emit(ListingFeedError(e.toString()));
        });
      } else {
        // Otherwise, do a one-time fetch (Supabase stream is limited for complex filters)
        final listings = await _repository.fetchListings(
          propertyType: propertyType,
          searchQuery: searchQuery,
          filters: filters,
        );
        emit(ListingFeedLoaded(listings));
      }
    } catch (e) {
      emit(ListingFeedError(e.toString()));
    }
  }
}
