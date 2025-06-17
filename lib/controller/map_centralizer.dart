import 'dart:async';

import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';

class MapCentralizer {
  Future<LatLng> obterLocalizacaoAtual() async {
    try {
      final bool servicoAtivo = await Geolocator.isLocationServiceEnabled();
      if (!servicoAtivo) {
        throw Exception('Serviço de localização desativado');
      }

      final LocationPermission permissao =
          await _verificarPermissoesComTimeout();
      if (permissao != LocationPermission.whileInUse &&
          permissao != LocationPermission.always) {
        throw Exception('Permissão de localização negada');
      }

      final Position posicao = await _obterPosicaoComTimeout();
      return LatLng(posicao.latitude, posicao.longitude);
    } catch (e) {
      return const LatLng(-8.052240, -34.928610);
    }
  }

  Future<LocationPermission> _verificarPermissoesComTimeout() async {
    try {
      return await Geolocator.checkPermission().timeout(
        const Duration(seconds: 5),
        onTimeout: () {
          throw TimeoutException('Timeout na verificação de permissões');
        },
      );
    } catch (e) {
      // Se timeout ou erro, solicita permissão
      return await Geolocator.requestPermission();
    }
  }

  Future<Position> _obterPosicaoComTimeout() async {
    return await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high, // Precisão alta
        timeLimit: Duration(seconds: 10), // Timeout de 10 segundos
      ),
    ).timeout(
      const Duration(seconds: 10),
      onTimeout: () {
        throw TimeoutException('Timeout na obtenção da posição');
      },
    );
  }
}
