import 'dart:math';
import 'package:flutter/material.dart';
import 'package:welhome/core/constants/app_text_styles.dart';

class HousingDetailHeader extends StatelessWidget {
  final List<String> imageUrls;
  final double rating;
  final int reviewsCount;
  final String title;
  final double price;

  const HousingDetailHeader({
    super.key,
    required this.imageUrls,
    required this.rating,
    required this.reviewsCount,
    required this.title,
    required this.price,
  });

  @override
  Widget build(BuildContext context) {
    final List<String> fallbackAssets = [
      'lib/assets/images/fallback1.jpg',
      'lib/assets/images/fallback2.jpg',
    ];
    final Random random = Random();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 212,
          width: double.infinity,
          child: PageView.builder(
            itemCount: imageUrls.length,
            itemBuilder: (context, index) {
              return Image.network(
                imageUrls[index],
                fit: BoxFit.cover,
                width: double.infinity,
                errorBuilder: (context, error, stackTrace) {
                  final fallback = fallbackAssets[random.nextInt(fallbackAssets.length)];
                  return Image.asset(
                    fallback,
                    fit: BoxFit.cover,
                    width: double.infinity,
                  );
                },
              );
            },
          ),
        ),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          color: const Color(0xFFFCFCFC),
          child: Row(
            children: [
              const Icon(Icons.star, color: Colors.black, size: 20),
              const SizedBox(width: 4),
              Text(
                rating.toStringAsFixed(2),
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 16,
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w600,
                  height: 1.5,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                "$reviewsCount reviews",
                style: const TextStyle(
                  color: Color(0xFF3B429F),
                  fontSize: 16,
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w400,
                  decoration: TextDecoration.underline,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            title,
            style: AppTextStyles.tittleMedium.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            '\$$price /month',
            style: AppTextStyles.textRegular,
          ),
        ),
      ],
    );
  }
}
