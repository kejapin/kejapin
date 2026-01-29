import '../domain/listing_entity.dart';

class ListingModel extends ListingEntity {
  ListingModel({
    required super.id,
    required super.title,
    required super.description,
    required super.propertyType,
    required super.listingType,
    required super.priceAmount,
    required super.locationName,
    required super.latitude,
    required super.longitude,
    required super.photos,
    required super.bedrooms,
    required super.bathrooms,
  });

  factory ListingModel.fromJson(Map<String, dynamic> json) {
    // Helper to parse photos which might come as a single string or list
    List<String> parsePhotos(dynamic photosData) {
      if (photosData == null) return [];
      
      if (photosData is List) {
        return List<String>.from(photosData.map((e) => e.toString()));
      } else if (photosData is String && photosData.isNotEmpty) {
        // If it's a comma-separated string or just a URL
        if (photosData.contains(',')) {
          return photosData.split(',').map((e) => e.trim()).toList();
        }
        // Basic validation to check if it looks like a URL
        if (photosData.startsWith('http')) {
           return [photosData];
        }
      }
      return [];
    }

    return ListingModel(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      propertyType: json['property_type'] ?? '',
      listingType: json['listing_type'] ?? 'RENT',
      priceAmount: (json['price_amount'] as num?)?.toDouble() ?? 0.0,
      locationName: '${json['address_line_1'] ?? ''}, ${json['city'] ?? ''}', // Better location format
      latitude: (json['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 0.0,
      photos: parsePhotos(json['photos']),
      bedrooms: json['bedrooms'] ?? 0,
      bathrooms: json['bathrooms'] ?? 0,
    );
  }
}
