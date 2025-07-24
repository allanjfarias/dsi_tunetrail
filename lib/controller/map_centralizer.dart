import 'dart:async';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

class MapCentralizer {
  Future<LatLng> obterLocalizacaoAtual() async {
    try {
      if (!await _isLocationServiceEnabled()) {
        throw Exception('Serviço de localização desativado');
      }

      final LocationPermission permissao = await _verificarPermissoes();
      if (!_isPermissionGranted(permissao)) {
        throw Exception('Permissão de localização negada');
      }

      return await _obterPosicao();
    } catch (_) {
      return const LatLng(-8.052240, -34.928610); // Fallback para Recife
    }
  }

  Future<bool> _isLocationServiceEnabled() async {
    return await Geolocator.isLocationServiceEnabled();
  }

  Future<LocationPermission> _verificarPermissoes() async {
    try {
      return await Geolocator.checkPermission().timeout(
        const Duration(seconds: 5),
        onTimeout: () => Geolocator.requestPermission(),
      );
    } catch (_) {
      return Geolocator.requestPermission();
    }
  }

  bool _isPermissionGranted(LocationPermission permission) {
    return permission == LocationPermission.whileInUse || 
           permission == LocationPermission.always;
  }

  Future<LatLng> _obterPosicao() async {
    final Position posicao = await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        timeLimit: Duration(seconds: 10),
      ),
    ).timeout(const Duration(seconds: 10));

    return LatLng(posicao.latitude, posicao.longitude);
  }
}