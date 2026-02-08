import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_cache/flutter_map_cache.dart';
import 'package:dio_cache_interceptor_file_store/dio_cache_interceptor_file_store.dart';
import 'package:path_provider/path_provider.dart';
import '../constants/api_endpoints.dart';
import 'dart:io';

class MapService {
  static Future<TileProvider> getCachedTileProvider() async {
    final cacheDirectory = await getTemporaryDirectory();
    final cachePath = '${cacheDirectory.path}/map_tiles';
    
    // Ensure the directory exists
    final dir = Directory(cachePath);
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }

    final provider = CachedTileProvider(
      store: FileCacheStore(cachePath),
    );
    
    provider.headers.addAll({
      'User-Agent': ApiEndpoints.osmUserAgent,
      'Referer': 'https://kejapin.com',
    });

    return provider;
  }
}
