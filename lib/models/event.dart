import 'package:latlong2/latlong.dart';

class Event {
  final String? id;
  final String name;
  final String description;
  final double latitude;
  final double longitude;
  final String? ownerId;

  Event({
    this.id,
    required this.name,
    required this.description,
    required this.latitude,
    required this.longitude,
    this.ownerId,
  });

  factory Event.fromJson(Map<String, dynamic> json) {
    return Event(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      latitude: json['latitude'],
      longitude: json['longitude'],
      ownerId: json['owner_id'],
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'name': name,
      'description': description,
      'latitude': latitude,
      'longitude': longitude,
      'owner_id': ownerId,
    };
  }

  LatLng get location => LatLng(latitude, longitude);

  Event copyWith({
    String? id,
    String? name,
    String? description,
    double? latitude,
    double? longitude,
    String? ownerId,
  }) {
    return Event(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      ownerId: ownerId ?? this.ownerId,
    );
  }
}
