import 'dart:math';
import 'package:flutter/material.dart';
import 'package:welhome/core/constants/app_text_styles.dart';
import 'package:welhome/features/housing/domain/entities/housing_post_entity.dart';

class HousingDetailHeader extends StatelessWidget {
  final HousingPostEntity post;

  const HousingDetailHeader({
    super.key,
    required this.post,
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
        if (post.pictures.isNotEmpty)
          SizedBox(
            height: 212,
            width: double.infinity,
            child: PageView.builder(
              itemCount: post.pictures.length,
              itemBuilder: (context, index) {
                return Image.network(
                  post.pictures[index].photoPath,
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
          )
        else
          Container(
            height: 212,
            width: double.infinity,
            color: Colors.grey[300],
            alignment: Alignment.center,
            child: const Text("No images available"),
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
                post.reviews.rating.toStringAsFixed(2),
                style: AppTextStyles.tittleSmall.copyWith(
                  color: Colors.black,
                  fontSize: 16,
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w600,
                  height: 1.5,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                "${post.reviews.reviewQuantity} reviews", // Usando la propiedad de la entidad
                style: AppTextStyles.textRegular.copyWith(
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
            post.title,
            style: AppTextStyles.tittleMedium.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            '\$${post.price.toStringAsFixed(0)} /month',
            style: AppTextStyles.textRegular,
          ),
        ),
      ],
    );
  }
}
