import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../../../core/constants/api_endpoints.dart';
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

      // 3. Search Locations (Via Go API -> Turso)
      final locationResults = await searchLocations(query);
      results.addAll(locationResults);

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
    if (query.isEmpty) return [];

    try {
      final response = await http.get(
        Uri.parse('${ApiEndpoints.locationSearch}?query=$query'),
      );

      if (response.statusCode == 200) {
        final List data = json.decode(response.body);
        return data.map((item) => SearchResult(
          id: item['id'].toString(),
          title: item['name'] ?? 'Unknown Location',
          subtitle: item['category'] ?? 'Location',
          type: SearchResultType.location,
          metadata: {
            'lat': item['lat'],
            'lon': item['lon'],
            'category': item['category'],
          },
        )).toList();
      }
      return [];
    } catch (e) {
      print('Location search error: $e');
      return [];
    }
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
