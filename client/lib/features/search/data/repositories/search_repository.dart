import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/search_result.dart';

abstract class SearchRepository {
  Future<List<SearchResult>> searchUniversal(String query);
  Future<List<SearchResult>> searchListings(String query);
  Future<List<SearchResult>> searchLocations(String query);
  Future<List<SearchResult>> searchMarketplace(String query);
}

class SupabaseSearchRepository implements SearchRepository {
  final SupabaseClient _supabase = Supabase.instance.client;

  @override
  Future<List<SearchResult>> searchUniversal(String query) async {
    if (query.isEmpty) return [];

    try {
      // 1. Search Properties (Listings)
      final propertyResults = await _supabase
          .from('properties')
          .select()
          .ilike('title', '%$query%')
          .limit(5);

      final List<SearchResult> results = [];

      for (var p in (propertyResults as List)) {
        results.add(SearchResult(
          id: p['id'].toString(),
          title: p['title'],
          subtitle: '${p['city']}, ${p['county']}',
          type: SearchResultType.listing,
          imageUrl: (p['photos'] != null && (p['photos'] as List).isNotEmpty) 
              ? p['photos'][0] 
              : null,
          metadata: {'price': p['price_amount'], 'beds': p['bedrooms']},
        ));
      }

      // 2. Search Landlords (Users with role LANDLORD)
      final landlordResults = await _supabase
          .from('users')
          .select()
          .eq('role', 'LANDLORD')
          .ilike('first_name', '%$query%')
          .limit(3);
      
      for (var u in (landlordResults as List)) {
        results.add(SearchResult(
          id: u['id'].toString(),
          title: '${u['first_name']} ${u['last_name']}',
          subtitle: 'Verified Landlord',
          type: SearchResultType.landlord,
          imageUrl: u['profile_picture'],
        ));
      }

      return results;
    } catch (e) {
      print('Search error: $e');
      return [];
    }
  }

  @override
  Future<List<SearchResult>> searchListings(String query) async {
    final results = await searchUniversal(query);
    return results.where((r) => r.type == SearchResultType.listing).toList();
  }

  @override
  Future<List<SearchResult>> searchLocations(String query) async {
    // For now, we search properties and extract locations or use a geo-coding service
    // Simple implementation: filter location type results
    final results = await searchUniversal(query);
    return results.where((r) => r.type == SearchResultType.location).toList();
  }

  @override
  Future<List<SearchResult>> searchMarketplace(String query) async {
    final results = await searchUniversal(query);
    return results.where((r) => r.type == SearchResultType.listing || r.type == SearchResultType.location).toList();
  }
}

// Keep the mock for compatibility or testing if needed
class MockSearchRepository implements SearchRepository {
  // ... (previous implementation can be moved here or deleted)
  @override
  Future<List<SearchResult>> searchUniversal(String query) async => [];
  @override
  Future<List<SearchResult>> searchListings(String query) async => [];
  @override
  Future<List<SearchResult>> searchLocations(String query) async => [];
  @override
  Future<List<SearchResult>> searchMarketplace(String query) async => [];
}
