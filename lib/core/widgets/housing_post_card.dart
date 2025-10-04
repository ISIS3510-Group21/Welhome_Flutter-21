import 'package:flutter/material.dart';
import 'package:welhome/core/data/models/housing_post.dart';
import '../constants/app_colors.dart';
import '../constants/app_text_styles.dart';

class HousingPostCard extends StatelessWidget {
  final HousingPost post;
  final VoidCallback? onTap;

  const HousingPostCard({
    super.key,
    required this.post,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 280,
        margin: const EdgeInsets.symmetric(horizontal: 4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.network(
                post.pictures.isNotEmpty
                    ? post.pictures.first.photoPath
                    : '', // dejamos vacío para que siempre use placeholder si no hay URL
                height: 180,
                width: double.infinity,
                fit: BoxFit.cover,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Container(
                    height: 180,
                    width: double.infinity,
                    color: Colors.grey[300],
                    child: const Center(child: CircularProgressIndicator()),
                  );
                },
                errorBuilder: (context, error, stackTrace) {
                  return Image.asset(
                    'lib/assets/images/fallback1.jpg',
                    height: 180,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  );
                },
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    post.title,
                    style: AppTextStyles.tittleSmall,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.star, color: AppColors.black, size: 18),
                      const SizedBox(width: 4),
                      Text(
                        post.rating.toStringAsFixed(2),
                        style: AppTextStyles.textRegular.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '4 reviews',
                        style: AppTextStyles.textSmall.copyWith(
                          color: AppColors.coolGray,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '\$${post.price.toInt()} /month',
                    style: AppTextStyles.textRegular,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

