import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_marker_popup/flutter_map_marker_popup.dart';
import 'package:latlong2/latlong.dart';
import '../constants/colors.dart';
import '../constants/text_styles.dart';
import '../controller/map_centralizer.dart';
import '../controller/event_controller.dart';
import '../models/event.dart';

class MapEventScreen extends StatefulWidget {
  const MapEventScreen({super.key});

  @override
  State<MapEventScreen> createState() => _MapEventScreenState();
}

class _MapEventScreenState extends State<MapEventScreen> {
  final MapController mapController = MapController();
  final PopupController popupController = PopupController();
  final MapCentralizer mapCentralizer = MapCentralizer();
  final EventController eventController = EventController();
  final LatLng recifeCoordinates = const LatLng(-8.052240, -34.928610);
  List<Marker> _markers = <Marker>[];
  List<Event> _events = <Event>[];
  LatLng? _currentLocation;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _init();
      showTopSnackbar(
        context,
        'Toque em qualquer local do mapa para adicionar um novo evento musical',
      );
    });
  }

  Future<void> _init() async {
    try {
      await _buscarLocalAtual();
      await _loadEvents();
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _buscarLocalAtual() async {
    LatLng local = recifeCoordinates;
    try {
      local = await mapCentralizer.obterLocalizacaoAtual();
    } catch (_) {}

    if (mounted) setState(() => _currentLocation = local);
    _moveMapSafely(local);
  }

  void _moveMapSafely(LatLng position) {
    try {
      mapController.move(position, 15);
    } catch (_) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          try {
            mapController.move(position, 15);
          } catch (_) {}
        }
      });
    }
  }

  Future<void> _loadEvents() async {
    try {
      final List<Event> events = await eventController.getEvents();

      if (!mounted) return;

      setState(() {
        _events = events;
        _updateMarkers();
      });
    } catch (e) {
      _showSnackBar('Erro ao carregar eventos: ${e.toString()}');
    }
  }

  void _updateMarkers() {
    _markers =
        _events.map((Event event) {
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
    final List<Color> colors = <Color>[
      AppColors.accent,
      Colors.red,
      Colors.blue,
      Colors.green,
      Colors.purple,
      Colors.orange,
    ];
    return colors[seed % colors.length];
  }

  void _showSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: AppColors.card,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      );
    }
  }

  void _addEventMarker(LatLng latLng) {
    final TextEditingController nameController = TextEditingController();
    final TextEditingController descController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          insetPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 24,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          backgroundColor: Colors.transparent,
          child: Container(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.8,
            ),
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(16),
              boxShadow: <BoxShadow>[
                BoxShadow(
                  color: const Color.fromRGBO(0, 0, 0, 0.3),
                  blurRadius: 20,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: SingleChildScrollView(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      'Novo Evento',
                      style: AppTextStyles.headlineSmall().copyWith(
                        color: AppColors.primaryColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      controller: nameController,
                      style: AppTextStyles.bodyLarge(),
                      decoration: InputDecoration(
                        labelText: 'Nome do evento',
                        labelStyle: AppTextStyles.bodyMedium(
                          color: AppColors.textSecondary,
                        ),
                        filled: true,
                        fillColor: AppColors.inputBackground,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: descController,
                      style: AppTextStyles.bodyLarge(),
                      maxLines: 3,
                      minLines: 1, // Adicionado para flexibilidade
                      decoration: InputDecoration(
                        labelText: 'Descrição',
                        labelStyle: AppTextStyles.bodyMedium(
                          color: AppColors.textSecondary,
                        ),
                        filled: true,
                        fillColor: AppColors.inputBackground,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: <Widget>[
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 12,
                            ),
                          ),
                          child: Text(
                            'Cancelar',
                            style: AppTextStyles.bodyMedium(
                              color: AppColors.error,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryColor,
                            padding: const EdgeInsets.symmetric(
                              vertical: 12,
                              horizontal: 6,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          onPressed: () async {
                            if (nameController.text.isEmpty) {
                              _showSnackBar('O nome do evento é obrigatório');
                              return;
                            }
                            final NavigatorState navigator = Navigator.of(
                              context,
                            );

                            try {
                              await eventController.createEvent(
                                nameController.text,
                                descController.text,
                                latLng,
                              );
                              await _loadEvents();
                            } catch (e) {
                              _showSnackBar('Erro ao criar evento: $e');
                            }

                            if (mounted) navigator.pop();
                          },
                          child: Text(
                            'Criar',
                            style: AppTextStyles.bodyMedium(
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void _editEvent(Event event) {
    final TextEditingController nameController = TextEditingController(
      text: event.name,
    );
    final TextEditingController descController = TextEditingController(
      text: event.description,
    );

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          insetPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 24,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          backgroundColor: Colors.transparent,
          child: Container(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.8,
            ),
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(16),
              boxShadow: <BoxShadow>[
                BoxShadow(
                  color: const Color.fromRGBO(0, 0, 0, 0.3),
                  blurRadius: 20,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: SingleChildScrollView(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      'Editar Evento',
                      style: AppTextStyles.headlineSmall().copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      autofocus: true, // Foco automático ao abrir o diálogo
                      controller: nameController,
                      style: AppTextStyles.bodyLarge(),
                      decoration: InputDecoration(
                        labelText: 'Nome do evento',
                        labelStyle: AppTextStyles.bodyMedium(
                          color: AppColors.textSecondary,
                        ),
                        filled: true,
                        fillColor: AppColors.inputBackground,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: descController,
                      style: AppTextStyles.bodyLarge(),
                      maxLines: 3,
                      minLines: 1, // Flexibilidade no tamanho do campo
                      decoration: InputDecoration(
                        labelText: 'Descrição',
                        labelStyle: AppTextStyles.bodyMedium(
                          color: AppColors.textSecondary,
                        ),
                        filled: true,
                        fillColor: AppColors.inputBackground,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: <Widget>[
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 12,
                            ),
                          ),
                          child: Text(
                            'Cancelar',
                            style: AppTextStyles.bodyMedium(
                              color: AppColors.error,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryColor,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 12,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          onPressed: () async {
                            final NavigatorState navigator = Navigator.of(
                              context,
                            );
                            try {
                              final Event updatedEvent = Event(
                                id: event.id,
                                name: nameController.text,
                                description: descController.text,
                                latitude: event.latitude,
                                longitude: event.longitude,
                                ownerId: event.ownerId,
                              );

                              await eventController.updateEvent(updatedEvent);
                              await _loadEvents();
                            } catch (e) {
                              _showSnackBar('Erro ao atualizar evento: $e');
                            }
                            if (mounted) navigator.pop();
                          },
                          child: Text(
                            'Salvar',
                            style: AppTextStyles.bodyMedium(
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: AppColors.background,
        body: Stack(
          children: <Widget>[
            // Se quiser, pode ter algum conteúdo aqui atrás
            Align(
              alignment:
                  Alignment.bottomCenter, // fixa na parte inferior central
              child: Padding(
                padding: const EdgeInsets.only(bottom: 50),
                child: CircularProgressIndicator(color: AppColors.primaryColor),
              ),
            ),
          ],
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'TuneTrail - Eventos',
          style: AppTextStyles.headlineSmall().copyWith(
            color: AppColors.primaryLight,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: AppColors.background,
        centerTitle: true,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: <Widget>[
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: FlutterMap(
                  mapController: mapController,
                  options: MapOptions(
                    initialCenter: _currentLocation ?? recifeCoordinates,
                    initialZoom: 13,
                    onTap: (_, LatLng point) => _addEventMarker(point),
                  ),
                  children: <Widget>[
                    TileLayer(
                      urlTemplate:
                          'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'com.example.your_app',
                    ),

                    PopupMarkerLayer(
                      options: PopupMarkerLayerOptions(
                        popupController: popupController,
                        markers: _markers,
                        markerTapBehavior: MarkerTapBehavior.togglePopup(),
                        popupDisplayOptions: PopupDisplayOptions(
                          snap: PopupSnap.markerCenter,
                          builder: (BuildContext context, Marker marker) {
                            final int index = _markers.indexOf(marker);
                            if (index < 0 || index >= _events.length) {
                              return const SizedBox.shrink();
                            }

                            final Event event = _events[index];
                            final bool isOwner = eventController.isOwner(event);

                            return Align(
                              alignment: Alignment.center,
                              child: Container(
                                width: 280,
                                margin: const EdgeInsets.only(top: 20),
                                decoration: BoxDecoration(
                                  color: AppColors.card,
                                  borderRadius: BorderRadius.circular(16),
                                  boxShadow: <BoxShadow>[
                                    BoxShadow(
                                      color: const Color.fromRGBO(0, 0, 0, 0.3),
                                      blurRadius: 20,
                                      spreadRadius: 2,
                                    ),
                                  ],
                                ),
                                child: Material(
                                  color: Colors.transparent,
                                  child: Padding(
                                    padding: const EdgeInsets.all(16),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: <Widget>[
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: <Widget>[
                                            Expanded(
                                              child: Text(
                                                event.name,
                                                style:
                                                    AppTextStyles.headlineSmall()
                                                        .copyWith(
                                                          color:
                                                              AppColors
                                                                  .textPrimary,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                        ),
                                              ),
                                            ),
                                            IconButton(
                                              icon: const Icon(
                                                Icons.close,
                                                size: 20,
                                                color: AppColors.textPrimary,
                                              ),
                                              onPressed:
                                                  popupController.hideAllPopups,
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 12),
                                        Text(
                                          event.description,
                                          style: AppTextStyles.bodyMedium()
                                              .copyWith(
                                                color: AppColors.textSecondary,
                                              ),
                                        ),
                                        if (isOwner) ...<Widget>[
                                          const SizedBox(height: 16),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.end,
                                            children: <Widget>[
                                              IconButton(
                                                icon: Icon(
                                                  Icons.edit,
                                                  color: AppColors.primaryColor,
                                                  size: 24,
                                                ),
                                                onPressed: () {
                                                  popupController
                                                      .hideAllPopups();
                                                  _editEvent(event);
                                                },
                                              ),
                                              const SizedBox(width: 8),
                                              IconButton(
                                                icon: Icon(
                                                  Icons.delete,
                                                  color: AppColors.error,
                                                  size: 24,
                                                ),
                                                onPressed: () async {
                                                  try {
                                                    if (event.id != null) {
                                                      await eventController
                                                          .deleteEvent(
                                                            event.id!,
                                                          );
                                                      await _loadEvents();
                                                    }
                                                  } catch (e) {
                                                    _showSnackBar(
                                                      'Erro ao excluir: $e',
                                                    );
                                                  }
                                                  popupController
                                                      .hideAllPopups();
                                                },
                                              ),
                                            ],
                                          ),
                                        ],
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: AppColors.background,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: AppColors.primaryColor,
        unselectedItemColor: AppColors.textDisabled,
        currentIndex: 3,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Início'),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Buscar'),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            label: 'Perfil',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today_outlined),
            label: 'Eventos',
          ),
        ],
        onTap: (int index) {
          switch (index) {
            case 0:
              Navigator.pushReplacementNamed(context, '/home_screen');
              break;
            case 1:
              Navigator.pushReplacementNamed(context, '/buscar_screen');
              break;
            case 2:
              Navigator.pushReplacementNamed(context, '/profile');
              break;
            case 3:
              break;
          }
        },
      ),
    );
  }

  void showTopSnackbar(BuildContext context, String message) {
    final OverlayState overlay = Overlay.of(context);

    final MediaQueryData mediaQuery = MediaQuery.of(context);

    late OverlayEntry overlayEntry;

    overlayEntry = OverlayEntry(
      builder:
          (BuildContext context) => GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTap: () => overlayEntry.remove(),
            child: Material(
              color: Colors.transparent,
              child: SafeArea(
                child: Container(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 16,
                  ),
                  padding: const EdgeInsets.all(20),
                  width: double.infinity,
                  height: mediaQuery.size.height * 0.95,
                  decoration: BoxDecoration(
                    color: AppColors.card.withAlpha((0.97 * 255).toInt()),
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: <BoxShadow>[
                      BoxShadow(
                        color: Colors.black.withAlpha((0.2 * 255).toInt()),
                        blurRadius: 15,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: Center(
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          Icon(
                            Icons.map_outlined,
                            size: 72,
                            color: AppColors.primaryColor,
                          ),
                          const SizedBox(height: 20),
                          Text(
                            'Bem-vindo ao Mapa de Eventos',
                            style: AppTextStyles.headlineSmall().copyWith(
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 15),
                          Text(
                            message,
                            style: AppTextStyles.bodyLarge().copyWith(
                              color: AppColors.textSecondary,
                              fontSize: 18,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 30),
                          ElevatedButton(
                            onPressed: () => overlayEntry.remove(),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primaryColor,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 32,
                                vertical: 16,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: Text(
                              'Fechar',
                              style: AppTextStyles.bodyLarge(
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
    );

    overlay.insert(overlayEntry);

    Future<Null>.delayed(const Duration(seconds: 6), () {
      if (overlayEntry.mounted) overlayEntry.remove();
    });
  }
}
