import 'package:flutter/material.dart';
import 'package:welhome/core/constants/app_text_styles.dart';
import 'package:welhome/core/data/models/housing_post.dart';

class HousingDetailRoommates extends StatelessWidget {
  final List<RoomateProfile> roommates;

  const HousingDetailRoommates({super.key, required this.roommates});

  @override
  Widget build(BuildContext context) {
    if (roommates.isEmpty) {
      return const SizedBox.shrink();
    }

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

                return CircleAvatar(
                  radius: 35,
                  backgroundColor: const Color(0xFFEFF1F5),
                  backgroundImage: NetworkImage(
                    roommate.studentUserID.isNotEmpty
                        ? "https://placehold.co/70x70" 
                        : "https://placehold.co/70x70",
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
