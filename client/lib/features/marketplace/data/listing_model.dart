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
    required super.city,
    required super.county,
    required super.latitude,
    required super.longitude,
    required super.photos,
    required super.amenities,
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
        if (photosData.contains(',')) {
          return photosData.split(',').map((e) => e.trim()).toList();
        }
        if (photosData.startsWith('http')) {
           return [photosData];
        }
      }
      return [];
    }

    // Helper to parse amenities
    List<String> parseAmenities(dynamic amenitiesData) {
      if (amenitiesData == null) return [];
      if (amenitiesData is List) {
        return List<String>.from(amenitiesData.map((e) => e.toString()));
      } else if (amenitiesData is String && amenitiesData.isNotEmpty) {
        if (amenitiesData.contains(',')) {
          return amenitiesData.split(',').map((e) => e.trim()).toList();
        }
        return [amenitiesData];
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
      locationName: '${json['address_line_1'] ?? ''}, ${json['city'] ?? ''}',
      city: json['city'] ?? '',
      county: json['county'] ?? '',
      latitude: (json['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 0.0,
      photos: parsePhotos(json['photos']),
      amenities: parseAmenities(json['amenities']),
      bedrooms: json['bedrooms'] ?? 0,
      bathrooms: json['bathrooms'] ?? 0,
    );
  }
}
