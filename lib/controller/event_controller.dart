import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/event.dart';
import '../models/crud_repository.dart';
import 'package:latlong2/latlong.dart';

class EventController {
  final CrudRepository<Event> _repository;
  final SupabaseClient _supabase = Supabase.instance.client;

  EventController()
    : _repository = CrudRepository<Event>(
        table: 'events',
        primaryKey: 'id',
        fromJson: (Map<String, dynamic> json) => Event.fromJson(json),
        toJson: (Event event) => event.toJson(),
      );

  Future<Event> createEvent(
    String name,
    String description,
    LatLng location,
  ) async {
    final Event event = Event(
      name: name,
      description: description,
      latitude: location.latitude,
      longitude: location.longitude,
      ownerId: _supabase.auth.currentUser?.id,
    );
    return await _repository.create(event);
  }

  Future<List<Event>> getEvents() async {
    return await _repository.readAll();
  }

  Future<void> updateEvent(Event event) async {
    if (event.id == null) throw Exception('Event ID is null');
    await _repository.update(event.id!, event);
  }

  Future<void> deleteEvent(String eventId) async {
    await _repository.delete(eventId);
  }

  bool isOwner(Event event) {
    final String? currentUserId = _supabase.auth.currentUser?.id;
    return currentUserId != null && event.ownerId == currentUserId;
  }
}
