import 'package:flutter/material.dart';
import '../constants/app_text_styles.dart';
import 'recently_viewed_item.dart';

class RecentlyViewedSection extends StatelessWidget {
  final List<Map<String, dynamic>> recentItems;

  const RecentlyViewedSection({
    super.key,
    required this.recentItems,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 🔹 Título
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.0),
          child: Text(
            'Recently seen',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const SizedBox(height: 12),

        // 🔹 Lista vertical SIN Expanded
        ListView.builder(
          shrinkWrap: true, // Para que tome solo el espacio que necesita
          physics: const NeverScrollableScrollPhysics(), // El scroll lo maneja el padre (SingleChildScrollView)
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: recentItems.length,
          itemBuilder: (context, index) {
            final item = recentItems[index];
            return Padding(
              padding: const EdgeInsets.only(bottom: 16.0), // separa los items
              child: RecentlyViewedItem(
                imageUrl: item['imageUrl'],
                title: item['title'],
                rating: item['rating'],
                reviews: item['reviews'],
                price: item['price'],
                onTap: () {},
              ),
            );
          },
        ),
      ],
    );
  }
}
