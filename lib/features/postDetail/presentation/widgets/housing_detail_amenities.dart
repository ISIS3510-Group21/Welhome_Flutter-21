import 'package:flutter/material.dart'; 
import 'package:welhome/core/constants/app_text_styles.dart';
import 'package:welhome/features/housing/domain/entities/amenity_entity.dart';
import 'dart:math'; 

class HousingDetailAmenities extends StatelessWidget {
  final List<AmenityEntity> amenities;
  
  HousingDetailAmenities({super.key, required this.amenities});

  // Lista de íconos posibles
  static const List<IconData> amenityIcons = [
    Icons.home_outlined,
    Icons.local_florist_outlined,
    Icons.fitness_center_outlined,
    Icons.bed_outlined,
    Icons.bathtub_outlined,
    Icons.chair_outlined,
    Icons.kitchen_outlined, 
  ];

  final Random _random = Random(); 

  Widget _buildAmenityCard(String label) {
    final icon = amenityIcons[_random.nextInt(amenityIcons.length)];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: ShapeDecoration(
        shape: RoundedRectangleBorder(
          side: const BorderSide(width: 1, color: Color(0xFF9C9FCE)),
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Icon(icon, size: 24, color: Colors.black),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              label,
              style: const TextStyle(
                color: Color(0xFF191716),
                fontSize: 13,
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w600,
                letterSpacing: 0.20,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (amenities.isEmpty) return const SizedBox.shrink(); 

    final displayedAmenities =
        amenities.length > 4 ? amenities.sublist(0, 4) : amenities;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Amenities', style: AppTextStyles.tittleMedium), 
          const SizedBox(height: 12),
          LayoutBuilder(
            builder: (context, constraints) {
              final cardWidth = (constraints.maxWidth - 8) / 2;
              return Wrap(
                spacing: 8,
                runSpacing: 8,
                children: displayedAmenities 
                    .map((amenity) => SizedBox( 
                          width: cardWidth,
                          child: _buildAmenityCard(amenity.name),
                        ))
                    .toList(),
              );
            },
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 14),
            decoration: ShapeDecoration(
              color: const Color(0xFFE4E5F1),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Center(
              child: Text(
                'View All Amenities',
                style: TextStyle(
                  color: Color(0xFF191716),
                  fontSize: 16,
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w600,
                  height: 1.38,
                  letterSpacing: 0.20,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
