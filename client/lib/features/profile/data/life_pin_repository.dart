import 'package:supabase_flutter/supabase_flutter.dart';
import '../domain/life_pin_model.dart';

class LifePinRepository {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<List<LifePin>> getLifePins() async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) throw Exception('User not logged in');

      // RLS will ensure we only get pins for the current user
      final response = await _supabase
          .from('life_pins')
          .select()
          .eq('user_id', user.id); // Although RLS handles it, adding explicit filter helps
      
      final data = response as List<dynamic>;
      return data.map((json) => LifePin.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to load life pins: $e');
    }
  }

  Future<void> createLifePin(LifePin pin) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) throw Exception('User not logged in');

      final pinData = pin.toJson();
      pinData['user_id'] = user.id; 
      if (pinData['id'] == null || pinData['id'].toString().isEmpty) {
        pinData.remove('id'); 
      }

      await _supabase.from('life_pins').insert(pinData);
    } catch (e) {
      throw Exception('Failed to create life pin: $e');
    }
  }

  Future<void> deleteLifePin(String id) async {
    try {
      await _supabase.from('life_pins').delete().eq('id', id);
    } catch (e) {
      throw Exception('Failed to delete life pin: $e');
    }
  }
}
