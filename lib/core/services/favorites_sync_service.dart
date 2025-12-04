import 'dart:developer' as developer;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:welhome/core/data/local/favorites_manager.dart';
import 'package:welhome/core/data/models/favorite_item.dart';
import 'package:welhome/core/services/connectivity_service.dart';

class FavoritesSyncService {
  final FavoritesManager _favoritesManager;
  final ConnectivityService _connectivityService;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  bool isSyncing = false;

  FavoritesSyncService({
    required FavoritesManager favoritesManager,
    required ConnectivityService connectivityService,
  })  : _favoritesManager = favoritesManager,
        _connectivityService = connectivityService;

  // Iniciar sincronización automática cuando se restaure la conexión
  Future<void> startAutoSync() async {
    _connectivityService.connectivityStream.listen((isConnected) async {
      if (isConnected) {
        developer.log('Connection restored, syncing favorites...');
        await syncPendingFavorites();
      }
    });
  }

  // Sincronizar todos los favoritos pendientes
  Future<void> syncPendingFavorites() async {
    try {
      isSyncing = true;
      List<FavoriteItem> pendingFavorites =
          await _favoritesManager.getPendingSyncFavorites();

      for (FavoriteItem favorite in pendingFavorites) {
        await _syncFavorite(favorite);
      }

      isSyncing = false;
      developer.log('All pending favorites synced');
    } catch (e) {
      isSyncing = false;
      developer.log('Error syncing favorites: $e');
    }
  }

  // Sincronizar un favorito individual
  Future<void> _syncFavorite(FavoriteItem favorite) async {
    try {
      String? userId = _auth.currentUser?.uid;
      if (userId == null) throw Exception('User not authenticated');

      // Referencia a la colección de favoritos del usuario
      final favoritesRef = _firestore
          .collection('StudentUser')
          .doc(userId)
          .collection('favorites');

      // Verificar si es una adición o eliminación basándose en si el favorito existe localmente
      // En este caso, si está pendingSync y no hay syncError, es una adición
      if (favorite.syncError == null) {
        // Agregar/actualizar favorito en Firestore
        await favoritesRef.doc(favorite.postId).set({
          'postId': favorite.postId,
          'title': favorite.title,
          'address': favorite.address,
          'price': favorite.price,
          'rating': favorite.rating,
          'reviewQuantity': favorite.reviewQuantity,
          'thumbnailUrl': favorite.thumbnailUrl,
          'hostId': favorite.hostId,
          'addedAt': Timestamp.fromDate(favorite.addedAt),
          'lastModifiedAt': Timestamp.now(),
        });

        developer.log('Favorite synced: ${favorite.postId}');
      }

      // Marcar como sincronizado
      await _favoritesManager.markSynced(favorite.postId);
    } catch (e) {
      developer.log('Error syncing favorite ${favorite.postId}: $e');
      await _favoritesManager.updateSyncStatus(
        favorite.postId,
        syncError: e.toString(),
      );
    }
  }

  // Agregar un favorito (con manejo offline)
  Future<void> addFavoriteWithSync(FavoriteItem favorite) async {
    try {
      // Guardar en caché local inmediatamente
      await _favoritesManager.addFavorite(
        favorite.copyWith(pendingSync: true, syncError: null),
      );

      // Intentar sincronizar si hay conexión
      if (await _connectivityService.isConnected()) {
        await _syncFavorite(favorite);
      } else {
        developer.log('Offline: favorite saved locally, will sync later');
      }
    } catch (e) {
      developer.log('Error adding favorite: $e');
      rethrow;
    }
  }

  // Eliminar un favorito (con manejo offline)
  Future<void> removeFavoriteWithSync(String postId) async {
    try {
      // Eliminar del caché local inmediatamente
      await _favoritesManager.removeFavorite(postId);

      // Intentar sincronizar eliminación si hay conexión
      if (await _connectivityService.isConnected()) {
        String? userId = _auth.currentUser?.uid;
        if (userId != null) {
          await _firestore
              .collection('StudentUser')
              .doc(userId)
              .collection('favorites')
              .doc(postId)
              .delete();

          developer.log('Favorite removed and synced: $postId');
        }
      } else {
        developer.log('Offline: favorite removed locally, sync pending');
      }
    } catch (e) {
      developer.log('Error removing favorite: $e');
      rethrow;
    }
  }

  // Reintentar sincronizar un favorito específico
  Future<void> retrySyncFavorite(String postId) async {
    try {
      FavoriteItem? favorite = await _favoritesManager.getFavorite(postId);
      if (favorite != null) {
        await _syncFavorite(favorite);
      }
    } catch (e) {
      developer.log('Error retrying sync for $postId: $e');
      rethrow;
    }
  }

  // Refrescar favoritos desde Firestore
  Future<void> refreshFavoritesFromFirebase() async {
    try {
      String? userId = _auth.currentUser?.uid;
      if (userId == null) throw Exception('User not authenticated');

      // Obtener favoritos de Firestore
      final snapshot = await _firestore
          .collection('StudentUser')
          .doc(userId)
          .collection('favorites')
          .get();

      List<FavoriteItem> favorites = [];
      for (var doc in snapshot.docs) {
        try {
          final data = doc.data();
          favorites.add(FavoriteItem(
            postId: data['postId'] as String,
            title: data['title'] as String,
            address: data['address'] as String,
            price: (data['price'] as num).toDouble(),
            rating: (data['rating'] as num).toDouble(),
            reviewQuantity: data['reviewQuantity'] as int,
            thumbnailUrl: data['thumbnailUrl'] as String?,
            hostId: data['hostId'] as String?,
            addedAt: (data['addedAt'] as Timestamp).toDate(),
            lastModifiedAt: (data['lastModifiedAt'] as Timestamp).toDate(),
            pendingSync: false,
            syncError: null,
          ));
        } catch (e) {
          developer.log('Error parsing favorite: $e');
        }
      }

      // Actualizar caché local
      await _favoritesManager.clearAll();
      for (var fav in favorites) {
        await _favoritesManager.addFavorite(fav);
      }

      await _favoritesManager.updateLastSyncTime();
      developer.log('Favorites refreshed from Firebase');
    } catch (e) {
      developer.log('Error refreshing favorites: $e');
      rethrow;
    }
  }
}
