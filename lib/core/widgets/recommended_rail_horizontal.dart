import 'package:flutter/material.dart';
import 'package:welhome/core/constants/app_colors.dart';
import 'package:welhome/features/housing/domain/entities/housing_post_entity.dart';

class RecommendedRailHorizontal extends StatelessWidget {
  final List<HousingPostEntity> posts;

  const RecommendedRailHorizontal({Key? key, required this.posts}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (posts.isEmpty) {
      return const Center(child: Text('No recommended posts available.'));
    }

    return SizedBox(
      height: 285, // Altura fija para el carrusel
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: posts.length,
        separatorBuilder: (context, index) => const SizedBox(width: 16),
        itemBuilder: (context, index) {
          final post = posts[index];
          return _buildRecommendedPostCard(context, post);
        },
      ),
    );
  }

  Widget _buildRecommendedPostCard(BuildContext context, HousingPostEntity post) {
    // Este es un ejemplo básico de cómo podrías mostrar un post.
    // Deberías adaptarlo a tu diseño real de tarjeta de post.
    return Container(
      width: 280,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            child: Image.network(
              post.pictures.isNotEmpty ? post.pictures.first.photoPath : 'https://via.placeholder.com/280x180',
              height: 180,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(post.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Text('\$${post.price.toStringAsFixed(0)} / month', style: const TextStyle(color: AppColors.violetBlue)),
          ),
        ],
      ),
    );
  }
}