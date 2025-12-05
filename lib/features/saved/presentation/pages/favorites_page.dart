import 'package:flutter/material.dart';
import 'dart:developer' as developer;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shimmer/shimmer.dart';
import 'package:welhome/core/constants/app_colors.dart';
import 'package:welhome/core/constants/app_text_styles.dart';
import 'package:welhome/core/data/local/favorites_manager.dart';
import 'package:welhome/core/data/models/favorite_item.dart';
import 'package:welhome/core/services/connectivity_service.dart';
import 'package:welhome/core/services/favorites_sync_service.dart';
import 'package:welhome/core/widgets/custom_bottom_nav_bar.dart';
import 'package:welhome/core/widgets/favorite_post_card.dart';

class FavoritesPage extends StatefulWidget {
  final String userId;

  const FavoritesPage({super.key, required this.userId});

  @override
  State<FavoritesPage> createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage> {
  late FavoritesManager _favoritesManager;
  late FavoritesSyncService _syncService;
  late ConnectivityService _connectivityService;

  List<FavoriteItem> _favorites = [];
  bool _isLoading = true;
  bool _isOnline = true;
  String? _removingPostId;

  @override
  void initState() {
    super.initState();
    _initializeServices();
    _loadFavorites();
  }

  Future<void> _initializeServices() async {
    _favoritesManager = FavoritesManager();
    await _favoritesManager.initialize();

    _connectivityService = ConnectivityService();
    _syncService = FavoritesSyncService(
      favoritesManager: _favoritesManager,
      connectivityService: _connectivityService,
    );

    await _syncService.startAutoSync();
    _checkConnectivity();
  }

  void _checkConnectivity() {
    _connectivityService.connectivityStream.listen((isConnected) {
      if (mounted) {
        setState(() {
          _isOnline = isConnected;
        });

        if (isConnected) {
          developer.log('Connection restored, refreshing favorites...');
          _refreshFavoritesFromFirebase();
        }
      }
    });
  }

  Future<void> _loadFavorites() async {
    try {
      // Cargar primero desde caché local
      List<FavoriteItem> cachedFavorites =
          await _favoritesManager.getAllFavorites();

      if (mounted) {
        setState(() {
          _favorites = cachedFavorites;
          _isLoading = false;
        });
      }

      // Si hay conexión, refrescar desde Firebase
      if (_isOnline) {
        await _refreshFavoritesFromFirebase();
      }
    } catch (e) {
      developer.log('Error loading favorites: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _refreshFavoritesFromFirebase() async {
    try {
      if (!_isOnline) return;

      await _syncService.refreshFavoritesFromFirebase();

      // Recargar desde caché actualizado
      List<FavoriteItem> updatedFavorites =
          await _favoritesManager.getAllFavorites();

      if (mounted) {
        setState(() {
          _favorites = updatedFavorites;
        });
      }

      developer.log('Favorites refreshed from Firebase');
    } catch (e) {
      developer.log('Error refreshing favorites: $e');
      if (mounted) {
        _showErrorSnackBar('Error al cargar favoritos');
      }
    }
  }

  Future<void> _removeFavorite(String postId) async {
    try {
      if (mounted) {
        setState(() {
          _removingPostId = postId;
        });
      }

      // Eliminar del caché y Firestore
      await _syncService.removeFavoriteWithSync(postId);

      // Actualizar lista local
      if (mounted) {
        setState(() {
          _favorites.removeWhere((fav) => fav.postId == postId);
          _removingPostId = null;
        });
      }

      developer.log('Favorite removed: $postId');
    } catch (e) {
      developer.log('Error removing favorite: $e');
      if (mounted) {
        setState(() {
          _removingPostId = null;
        });
        _showErrorSnackBar('Error al eliminar favorito');
      }
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.indianRed,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _navigateToHome() {
    Navigator.of(context).pushReplacementNamed('/home');
  }

  void _onBottomNavTap(int index) {
    switch (index) {
      case 0:
        Navigator.of(context).pushReplacementNamed('/home');
        break;
      case 1:
        Navigator.of(context).pushReplacementNamed('/search');
        break;
      case 2:
        Navigator.of(context).pushReplacementNamed('/messages');
        break;
      case 3:
        // Already on favorites page
        break;
      case 4:
        Navigator.of(context).pushReplacementNamed('/profile');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        title: Text(
          'Favoritos',
          style: AppTextStyles.tittleMedium,
        ),
        centerTitle: false,
      ),
      body: SafeArea(
        child: Stack(
          children: [
            // Contenido principal
            _isLoading ? _buildShimmerLoader() : _buildContent(),

            // Banner de offline
            if (!_isOnline)
              Positioned(
                left: 0,
                right: 0,
                bottom: 70,
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  color: Colors.orange,
                  child: const Text(
                    'Sin conexión - Los cambios se sincronizarán automáticamente',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: AppColors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: 3,
        onTap: _onBottomNavTap,
      ),
    );
  }

  Widget _buildContent() {
    if (_favorites.isEmpty) {
      return _buildEmptyState();
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Información de favoritos
          Text(
            '${_favorites.length} alojamiento${_favorites.length > 1 ? 's' : ''}',
            style: AppTextStyles.textRegular.copyWith(
              color: AppColors.coolGray,
            ),
          ),
          const SizedBox(height: 16),

          // Lista de favoritos
          ...List.generate(
            _favorites.length,
            (index) {
              FavoriteItem favorite = _favorites[index];
              bool isRemoving = _removingPostId == favorite.postId;

              return FavoritePostCard(
                key: ValueKey(favorite.postId),
                favorite: favorite,
                isRemoving: isRemoving,
                onTap: () {
                  Navigator.of(context).pushNamed(
                    '/post-detail',
                    arguments: favorite.postId,
                  );
                },
                onRemove: () => _removeFavorite(favorite.postId),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.favorite_border,
            size: 80,
            color: AppColors.lavender,
          ),
          const SizedBox(height: 24),
          Text(
            'Aún no tienes favoritos',
            style: AppTextStyles.tittleMedium.copyWith(
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Marca tus alojamientos favoritos para\nacceder rápidamente a ellos',
            textAlign: TextAlign.center,
            style: AppTextStyles.textRegular.copyWith(
              color: AppColors.coolGray,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: _navigateToHome,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
              backgroundColor: AppColors.violetBlue,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              'Explorar alojamientos',
              style: AppTextStyles.buttons.copyWith(fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShimmerLoader() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: List.generate(
          5,
          (index) => Shimmer.fromColors(
            baseColor: AppColors.lavenderLight,
            highlightColor: AppColors.white,
            child: Container(
              margin: const EdgeInsets.only(bottom: 12),
              height: 140,
              decoration: BoxDecoration(
                color: AppColors.lavenderLight,
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
