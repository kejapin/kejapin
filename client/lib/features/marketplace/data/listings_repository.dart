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
        // Simple search on title or description using ilike
        // query = query.or('title.ilike.%$searchQuery%,description.ilike.%$searchQuery%');
        query = query.ilike('title', '%$searchQuery%'); // PostgREST has limitations on OR across columns in simpler syntax often
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
        // Amenities filtering would require array column support or specific logic
        // For now, we'll skip complex array filtering unless using specific PG operators
      }
      
      // Order by latest
      query = query.order('created_at', ascending: false);

      final response = await query;
      
      final data = response as List<dynamic>;
      return data.map((json) => ListingModel.fromJson(json)).toList();
    } catch (e) {
      print('Error fetching listings: $e');
      throw Exception('Supabase error: $e');
    }
  }
}
