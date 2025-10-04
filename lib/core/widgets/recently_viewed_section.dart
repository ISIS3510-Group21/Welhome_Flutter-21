import 'package:flutter/material.dart';
import 'package:welhome/core/data/models/housing_post.dart';
import 'recently_viewed_item.dart';

class RecentlyViewedSection extends StatelessWidget {
  final List<HousingPost> posts;

  const RecentlyViewedSection({super.key, required this.posts});

  @override
  Widget build(BuildContext context) {
    if (posts.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.0),
          child: Text(
            'Recently seen',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
          ),
        ),
        const SizedBox(height: 12),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: posts.length,
          itemBuilder: (context, index) {
            final post = posts[index];
            return Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: RecentlyViewedItem(
                post: post,
                onTap: () {
                  // Navegar al detalle del post
                },
              ),
            );
          },
        ),
      ],
    );
  }
}

