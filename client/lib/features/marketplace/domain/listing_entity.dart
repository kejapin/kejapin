class ListingEntity {
  final String id;
  final String title;
  final String description;
  final String propertyType;
  final String listingType;
  final double priceAmount;
  final double? purchasePrice;
  final String rentPeriod;
  final bool isForRent;
  final bool isForSale;
  final String locationName;
  final String city;
  final String county;
  final double latitude;
  final double longitude;
  final List<String> photos;
  final List<String> amenities;
  final int bedrooms;
  final int bathrooms;
  final String ownerId;
  final String ownerName;
  final String? ownerAvatar;
  final int? sqft;
  final double rating;
  final int reviewCount;
  final DateTime createdAt;
  final String status;
  
  // Real-world infrastructure stats from DB
  final Map<String, double> infrastructureStats;

  ListingEntity({
    required this.id,
    required this.title,
    required this.description,
    required this.propertyType,
    required this.listingType,
    required this.priceAmount,
    this.purchasePrice,
    this.rentPeriod = 'MONTHLY',
    this.isForRent = true,
    this.isForSale = false,
    required this.locationName,
    required this.city,
    required this.county,
    required this.latitude,
    required this.longitude,
    required this.photos,
    required this.amenities,
    required this.bedrooms,
    required this.bathrooms,
    required this.ownerId,
    required this.ownerName,
    this.ownerAvatar,
    this.sqft,
    this.rating = 4.5,
    this.reviewCount = 12,
    required this.createdAt,
    this.status = 'AVAILABLE',
    this.infrastructureStats = const {},
  });
}
