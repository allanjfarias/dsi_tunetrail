import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../constants/colors.dart';
import '../models/event.dart';
import '../models/crud_repository.dart';
import '../view/dialogs/event_dialog.dart';
import 'map_centralizer.dart';

class EventController {
  // CRUD Repository
  final CrudRepository<Event> _repository;
  final SupabaseClient _supabase = Supabase.instance.client;

  // Mapa e estado
  final MapController mapController = MapController();
  final MapCentralizer mapCentralizer = MapCentralizer();
  final ValueNotifier<bool> isLoading = ValueNotifier<bool>(true);
  final ValueNotifier<List<Marker>> markers = ValueNotifier<List<Marker>>(
    <Marker>[],
  );
  final ValueNotifier<List<Event>> events = ValueNotifier<List<Event>>(
    <Event>[],
  );
  LatLng currentLocation = const LatLng(-8.052240, -34.928610);

  EventController()
    : _repository = CrudRepository<Event>(
        table: 'events',
        primaryKey: 'id',
        fromJson: (Map<String, dynamic> json) => Event.fromJson(json),
        toJson: (Event event) => event.toJson(),
      );

  Future<void> initialize() async {
    try {
      await _fetchCurrentLocation();
      await _loadEvents();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _fetchCurrentLocation() async {
    try {
      currentLocation = await mapCentralizer.obterLocalizacaoAtual();
      _moveMapSafely(currentLocation);
    } catch (_) {
      currentLocation = const LatLng(-8.052240, -34.928610);
    }
  }

  void _moveMapSafely(LatLng position) {
    try {
      mapController.move(position, 15);
    } catch (_) {
      Timer(const Duration(milliseconds: 500), () {
        mapController.move(position, 15);
      });
    }
  }

  Future<void> _loadEvents() async {
    try {
      events.value = await getEvents();
      _updateMarkers();
    } catch (e) {
      _showSnackBar('Erro ao carregar eventos: ${e.toString()}');
    }
  }

  void _updateMarkers() {
    markers.value =
        events.value.map((Event event) {
          return Marker(
            point: event.location,
            width: 40,
            height: 40,
            key: ValueKey<String?>(event.id),
            child: GestureDetector(
              behavior: HitTestBehavior.translucent,
              child: Icon(
                Icons.location_on,
                size: 40,
                color: _getRandomColor(event.id.hashCode),
              ),
            ),
          );
        }).toList();
  }

  Color _getRandomColor(int seed) {
    const List<Color> colors = <Color>[
      AppColors.accent,
      Colors.red,
      Colors.blue,
      Colors.green,
      Colors.purple,
      Colors.orange,
    ];
    return colors[seed % colors.length];
  }

  // Funções CRUD (do primeiro arquivo)
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

  Future<void> deleteEvent(Event event) async {
    await _repository.delete(event.id!);
  }

  bool isOwner(Event event) {
    final String? currentUserId = _supabase.auth.currentUser?.id;
    return currentUserId != null && event.ownerId == currentUserId;
  }

  void showAddEventDialog(BuildContext context, LatLng position) {
    showDialog(
      context: context,
      builder:
          (BuildContext context) => EventDialog(
            title: 'Novo Evento',
            onSubmit:
                (String name, String description) =>
                    _handleCreateEvent(context, name, description, position),
          ),
    );
  }

  void showEditEventDialog(BuildContext context, Event event) {
    showDialog(
      context: context,
      builder:
          (BuildContext context) => EventDialog(
            title: 'Editar Evento',
            event: event,
            onSubmit:
                (String name, String description) =>
                    _handleUpdateEvent(context, event, name, description),
          ),
    );
  }

  Future<void> _handleCreateEvent(
    BuildContext context,
    String name,
    String description,
    LatLng position,
  ) async {
    try {
      await createEvent(name, description, position);
      await _loadEvents();
    } catch (e) {
      _showSnackBar('Erro ao criar evento: $e');
    }
  }

  Future<void> _handleUpdateEvent(
    BuildContext context,
    Event original,
    String name,
    String description,
  ) async {
    try {
      final Event updatedEvent = original.copyWith(
        name: name,
        description: description,
      );
      await updateEvent(updatedEvent);
      await _loadEvents();
    } catch (e) {
      _showSnackBar('Erro ao atualizar evento: $e');
    }
  }

  Future<void> loadEvents() async {
    await _loadEvents(); // se _loadEvents já existe
  }

  Future<void> handleDeleteEvent(Event event) async {
    try {
      if (event.id != null) {
        await deleteEvent(event);
        await _loadEvents();
      }
    } catch (e) {
      _showSnackBar('Erro ao excluir: $e');
    }
  }

  void _showSnackBar(String message) {
    // Implementação alternativa sem contexto
    debugPrint('[SnackBar]: $message');
  }

  Event? getEventFromMarker(Marker marker) {
    final int index = markers.value.indexOf(marker);
    return (index >= 0 && index < events.value.length)
        ? events.value[index]
        : null;
  }
}
