import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_marker_popup/flutter_map_marker_popup.dart';
import 'package:latlong2/latlong.dart';
import '../../controller/event_controller.dart';
import 'event_popup.dart';
import '../../models/event.dart';

class EventMapWidget extends StatelessWidget {
  final EventController eventController;
  final PopupController popupController;
  final Function(LatLng) onAddEvent;

  const EventMapWidget({
    super.key,
    required this.eventController,
    required this.popupController,
    required this.onAddEvent,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: ValueListenableBuilder<List<Marker>>(
        valueListenable: eventController.markers,
        builder: (BuildContext context, List<Marker> markers, _) {
          return FlutterMap(
            mapController: eventController.mapController,
            options: MapOptions(
              initialCenter: eventController.currentLocation,
              initialZoom: 13,
              onTap: (_, LatLng point) => onAddEvent(point),
            ),
            children: <Widget>[
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.your_app',
              ),
              PopupMarkerLayer(
                options: PopupMarkerLayerOptions(
                  popupController: popupController,
                  markers: markers,
                  markerTapBehavior: MarkerTapBehavior.togglePopup(),
                  popupDisplayOptions: PopupDisplayOptions(
                    snap: PopupSnap.markerCenter,
                    builder: (BuildContext context, Marker marker) {
                      final Event? event = eventController.getEventFromMarker(marker);
                      if (event == null) return const SizedBox.shrink();
                      
                      return EventPopup(
                        event: event,
                        eventController: eventController,
                        popupController: popupController,
                      );
                    },
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}