import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseStorageService {
  final SupabaseClient _supabase = Supabase.instance.client;

  /// Uploads a file to a specified bucket and returns the public URL.
  Future<String> uploadFile({
    required String bucket,
    required File file,
    required String path,
  }) async {
    try {
      final String fullPath = await _supabase.storage.from(bucket).upload(
            path,
            file,
            fileOptions: const FileOptions(cacheControl: '3600', upsert: true),
          );

      // Convert the path to a public URL
      final String publicUrl = _supabase.storage.from(bucket).getPublicUrl(path);
      return publicUrl;
    } catch (e) {
      throw Exception('Upload failed: $e');
    }
  }

  /// Uploads multiple files and returns a list of public URLs.
  Future<List<String>> uploadMultipleFiles({
    required String bucket,
    required List<File> files,
    required String folder,
  }) async {
    List<String> urls = [];
    for (var i = 0; i < files.length; i++) {
      final String fileName = '${DateTime.now().millisecondsSinceEpoch}_$i.jpg';
      final String path = '$folder/$fileName';
      final url = await uploadFile(bucket: bucket, file: files[i], path: path);
      urls.add(url);
    }
    return urls;
  }
}
