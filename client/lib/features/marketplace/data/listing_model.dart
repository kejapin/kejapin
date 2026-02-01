import 'dart:math';
import 'dart:convert';
import '../domain/listing_entity.dart';

class ListingModel extends ListingEntity {
  ListingModel({
    required super.id,
    required super.title,
    required super.description,
    required super.propertyType,
    required super.listingType,
    required super.priceAmount,
    super.purchasePrice,
    super.rentPeriod = 'MONTHLY',
    super.isForRent = true,
    super.isForSale = false,
    required super.locationName,
    required super.city,
    required super.county,
    required super.latitude,
    required super.longitude,
    required super.photos,
    required super.amenities,
    required super.bedrooms,
    required super.bathrooms,
    required super.ownerId,
    required super.ownerName,
    super.ownerAvatar,
    super.sqft,
    super.rating = 4.5,
    super.reviewCount = 12,
    required super.createdAt,
    super.infrastructureStats,
  });

  factory ListingModel.fromJson(Map<String, dynamic> json) {
    final owner = json['owner'] as Map<String, dynamic>? ?? {};
    final ownerFirstName = owner['first_name'] ?? 'Landlord';
    final ownerLastName = owner['last_name'] ?? '';

    List<String> parsePhotos(dynamic photosData) {
      if (photosData == null) return [];
      if (photosData is List) {
        return List<String>.from(photosData.map((e) => e.toString()));
      } else if (photosData is String && photosData.isNotEmpty) {
        if (photosData.contains(',')) {
          return photosData.split(',').map((e) => e.trim()).toList();
        }
        if (photosData.startsWith('http')) return [photosData];
      }
      return [];
    }

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

    // Parse infrastructure stats from JSONB or String
    Map<String, dynamic> infraData = {};
    final rawInfra = json['efficiency_stats'];
    if (rawInfra is Map<String, dynamic>) {
      infraData = rawInfra;
    } else if (rawInfra is String && rawInfra.isNotEmpty) {
      try {
        infraData = jsonDecode(rawInfra) as Map<String, dynamic>;
      } catch (_) {}
    }

    final Map<String, double> infraStats = infraData.map(
      (key, value) => MapEntry(key, (value as num).toDouble()),
    );

    // Seed variety in rating if null
    final double baseRating = (json['rating'] as num?)?.toDouble() ?? 4.2;
    final double seededRating = json['rating'] == null 
        ? (baseRating + (Random(json['id'].hashCode).nextDouble() * 0.7)).clamp(3.8, 5.0)
        : baseRating;
        
    final int baseReviews = (json['review_count'] as num?)?.toInt() ?? 8;
    final int seededReviews = json['review_count'] == null
        ? baseReviews + Random(json['id'].hashCode).nextInt(45)
        : baseReviews;

    return ListingModel(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      propertyType: json['property_type'] ?? '',
      listingType: json['listing_type'] ?? 'RENT',
      priceAmount: (json['price_amount'] as num?)?.toDouble() ?? 0.0,
      purchasePrice: (json['purchase_price'] as num?)?.toDouble(),
      rentPeriod: json['rent_period'] ?? 'MONTHLY',
      isForRent: json['is_for_rent'] ?? (json['listing_type'] == 'RENT'),
      isForSale: json['is_for_sale'] ?? (json['listing_type'] == 'SALE'),
      locationName: '${json['address_line_1'] ?? ''}, ${json['city'] ?? ''}',
      city: json['city'] ?? '',
      county: json['county'] ?? '',
      latitude: (json['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 0.0,
      photos: parsePhotos(json['photos']),
      amenities: parseAmenities(json['amenities']),
      bedrooms: json['bedrooms'] ?? 0,
      bathrooms: json['bathrooms'] ?? 0,
      ownerId: json['owner_id'] ?? '',
      ownerName: '$ownerFirstName $ownerLastName'.trim(),
      ownerAvatar: owner['profile_picture'],
      sqft: json['sqft'] ?? (json['bedrooms'] != null ? json['bedrooms'] * 450 + 200 : null),
      rating: seededRating,
      reviewCount: seededReviews,
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at']) 
          : DateTime.now(),
      infrastructureStats: infraStats,
    );
  }
}
