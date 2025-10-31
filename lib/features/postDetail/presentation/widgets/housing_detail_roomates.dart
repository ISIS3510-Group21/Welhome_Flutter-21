import 'package:flutter/material.dart';
import 'package:welhome/core/constants/app_text_styles.dart';
import 'package:welhome/features/housing/domain/entities/roomate_profile_entity.dart';
import 'dart:math';

class HousingDetailRoommates extends StatelessWidget {
  final List<RoomateProfileEntity> roommates;

  const HousingDetailRoommates({super.key, required this.roommates});

  @override
  Widget build(BuildContext context) {
    if (roommates.isEmpty) {
      return const SizedBox.shrink();
    }

    final List<String> assetImages = [
      'lib/assets/images/roommate1.png',
      'lib/assets/images/roommate2.png',
      'lib/assets/images/roommate3.png',
    ];

    final Random random = Random();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(top: 12, left: 16, right: 16),
      color: const Color(0xFFFCFCFC),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Roommates Profile',
            style: AppTextStyles.tittleMedium,
          ),
          const SizedBox(height: 4),

          SizedBox(
            height: 85,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: roommates.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final roommate = roommates[index];
                final String imagePath = assetImages[random.nextInt(assetImages.length)];

                return CircleAvatar(
                  radius: 35,
                  backgroundColor: const Color(0xFFEFF1F5),
                  backgroundImage: AssetImage(imagePath),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
