import 'package:flutter/material.dart';
import 'package:welhome/core/constants/app_colors.dart';
import 'package:welhome/core/constants/app_text_styles.dart';
import 'package:welhome/features/housing/domain/entities/housing_post_entity.dart';

class RecentlyViewedSection extends StatelessWidget {
  final List<HousingPostEntity> posts;

  const RecentlyViewedSection({Key? key, required this.posts}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (posts.isEmpty) {
      return const SizedBox.shrink(); // O un mensaje de "No hay posts vistos recientemente"
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          child: Text(
            'Recently Viewed',
            style: AppTextStyles.titleLarge,
          ),
        ),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: posts.length,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemBuilder: (context, index) {
            final post = posts[index];
            return _buildRecentlyViewedCard(context, post);
          },
        ),
      ],
    );
  }

  Widget _buildRecentlyViewedCard(BuildContext context, HousingPostEntity post) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                post.pictures.isNotEmpty ? post.pictures.first.photoPath : 'https://via.placeholder.com/100x100',
                width: 100,
                height: 100,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(post.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  Text(post.address, style: TextStyle(color: Colors.grey[600])),
                  Text('\$${post.price.toStringAsFixed(0)} / month', style: const TextStyle(color: AppColors.violetBlue, fontWeight: FontWeight.w600)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}