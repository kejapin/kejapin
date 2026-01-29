class LifePin {
  final String id;
  final String label;
  final double latitude;
  final double longitude;
  final String transportMode;
  final bool isPrimary;

  LifePin({
    required this.id,
    required this.label,
    required this.latitude,
    required this.longitude,
    required this.transportMode,
    this.isPrimary = false,
  });

  factory LifePin.fromJson(Map<String, dynamic> json) {
    return LifePin(
      id: json['id'],
      label: json['label'],
      latitude: json['latitude'],
      longitude: json['longitude'],
      transportMode: json['transport_mode'],
      isPrimary: json['is_primary'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'label': label,
      'latitude': latitude,
      'longitude': longitude,
      'transport_mode': transportMode,
      'is_primary': isPrimary,
    };
  }
}
