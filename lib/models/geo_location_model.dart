class GeoLocation {
  final double latitude;
  final double longitude;
  final String? address;
  final double? accuracyMeters;
  final String? label;

  const GeoLocation({
    required this.latitude,
    required this.longitude,
    this.address,
    this.accuracyMeters,
    this.label,
  });

  factory GeoLocation.fromMap(Map<String, dynamic> map) {
    return GeoLocation(
      latitude: (map['latitude'] as num).toDouble(),
      longitude: (map['longitude'] as num).toDouble(),
      address: map['address'] as String?,
      accuracyMeters: (map['accuracyMeters'] as num?)?.toDouble(),
      label: map['label'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'latitude': latitude,
      'longitude': longitude,
      if (address != null) 'address': address,
      if (accuracyMeters != null) 'accuracyMeters': accuracyMeters,
      if (label != null) 'label': label,
    };
  }
}
