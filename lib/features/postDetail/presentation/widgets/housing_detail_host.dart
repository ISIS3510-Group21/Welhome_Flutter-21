import 'package:flutter/material.dart';
import 'package:welhome/core/constants/app_colors.dart';
import 'package:welhome/core/constants/app_text_styles.dart';

class HousingDetailHost extends StatelessWidget {
  final String hostName;

  const HousingDetailHost({super.key, required this.hostName});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(top: 8, left: 16, right: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Host',
            style: AppTextStyles.tittleMedium ,
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  image: DecorationImage(
                    image: const AssetImage('lib/assets/images/profile_pic_owner.png'),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(width: 12),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      hostName,
                      style: AppTextStyles.tittleSmall,
                    ),
                    const SizedBox(height: 2),
                    const Text(
                      'World-renowned startup founder',
                      style: TextStyle(
                        color: AppColors.coolGray,
                        fontSize: 14,
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w400,
                        height: 1.43,
                      ),
                    ),
                  ],
                ),
              ),

              IconButton(
                onPressed: () {
                },
                icon: const Icon(
                  Icons.phone_outlined,
                  color: Colors.black,
                ),
              ),
              IconButton(
                onPressed: () {
                },
                icon: const Icon(
                  Icons.chat_bubble_outline,
                  color: Colors.black,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

