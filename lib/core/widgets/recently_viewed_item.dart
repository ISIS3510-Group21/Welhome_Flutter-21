import 'package:flutter/material.dart';
import 'package:welhome/core/constants/app_text_styles.dart';
import 'package:welhome/core/data/models/housing_post.dart';

class RecentlyViewedItem extends StatelessWidget {
  final HousingPost post;
  final VoidCallback? onTap;

  const RecentlyViewedItem({
    super.key,
    required this.post,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final imageUrl = post.pictures.isNotEmpty
        ? post.pictures.first.photoPath
        : 'lib/assets/images/fallback2.jpg';

    int filledStars = post.rating.floor();
    int emptyStars = 5 - filledStars;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.only(top: 12, left: 16, right: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Imagen con placeholder
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.network(
                imageUrl,
                width: double.infinity,
                height: 219,
                fit: BoxFit.cover,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Container(
                    width: double.infinity,
                    height: 219,
                    color: Colors.grey[300],
                    child: const Center(child: CircularProgressIndicator()),
                  );
                },
                errorBuilder: (context, error, stackTrace) {
                  return Image.asset(
                    'lib/assets/images/fallback2.jpg',
                    width: double.infinity,
                    height: 219,
                    fit: BoxFit.cover,
                  );
                },
              ),
            ),
            const SizedBox(height: 8),
            // Título
            Text(
              post.title,
              style: AppTextStyles.tittleMedium,
            ),
            const SizedBox(height: 4),
            // Estrellas usando Icons
            Row(
              children: [
                Row(
                  children: [
                    for (int i = 0; i < filledStars; i++) ...[
                      const Icon(Icons.star, size: 20, color: Colors.black),
                      const SizedBox(width: 4),
                    ],
                    for (int i = 0; i < emptyStars; i++) ...[
                      const Icon(Icons.star, size: 20, color: Color(0xFFE4E5F1)),
                      const SizedBox(width: 4),
                    ],
                  ],
                ),
                const SizedBox(width: 8),
                Text(
                  post.rating.toStringAsFixed(2),
                  style: AppTextStyles.tittleSmall,
                ),
              ],
            ),
            const SizedBox(height: 4),
            // Precio
            Text(
              '\$${post.price.toInt()} /month',
              style: AppTextStyles.textRegular,
            ),
          ],
        ),
      ),
    );
  }
}
