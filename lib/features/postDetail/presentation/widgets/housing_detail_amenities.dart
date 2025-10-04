import 'package:flutter/material.dart'; 
import 'package:welhome/core/constants/app_text_styles.dart';
import 'package:welhome/core/data/models/ammenities.dart';

class HousingDetailAmenities extends StatelessWidget {
  final List<Ammenities> amenities;

  const HousingDetailAmenities({super.key, required this.amenities});

  Widget _buildAmenityCard(String label) {
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
          // Placeholder para ícono
          Container(width: 24, height: 24, color: Colors.grey[300]),
          const SizedBox(width: 8),
          Text(
            label,
            style: const TextStyle(
              color: Color(0xFF191716),
              fontSize: 13,
              fontFamily: 'Inter',
              fontWeight: FontWeight.w600,
              letterSpacing: 0.20,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (amenities.isEmpty) {
      return const SizedBox.shrink();
    }

    final displayedAmenities = amenities.length > 4 ? amenities.sublist(0, 4) : amenities;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Título
          SizedBox(
            width: double.infinity,
            child: Text(
              'Amenities',
              style: AppTextStyles.tittleMedium,
            ),
          ),

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
