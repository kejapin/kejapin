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

  ListingFeedCubit(this._repository) : super(ListingFeedInitial());

  Future<void> loadListings({
    String? propertyType,
    bool isRefresh = false,
    String? searchQuery,
    Map<String, dynamic>? filters,
  }) async {
    if (!isRefresh) {
      emit(ListingFeedLoading());
    }
    try {
      final listings = await _repository.fetchListings(
        propertyType: propertyType,
        searchQuery: searchQuery,
        filters: filters,
      );
      emit(ListingFeedLoaded(listings));
    } catch (e) {
      emit(ListingFeedError(e.toString()));
    }
  }
}
