import 'package:flutter/material.dart';
import 'package:welhome/core/constants/app_colors.dart';
import 'package:welhome/core/constants/app_text_styles.dart';
import 'package:welhome/core/data/models/favorite_item.dart';

class FavoritePostCard extends StatelessWidget {
  final FavoriteItem favorite;
  final VoidCallback? onTap;
  final VoidCallback onRemove;
  final bool isRemoving;

  const FavoritePostCard({
    super.key,
    required this.favorite,
    this.onTap,
    required this.onRemove,
    this.isRemoving = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isRemoving ? null : onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.lavenderLight, width: 1),
        ),
        child: Stack(
          children: [
            Row(
              children: [
                // Imagen
                ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(12),
                    bottomLeft: Radius.circular(12),
                  ),
                  child: SizedBox(
                    width: 140,
                    height: 140,
                    child: Image.network(
                      favorite.thumbnailUrl ?? '',
                      fit: BoxFit.cover,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Container(
                          color: AppColors.lavenderLight,
                          child: const Center(
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                AppColors.violetBlue,
                              ),
                            ),
                          ),
                        );
                      },
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: AppColors.lavenderLight,
                          child: const Icon(
                            Icons.image_not_supported,
                            color: AppColors.coolGray,
                          ),
                        );
                      },
                    ),
                  ),
                ),
                // Contenido
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Título
                        Text(
                          favorite.title,
                          style: AppTextStyles.tittleSmall,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        // Dirección
                        Row(
                          children: [
                            const Icon(
                              Icons.location_on_outlined,
                              size: 14,
                              color: AppColors.coolGray,
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                favorite.address,
                                style: AppTextStyles.textSmall.copyWith(
                                  color: AppColors.coolGray,
                                  fontSize: 12,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        // Rating y Precio
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                const Icon(
                                  Icons.star,
                                  size: 14,
                                  color: AppColors.black,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  favorite.rating.toStringAsFixed(1),
                                  style: AppTextStyles.textSmall.copyWith(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '(${favorite.reviewQuantity})',
                                  style: AppTextStyles.textSmall.copyWith(
                                    color: AppColors.coolGray,
                                    fontSize: 11,
                                  ),
                                ),
                              ],
                            ),
                            Text(
                              '\$${favorite.price.toInt()}/mo',
                              style: AppTextStyles.tittleSmall.copyWith(
                                color: AppColors.violetBlue,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            // Botón de eliminar (esquina superior derecha)
            Positioned(
              top: 8,
              right: 8,
              child: GestureDetector(
                onTap: isRemoving ? null : onRemove,
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.lavenderLight, width: 1),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.all(8),
                  child: isRemoving
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              AppColors.violetBlue,
                            ),
                          ),
                        )
                      : const Icon(
                          Icons.close,
                          size: 16,
                          color: AppColors.indianRed,
                        ),
                ),
              ),
            ),
            // Indicador de pendiente de sincronización
            if (favorite.pendingSync)
              Positioned(
                bottom: 8,
                left: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.orange.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SizedBox(
                        width: 10,
                        height: 10,
                        child: CircularProgressIndicator(
                          strokeWidth: 1.5,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.orange,
                          ),
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Sincronizando...',
                        style: AppTextStyles.textSmall.copyWith(
                          fontSize: 10,
                          color: Colors.orange,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
