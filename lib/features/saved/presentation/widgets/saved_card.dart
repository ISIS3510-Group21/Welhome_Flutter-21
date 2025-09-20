import 'package:flutter/material.dart';
import 'package:welhome/core/constants/app_colors.dart';


class SavedItemCard extends StatelessWidget {
  final String imageUrl;
  final String title;
  final double rating;
  final String price;

  const SavedItemCard({
    super.key,
    required this.imageUrl,
    required this.title,
    required this.rating,
    required this.price,
  });

  List<Widget> _buildStars(double rating) {
    const int maxStars = 5;
    List<Widget> stars = [];
    for (int i = 1; i <= maxStars; i++) {
      if (rating >= i) {
        stars.add(const Icon(Icons.star, color: AppColors.black, size: 20));
      } else if (rating >= i - 0.5) {
        stars.add(const Icon(Icons.star_half, color: AppColors.black, size: 20));
      } else {
        stars.add(const Icon(Icons.star_border, color: AppColors.black, size: 20));
      }
    }
    return stars;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Image.network(
              imageUrl,
              width: double.infinity,
              height: 219,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(height: 8),

          Text(
            title,
            style: const TextStyle(
              color: Color(0xFF191716),
              fontSize: 16,
              fontWeight: FontWeight.w600,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 4),

          Row(
            children: [
              Row(children: _buildStars(rating)),
              const SizedBox(width: 6),
              Text(
                rating.toStringAsFixed(2),
                style: const TextStyle(
                  color: Color(0xFF191716),
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),

          Text(
            price,
            style: const TextStyle(
              color: Color(0xFF191716),
              fontSize: 14,
              fontWeight: FontWeight.w400,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}
