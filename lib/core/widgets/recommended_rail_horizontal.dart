import 'package:flutter/material.dart';
import '../data/models/housing_post.dart';
import 'housing_post_card.dart';

class RecommendedRailHorizontal extends StatelessWidget {
  final List<HousingPost> posts;

  const RecommendedRailHorizontal({super.key, required this.posts});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 285,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: posts.length,
        separatorBuilder: (_, __) => const SizedBox(width: 16),
        itemBuilder: (context, index) {
          final post = posts[index];
          return HousingPostCard(
            post: post,
            onTap: () {},
          );
        },
      ),
    );
  }
}
