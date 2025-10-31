import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:welhome/features/filter/data/models/property_model.dart';

class PropertyLocalDataSource {
  static const String CACHED_PROPERTIES_KEY = 'CACHED_PROPERTIES';
  static const String CACHE_TIMESTAMP_KEY = 'PROPERTIES_CACHE_TIMESTAMP';
  static const Duration CACHE_DURATION = Duration(minutes: 30);

  final SharedPreferences _prefs;

  PropertyLocalDataSource(this._prefs);

  Future<void> cacheProperties(List<PropertyModel> properties) async {
    final List<Map<String, dynamic>> propertiesJson = 
        properties.map((property) => property.toJson()).toList();
    
    await _prefs.setString(
      CACHED_PROPERTIES_KEY,
      json.encode(propertiesJson),
    );
    
    await _prefs.setInt(
      CACHE_TIMESTAMP_KEY,
      DateTime.now().millisecondsSinceEpoch,
    );
  }

  Future<List<PropertyModel>?> getCachedProperties() async {
    final cachedData = _prefs.getString(CACHED_PROPERTIES_KEY);
    final timestamp = _prefs.getInt(CACHE_TIMESTAMP_KEY);

    if (cachedData != null && timestamp != null) {
      final cacheDateTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
      final now = DateTime.now();

      // Verificar si el caché aún es válido
      if (now.difference(cacheDateTime) <= CACHE_DURATION) {
        final List<dynamic> decoded = json.decode(cachedData);
        return decoded
            .map((item) => PropertyModel.fromJson(item as Map<String, dynamic>))
            .toList();
      }
    }
    return null;
  }

  Future<bool> isCacheValid() async {
    final timestamp = _prefs.getInt(CACHE_TIMESTAMP_KEY);
    if (timestamp == null) return false;

    final cacheDateTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
    final now = DateTime.now();
    return now.difference(cacheDateTime) <= CACHE_DURATION;
  }

  Future<void> clearCache() async {
    await _prefs.remove(CACHED_PROPERTIES_KEY);
    await _prefs.remove(CACHE_TIMESTAMP_KEY);
  }
}