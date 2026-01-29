import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/models/search_result.dart';
import '../../data/repositories/search_repository.dart';

// Events
abstract class SearchEvent {}

class SearchQueryChanged extends SearchEvent {
  final String query;
  SearchQueryChanged(this.query);
}

class SearchMarketplaceQueryChanged extends SearchEvent {
  final String query;
  SearchMarketplaceQueryChanged(this.query);
}

class SearchClear extends SearchEvent {}

// States
abstract class SearchState {}

class SearchInitial extends SearchState {}

class SearchLoading extends SearchState {}

class SearchLoaded extends SearchState {
  final List<SearchResult> results;
  final bool isUniversal; // true if showing all types, false if filtered

  SearchLoaded(this.results, {this.isUniversal = true});
  
  // Helper to get grouped results
  Map<SearchResultType, List<SearchResult>> get groupedResults {
    final map = <SearchResultType, List<SearchResult>>{};
    for (var result in results) {
      if (!map.containsKey(result.type)) {
        map[result.type] = [];
      }
      map[result.type]!.add(result);
    }
    return map;
  }
}

class SearchError extends SearchState {
  final String message;
  SearchError(this.message);
}

// Bloc
class SearchBloc extends Bloc<SearchEvent, SearchState> {
  final SearchRepository _repository;

  SearchBloc(this._repository) : super(SearchInitial()) {
    on<SearchQueryChanged>(_onQueryChanged);
    on<SearchMarketplaceQueryChanged>(_onMarketplaceQueryChanged);
    on<SearchClear>(_onClear);
  }

  Future<void> _onQueryChanged(SearchQueryChanged event, Emitter<SearchState> emit) async {
    if (event.query.isEmpty) {
      emit(SearchInitial());
      return;
    }

    emit(SearchLoading());

    try {
      final results = await _repository.searchUniversal(event.query);
      emit(SearchLoaded(results));
    } catch (e) {
      emit(SearchError("Failed to search: $e"));
    }
  }

  Future<void> _onMarketplaceQueryChanged(SearchMarketplaceQueryChanged event, Emitter<SearchState> emit) async {
    if (event.query.isEmpty) {
      emit(SearchInitial());
      return;
    }

    emit(SearchLoading());

    try {
      // Use the repository method
      final results = await _repository.searchMarketplace(event.query);
      emit(SearchLoaded(results, isUniversal: false));
    } catch (e) {
      emit(SearchError("Failed to search: $e"));
    }
  }

  void _onClear(SearchClear event, Emitter<SearchState> emit) {
    emit(SearchInitial());
  }
}
