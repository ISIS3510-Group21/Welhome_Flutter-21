import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:welhome/features/filter/data/models/property_model.dart';

class PropertyCacheService {
  static const String CACHED_PROPERTIES_KEY = 'CACHED_PROPERTIES';
  static const String CACHE_TIMESTAMP_KEY = 'PROPERTIES_CACHE_TIMESTAMP';
  static const Duration CACHE_DURATION = Duration(hours: 24);
  
  final SharedPreferences _prefs;
  
  PropertyCacheService(this._prefs);
  
  Future<void> cacheProperties(List<PropertyModel> properties) async {
    final propertiesJson = properties.map((p) => p.toJson()).toList();
    await _prefs.setString(CACHED_PROPERTIES_KEY, json.encode(propertiesJson));
    await _prefs.setInt(CACHE_TIMESTAMP_KEY, DateTime.now().millisecondsSinceEpoch);
  }
  
  Future<List<PropertyModel>?> getCachedProperties() async {
    final cachedData = _prefs.getString(CACHED_PROPERTIES_KEY);
    final timestamp = _prefs.getInt(CACHE_TIMESTAMP_KEY);
    
    if (cachedData != null && timestamp != null) {
      final cacheAge = DateTime.now().difference(
        DateTime.fromMillisecondsSinceEpoch(timestamp)
      );
      
      if (cacheAge <= CACHE_DURATION) {
        final List<dynamic> decoded = json.decode(cachedData);
        return decoded
            .map((item) => PropertyModel.fromJson(item))
            .toList();
      }
    }
    return null;
  }
  
  bool hasValidCache() {
    final timestamp = _prefs.getInt(CACHE_TIMESTAMP_KEY);
    if (timestamp == null) return false;
    
    final cacheAge = DateTime.now().difference(
      DateTime.fromMillisecondsSinceEpoch(timestamp)
    );
    return cacheAge <= CACHE_DURATION;
  }
  
  Future<void> clearCache() async {
    await _prefs.remove(CACHED_PROPERTIES_KEY);
    await _prefs.remove(CACHE_TIMESTAMP_KEY);
  }

  Future<List<PropertyModel>> filterCachedProperties({
    List<String>? selectedAmenities,
    List<String>? selectedHousingTags,
  }) async {
    final properties = await getCachedProperties();
    if (properties == null) return [];

    return properties.where((property) {
      bool matchesAmenities = selectedAmenities?.isEmpty ?? true;
      bool matchesTags = selectedHousingTags?.isEmpty ?? true;

      if (selectedAmenities?.isNotEmpty ?? false) {
        matchesAmenities = property.amenities
            .any((amenity) => selectedAmenities!.contains(amenity));
      }

      if (selectedHousingTags?.isNotEmpty ?? false) {
        matchesTags = property.housingTags
            .any((tag) => selectedHousingTags!.contains(tag));
      }

      return matchesAmenities && matchesTags;
    }).toList();
  }
}