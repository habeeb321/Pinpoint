class LocationModel {
  final String id; // Add this field
  final String name;
  final double lat;
  final double long;

  LocationModel({
    required this.id,
    required this.name,
    required this.lat,
    required this.long,
  });

  // Convert a LocationModel object into a JSON-compatible map
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'lat': lat,
      'long': long,
    };
  }

  // Create a LocationModel object from a JSON map
  factory LocationModel.fromJson(Map<String, dynamic> json) {
    return LocationModel(
      id: json['id'],
      name: json['name'],
      lat: json['lat'],
      long: json['long'],
    );
  }

  @override
  String toString() {
    return 'LocationModel(id: $id,name: $name, lat: $lat, long: $long)';
  }
}
