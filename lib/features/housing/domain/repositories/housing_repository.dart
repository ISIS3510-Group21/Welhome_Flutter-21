import 'package:welhome/features/housing/domain/entities/housing_post_entity.dart';

/// El Contrato del Repositorio.
/// Define las operaciones de datos para el dominio 'housing' de forma abstracta.
/// La capa de dominio (UseCases) dependerá de este contrato, no de la implementación.
abstract class HousingRepository {
  /// Obtiene una lista de alojamientos recomendados para la página de inicio.
  /// Podría ser una lista de los posts mejor calificados o más nuevos.
  Future<List<HousingPostEntity>> getRecommendedPosts();

  /// Obtiene una lista de alojamientos vistos recientemente por un usuario específico.
  Future<List<HousingPostEntity>> getRecentlyViewedPosts({
    required String userId,
  });

  /// Obtiene todos los detalles de un único alojamiento por su ID.
  /// Devuelve `null` si el post no se encuentra.
  Future<HousingPostEntity?> getPostDetails({
    required String postId,
  });

  /// Busca alojamientos cerca de una ubicación geográfica dada.
  /// El filtrado por radio se hará en la capa de presentación o en el UseCase.
  Future<List<HousingPostEntity>> findPostsNearLocation({
    required double lat,
    required double lng,
    required double radiusInKm,
  });

  // Podrías añadir más métodos según tus necesidades, como para filtros.
  // Future<List<HousingPostEntity>> getFilteredPosts({...});
}