class ListingEntity {
  final String id;
  final String title;
  final String description;
  final String propertyType; // BEDSITTER, 1BHK, etc.
  final String listingType; // RENT, SALE
  final double priceAmount;
  final String locationName; // e.g. "Roysambu, TRM Drive"
  final String city;
  final String county;
  final double latitude;
  final double longitude;
  final List<String> photos;
  final List<String> amenities;
  final int bedrooms;
  final int bathrooms;

  ListingEntity({
    required this.id,
    required this.title,
    required this.description,
    required this.propertyType,
    required this.listingType,
    required this.priceAmount,
    required this.locationName,
    required this.city,
    required this.county,
    required this.latitude,
    required this.longitude,
    required this.photos,
    required this.amenities,
    required this.bedrooms,
    required this.bathrooms,
  });
}
