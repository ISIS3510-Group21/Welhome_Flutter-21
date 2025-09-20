import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:welhome/core/constants/app_colors.dart';

class FilterChipCustom extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback? onTap;

  const FilterChipCustom({
    super.key,
    required this.label,
    this.selected = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        margin: const EdgeInsets.only(right: 8),
        decoration: ShapeDecoration(
          color: selected ? AppColors.violetBlue : AppColors.lavenderLight,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            height: 1.38,
            color: selected ? AppColors.white : AppColors.black,
          ),
        ),
      ),
    );
  }
}
