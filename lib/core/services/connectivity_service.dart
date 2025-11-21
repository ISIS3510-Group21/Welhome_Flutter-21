import 'package:connectivity_plus/connectivity_plus.dart';
import 'dart:developer' as developer;

/// Servicio para monitorear la conectividad de la aplicación
class ConnectivityService {
  final _connectivity = Connectivity();
  
  /// Stream que emite cambios de conectividad
  Stream<bool> get connectivityStream => _connectivity.onConnectivityChanged
      .map((result) => !result.contains(ConnectivityResult.none));

  /// Obtiene el estado actual de conectividad
  Future<bool> isConnected() async {
    final result = await _connectivity.checkConnectivity();
    final isOnline = !result.contains(ConnectivityResult.none);
    developer.log('Connectivity check: ${isOnline ? "online" : "offline"}');
    return isOnline;
  }
}
