import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:welhome/core/data/models/favorite_item.dart';

class FavoritesManager {
  static const String _favoritesKey = 'favorites_list';
  static const String _lastSyncKey = 'favorites_last_sync';
  late SharedPreferences _prefs;

  Future<void> initialize() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // Agregar un favorito
  Future<void> addFavorite(FavoriteItem favorite) async {
    try {
      List<FavoriteItem> favorites = await getAllFavorites();
      
      // Verificar si ya existe
      int index = favorites.indexWhere((f) => f.postId == favorite.postId);
      if (index >= 0) {
        // Si ya existe, actualizar
        favorites[index] = favorite;
      } else {
        // Si no existe, agregar
        favorites.add(favorite);
      }

      await _saveFavorites(favorites);
    } catch (e) {
      throw Exception('Error adding favorite: $e');
    }
  }

  // Obtener todos los favoritos
  Future<List<FavoriteItem>> getAllFavorites() async {
    try {
      String? jsonString = _prefs.getString(_favoritesKey);
      if (jsonString == null) return [];

      List<dynamic> jsonList = jsonDecode(jsonString);
      return jsonList
          .map((item) => FavoriteItem.fromMap(item as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Error retrieving favorites: $e');
    }
  }

  // Obtener un favorito específico
  Future<FavoriteItem?> getFavorite(String postId) async {
    try {
      List<FavoriteItem> favorites = await getAllFavorites();
      return favorites.firstWhere(
        (f) => f.postId == postId,
        orElse: () => throw Exception('Favorite not found'),
      );
    } catch (e) {
      return null;
    }
  }

  // Verificar si un post es favorito
  Future<bool> isFavorite(String postId) async {
    try {
      FavoriteItem? favorite = await getFavorite(postId);
      return favorite != null;
    } catch (e) {
      return false;
    }
  }

  // Eliminar un favorito
  Future<void> removeFavorite(String postId) async {
    try {
      List<FavoriteItem> favorites = await getAllFavorites();
      favorites.removeWhere((f) => f.postId == postId);

      if (favorites.isEmpty) {
        await _prefs.remove(_favoritesKey);
      } else {
        await _saveFavorites(favorites);
      }
    } catch (e) {
      throw Exception('Error removing favorite: $e');
    }
  }

  // Obtener favoritos pendientes de sincronizar
  Future<List<FavoriteItem>> getPendingSyncFavorites() async {
    try {
      List<FavoriteItem> favorites = await getAllFavorites();
      return favorites.where((f) => f.pendingSync).toList();
    } catch (e) {
      throw Exception('Error retrieving pending sync favorites: $e');
    }
  }

  // Actualizar estado de sincronización
  Future<void> updateSyncStatus(
    String postId, {
    bool? pendingSync,
    String? syncError,
  }) async {
    try {
      FavoriteItem? favorite = await getFavorite(postId);
      if (favorite == null) throw Exception('Favorite not found');

      FavoriteItem updatedFavorite = favorite.copyWith(
        pendingSync: pendingSync ?? favorite.pendingSync,
        syncError: syncError ?? favorite.syncError,
        lastModifiedAt: DateTime.now(),
      );

      await addFavorite(updatedFavorite);
    } catch (e) {
      throw Exception('Error updating sync status: $e');
    }
  }

  // Marcar como sincronizado
  Future<void> markSynced(String postId) async {
    try {
      FavoriteItem? favorite = await getFavorite(postId);
      if (favorite == null) throw Exception('Favorite not found');

      FavoriteItem updatedFavorite = favorite.copyWith(
        pendingSync: false,
        syncError: null,
        lastModifiedAt: DateTime.now(),
      );

      await addFavorite(updatedFavorite);
    } catch (e) {
      throw Exception('Error marking as synced: $e');
    }
  }

  // Obtener timestamp de última sincronización
  DateTime? getLastSyncTime() {
    String? lastSync = _prefs.getString(_lastSyncKey);
    if (lastSync == null) return null;
    return DateTime.parse(lastSync);
  }

  // Actualizar timestamp de última sincronización
  Future<void> updateLastSyncTime() async {
    await _prefs.setString(_lastSyncKey, DateTime.now().toIso8601String());
  }

  // Limpiar todos los favoritos
  Future<void> clearAll() async {
    try {
      await _prefs.remove(_favoritesKey);
    } catch (e) {
      throw Exception('Error clearing favorites: $e');
    }
  }

  // Helper privado para guardar favoritos
  Future<void> _saveFavorites(List<FavoriteItem> favorites) async {
    List<Map<String, dynamic>> jsonList =
        favorites.map((fav) => fav.toMap()).toList();
    await _prefs.setString(_favoritesKey, jsonEncode(jsonList));
  }
}
