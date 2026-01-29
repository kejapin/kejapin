import 'package:supabase_flutter/supabase_flutter.dart';
import 'listing_model.dart';
import '../domain/listing_entity.dart';

class ListingsRepository {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<List<ListingEntity>> fetchListings({
    String? propertyType,
    String? searchQuery,
    Map<String, dynamic>? filters,
  }) async {
    try {
      var query = _supabase.from('properties').select();

      // Apply initial filters
      if (propertyType != null && propertyType != 'All') {
        query = query.eq('property_type', propertyType.toUpperCase());
      }

      if (searchQuery != null && searchQuery.isNotEmpty) {
        query = query.ilike('title', '%$searchQuery%');
      }

      if (filters != null) {
        if (filters['minPrice'] != null) {
          query = query.gte('price_amount', filters['minPrice']);
        }
        if (filters['maxPrice'] != null) {
          query = query.lte('price_amount', filters['maxPrice']);
        }
        if (filters['propertyTypes'] != null && (filters['propertyTypes'] as List).isNotEmpty) {
          query = query.inFilter('property_type', (filters['propertyTypes'] as List));
        }
      }
      
      final response = await query.order('created_at', ascending: false);
      
      final data = response as List<dynamic>;
      return data.map((json) => ListingModel.fromJson(json)).toList();
    } catch (e) {
      print('Error fetching listings: $e');
      throw Exception('Supabase error: $e');
    }
  }

  Future<ListingEntity> fetchListingById(String id) async {
    try {
      final response = await _supabase
          .from('properties')
          .select()
          .eq('id', id)
          .single();
      
      return ListingModel.fromJson(response);
    } catch (e) {
      print('Error fetching listing $id: $e');
      throw Exception('Failed to load listing details');
    }
  }
}
