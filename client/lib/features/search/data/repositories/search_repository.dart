import '../models/search_result.dart';

abstract class SearchRepository {
  Future<List<SearchResult>> searchUniversal(String query);
  Future<List<SearchResult>> searchListings(String query);
  Future<List<SearchResult>> searchLocations(String query);
}

class MockSearchRepository implements SearchRepository {
  @override
  Future<List<SearchResult>> searchUniversal(String query) async {
    await Future.delayed(const Duration(milliseconds: 500)); // Simulate network delay
    
    if (query.isEmpty) return [];

    final lowerQuery = query.toLowerCase();
    
    // Mock Data
    final allResults = [
      // Listings
      SearchResult(
        id: '1',
        title: 'Modern Studio Apartment',
        subtitle: 'Westlands, Nairobi',
        type: SearchResultType.listing,
        imageUrl: 'https://images.unsplash.com/photo-1522708323590-d24dbb6b0267?ixlib=rb-4.0.3&auto=format&fit=crop&w=2340&q=80',
        metadata: {'price': 25000, 'beds': 1},
      ),
      SearchResult(
        id: '2',
        title: 'Luxury 2BR Penthouse',
        subtitle: 'Kilimani, Nairobi',
        type: SearchResultType.listing,
        imageUrl: 'https://images.unsplash.com/photo-1502672260266-1c1ef2d93688?ixlib=rb-4.0.3&auto=format&fit=crop&w=2340&q=80',
        metadata: {'price': 85000, 'beds': 2},
      ),
      
      // Landlords
      SearchResult(
        id: 'l1',
        title: 'John Doe',
        subtitle: 'Verified Landlord • 4.8 ★',
        type: SearchResultType.landlord,
        imageUrl: 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?ixlib=rb-4.0.3&auto=format&fit=crop&w=1000&q=80',
      ),
      SearchResult(
        id: 'l2',
        title: 'Alice Smith',
        subtitle: 'Super Host • 5.0 ★',
        type: SearchResultType.landlord,
        imageUrl: 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?ixlib=rb-4.0.3&auto=format&fit=crop&w=1000&q=80',
      ),

      // Locations
      SearchResult(
        id: 'loc1',
        title: 'Westlands',
        subtitle: 'Nairobi, Kenya',
        type: SearchResultType.location,
        metadata: {'lat': -1.2683, 'lng': 36.8111},
      ),
      SearchResult(
        id: 'loc2',
        title: 'Kilimani',
        subtitle: 'Nairobi, Kenya',
        type: SearchResultType.location,
        metadata: {'lat': -1.2921, 'lng': 36.7871},
      ),
    ];

    return allResults.where((result) {
      return result.title.toLowerCase().contains(lowerQuery) ||
             result.subtitle.toLowerCase().contains(lowerQuery);
    }).toList();
  }

  @override
  Future<List<SearchResult>> searchListings(String query) async {
    final results = await searchUniversal(query);
    return results.where((r) => r.type == SearchResultType.listing).toList();
  }

  @override
  Future<List<SearchResult>> searchLocations(String query) async {
    final results = await searchUniversal(query);
    return results.where((r) => r.type == SearchResultType.location || r.type == SearchResultType.coordinate).toList();
  }

  Future<List<SearchResult>> searchMarketplace(String query) async {
    final results = await searchUniversal(query);
    return results.where((r) => r.type == SearchResultType.listing || r.type == SearchResultType.location).toList();
  }
}
