import 'package:shared_preferences/shared_preferences.dart';
import 'dart:developer' as developer;

/// Modelo para datos de sesión
class SessionData {
  final String userId;
  final String email;
  final bool isOwner;

  SessionData({
    required this.userId,
    required this.email,
    required this.isOwner,
  });
}

/// Modelo para identidad offline
class OfflineIdentity {
  final String userId;
  final String email;
  final bool isOwner;

  OfflineIdentity({
    required this.userId,
    required this.email,
    required this.isOwner,
  });
}

/// Gestor de sesión segura usando SharedPreferences para eventual connectivity
class SecureSessionManager {
  static const String _keyUserId = 'user_id';
  static const String _keyEmail = 'email';
  static const String _keyIsOwner = 'is_owner';
  static const String _keySessionTimestamp = 'session_timestamp';
  static const int _sessionValidityDays = 30;

  static const String _keyProfileName = 'profile_name';
  static const String _keyProfileNationality = 'profile_nationality';
  static const String _keyProfilePhone = 'profile_phone';

  static const String _keyOfflineUserId = 'offline_user_id';
  static const String _keyOfflineEmail = 'offline_email';
  static const String _keyOfflineIsOwner = 'offline_is_owner';
  static const String _keyOfflinePassword = 'offline_password';

  late SharedPreferences _prefs;

  /// Inicializa el gestor de sesión
  Future<void> initialize() async {
    _prefs = await SharedPreferences.getInstance();
    developer.log('SecureSessionManager initialized');
  }

  /// Guarda la sesión después de login exitoso
  Future<void> saveSession({
    required String userId,
    required String email,
    required bool isOwner,
    String? password,
  }) async {
    await _prefs.setString(_keyUserId, userId);
    await _prefs.setString(_keyEmail, email);
    await _prefs.setBool(_keyIsOwner, isOwner);
    await _prefs.setInt(
      _keySessionTimestamp,
      DateTime.now().millisecondsSinceEpoch,
    );

    await saveOfflineIdentity(
      userId: userId,
      email: email,
      isOwner: isOwner,
    );

    if (password != null && password.isNotEmpty) {
      await _prefs.setString(_keyOfflinePassword, password);
    }

    developer.log('Session saved for user: $email');
  }

  /// Obtiene la sesión guardada (null si no existe o expiró)
  SessionData? getSession() {
    final userId = _prefs.getString(_keyUserId);
    final email = _prefs.getString(_keyEmail);
    final isOwner = _prefs.getBool(_keyIsOwner) ?? false;
    final timestamp = _prefs.getInt(_keySessionTimestamp) ?? 0;

    if (userId == null || email == null) {
      return null;
    }

    final currentTime = DateTime.now().millisecondsSinceEpoch;
    final daysPassed = (currentTime - timestamp) / (1000 * 60 * 60 * 24);

    if (daysPassed > _sessionValidityDays) {
      developer.log('Session expired (${daysPassed.toStringAsFixed(2)} days old)');
      clearSession();
      return null;
    }

    developer.log('Valid session found for: $email');
    return SessionData(
      userId: userId,
      email: email,
      isOwner: isOwner,
    );
  }

  /// Verifica si existe una sesión válida
  bool hasValidSession() => getSession() != null;

  /// Limpia la sesión activa (logout)
  Future<void> clearSession() async {
    await _prefs.remove(_keyUserId);
    await _prefs.remove(_keyEmail);
    await _prefs.remove(_keyIsOwner);
    await _prefs.remove(_keySessionTimestamp);
    developer.log('Session cleared (offline identity preserved)');
  }

  /// Guarda la identidad offline para login sin internet
  Future<void> saveOfflineIdentity({
    required String userId,
    required String email,
    required bool isOwner,
  }) async {
    await _prefs.setString(_keyOfflineUserId, userId);
    await _prefs.setString(_keyOfflineEmail, email);
    await _prefs.setBool(_keyOfflineIsOwner, isOwner);
    developer.log('Offline identity saved for: $email');
  }

  /// Obtiene la identidad offline guardada
  OfflineIdentity? getOfflineIdentity() {
    final userId = _prefs.getString(_keyOfflineUserId);
    final email = _prefs.getString(_keyOfflineEmail);
    final isOwner = _prefs.getBool(_keyOfflineIsOwner) ?? false;

    if (userId == null || email == null) {
      return null;
    }

    return OfflineIdentity(
      userId: userId,
      email: email,
      isOwner: isOwner,
    );
  }

  /// Guarda la contraseña de forma encriptada
  Future<void> saveOfflinePassword(String password) async {
    await _prefs.setString(_keyOfflinePassword, password);
  }

  /// Obtiene la contraseña guardada
  String? getOfflinePassword() {
    return _prefs.getString(_keyOfflinePassword);
  }

  /// Verifica si email y contraseña coinciden con datos offline
  bool verifyOfflineEmailAndPassword({
    required String email,
    required String password,
  }) {
    final offlineIdentity = getOfflineIdentity();
    final storedPassword = getOfflinePassword();

    return offlineIdentity?.email.toLowerCase() == email.toLowerCase() &&
        storedPassword == password;
  }

  /// Guarda información básica del perfil
  Future<void> saveBasicProfile({
    required String? name,
    required String? nationality,
    required String? phoneNumber,
  }) async {
    if (name != null) await _prefs.setString(_keyProfileName, name);
    if (nationality != null) {
      await _prefs.setString(_keyProfileNationality, nationality);
    }
    if (phoneNumber != null) await _prefs.setString(_keyProfilePhone, phoneNumber);
  }

  /// Obtiene el perfil básico guardado
  Map<String, String>? getBasicProfile() {
    final name = _prefs.getString(_keyProfileName);
    final nationality = _prefs.getString(_keyProfileNationality);
    final phone = _prefs.getString(_keyProfilePhone);

    if (name == null && nationality == null && phone == null) {
      return null;
    }

    return {
      'name': name ?? '',
      'nationality': nationality ?? '',
      'phone': phone ?? '',
    };
  }

  /// Limpia toda la información guardada
  Future<void> clearAll() async {
    await _prefs.clear();
    developer.log('All session data cleared');
  }

  /// Verifica si hay datos offline disponibles
  bool hasOfflineData() => getOfflineIdentity() != null;
}
