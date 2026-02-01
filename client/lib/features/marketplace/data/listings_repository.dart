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
      var query = _supabase.from('properties').select('*, owner:owner_id(first_name, last_name, profile_picture)');

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

  Stream<List<ListingEntity>> getListingsStream() {
    return _supabase
        .from('properties')
        .stream(primaryKey: ['id'])
        .map((data) {
          final List<ListingEntity> listings = data
              .map((json) => ListingModel.fromJson(json))
              .toList();
          
          listings.sort((a, b) => b.createdAt.compareTo(a.createdAt));
          return listings;
        });
  }

  Future<ListingEntity> fetchListingById(String id) async {
    try {
      final response = await _supabase
          .from('properties')
          .select('*, owner:owner_id(first_name, last_name, profile_picture)')
          .eq('id', id)
          .single();
      
      return ListingModel.fromJson(response);
    } catch (e) {
      print('Error fetching listing $id: $e');
      throw Exception('Failed to load listing details');
    }
  }

  Future<void> toggleSaveListing(String propertyId, bool isSaved) async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) throw Exception('Must be logged in to save listings');

    try {
      if (isSaved) {
        await _supabase.from('saved_listings').delete().match({
          'user_id': userId,
          'property_id': propertyId,
        });
      } else {
        await _supabase.from('saved_listings').insert({
          'user_id': userId,
          'property_id': propertyId,
        });
      }
    } catch (e) {
      throw Exception('Failed to update saved status');
    }
  }

  Future<bool> isListingSaved(String propertyId) async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return false;

    try {
      final response = await _supabase
          .from('saved_listings')
          .select()
          .eq('user_id', userId)
          .eq('property_id', propertyId)
          .maybeSingle();
      
      return response != null;
    } catch (e) {
      return false;
    }
  }

  Future<List<ListingEntity>> fetchSavedListings() async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return [];

    try {
      final response = await _supabase
          .from('saved_listings')
          .select('properties(*, owner:owner_id(first_name, last_name, profile_picture))')
          .eq('user_id', userId);
      
      final data = response as List<dynamic>;
      return data
          .where((json) => json['properties'] != null)
          .map((json) => ListingModel.fromJson(json['properties']))
          .toList();
    } catch (e) {
      print('Error fetching saved listings: $e');
      return [];
    }
  }
}
