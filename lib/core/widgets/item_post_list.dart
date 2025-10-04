import 'package:flutter/material.dart';
import 'package:welhome/core/constants/app_colors.dart';
import 'package:welhome/core/constants/app_text_styles.dart';

class ItemPostList extends StatelessWidget {
  final String title;
  final String? imageUrl;
  final String? placeholderAsset; // NUEVO
  final double rating;
  final String price;
  final String? subtitle;
  final VoidCallback? onTap;

  const ItemPostList({
    super.key,
    required this.title,
    this.imageUrl,
    this.placeholderAsset,
    required this.rating,
    required this.price,
    this.subtitle,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final hasNetworkImage = imageUrl != null && imageUrl!.isNotEmpty;
    final imageProvider = hasNetworkImage
        ? NetworkImage(imageUrl!)
        : (placeholderAsset != null
            ? AssetImage(placeholderAsset!)
            : AssetImage('assets/images/fallback1.jpg')) as ImageProvider;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: double.infinity,
        height: 126,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Imagen
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                image: DecorationImage(
                  image: imageProvider,
                  fit: BoxFit.cover,
                ),
              ),
            ),

            const SizedBox(width: 12),

            // Texto
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.tittleMedium,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.star, color: AppColors.black, size: 20),
                      const SizedBox(width: 4),
                      Text(
                        rating.toStringAsFixed(2),
                        style: AppTextStyles.tittleSmall,
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    price,
                    style: AppTextStyles.textRegular,
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      subtitle!,
                      style: AppTextStyles.textSmall.copyWith(
                        color: AppColors.coolGray,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
