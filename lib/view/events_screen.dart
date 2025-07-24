import 'package:flutter/material.dart';
import 'package:flutter_map_marker_popup/flutter_map_marker_popup.dart';
import '../controller/event_controller.dart';
import './dialogs/event_map_widget.dart';
import '../constants/colors.dart';
import 'package:latlong2/latlong.dart';
import '../constants/text_styles.dart';

class MapEventScreen extends StatefulWidget {
  const MapEventScreen({super.key});

  @override
  State<MapEventScreen> createState() => _MapEventScreenState();
}

class _MapEventScreenState extends State<MapEventScreen> {
  final EventController eventController = EventController();
  final PopupController popupController = PopupController();

  @override
  void dispose() {
    popupController.hideAllPopups();
    popupController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      eventController.initialize();
    });
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: eventController.isLoading,
      builder: (BuildContext context, bool isLoading, _) {
        if (isLoading) {
          return _buildLoadingScreen();
        }
        return _buildMainScreen();
      },
    );
  }

  Widget _buildLoadingScreen() {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: CircularProgressIndicator(color: AppColors.primaryColor),
      ),
    );
  }

  Widget _buildMainScreen() {
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
              child: EventMapWidget(
                eventController: eventController,
                popupController: popupController,
                onAddEvent:
                    (LatLng position) =>
                        eventController.showAddEventDialog(context, position),
              ),
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNavBar(),
    );
  }

  BottomNavigationBar _buildBottomNavBar() {
    return BottomNavigationBar(
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
      onTap: (int index) => handleNavTap(context, index),
    );
  }

  void handleNavTap(BuildContext context, int index) {
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
  }
}
