import 'package:flutter/material.dart';
import 'package:welhome/features/housing/domain/entities/housing_post_entity.dart';
import 'package:welhome/features/postDetail/presentation/pages/housing_detail_page.dart';
import 'housing_post_card.dart';

class RecommendedRailHorizontal extends StatelessWidget {
  final List<HousingPostEntity> posts;

  const RecommendedRailHorizontal({super.key, required this.posts});

  @override
  Widget build(BuildContext context) {
    if (posts.isEmpty) {
      return const Center(child: Text('No recommended posts available.'));
    }

    return SizedBox(
      height: 285,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: posts.length,
        separatorBuilder: (context, index) => const SizedBox(width: 16),
        itemBuilder: (context, index) {
          final post = posts[index];
          return HousingPostCard(
            post: post,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => HousingDetailPage(postId: post.id),
                ),
              );
            },
          );
        },
      ),
    );
  }
}