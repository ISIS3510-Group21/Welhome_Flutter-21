import 'package:flutter/material.dart';
import 'package:welhome/core/constants/app_colors.dart';
import 'package:welhome/core/constants/app_text_styles.dart';

class ItemPostList extends StatelessWidget {
  final String title;
  final String? imageUrl;
  final double rating;
  final String price;
  final bool useColorPlaceholder;

  const ItemPostList({
    super.key,
    required this.title,
    this.imageUrl,
    required this.rating,
    required this.price,
    this.useColorPlaceholder = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 121,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: useColorPlaceholder ? AppColors.coolGray : null,
              borderRadius: BorderRadius.circular(12),
              image: (!useColorPlaceholder && imageUrl != null)
                  ? DecorationImage(
                      image: NetworkImage(imageUrl!),
                      fit: BoxFit.cover,
                    )
                  : null,
            ),
          ),

          const SizedBox(width: 12),

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
              ],
            ),
          ),
        ],
      ),
    );
  }
}

