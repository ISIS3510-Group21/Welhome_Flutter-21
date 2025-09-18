import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/app_colors.dart';

class AppSearchBar extends StatelessWidget {
  final String hintText;
  final VoidCallback? onTap;
  final ValueChanged<String>? onChanged;

  const AppSearchBar({
    super.key,
    this.hintText = "Search",
    this.onTap,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(
        top: 10,
        left: 16,
        right: 16,
        bottom: 10,
      ),
      decoration: ShapeDecoration(
        color: AppColors.lavenderLight,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(32),
        ),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.search,
            color: AppColors.coolGray,
            size: 24,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              onTap: onTap,
              onChanged: onChanged,
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w400,
                color: AppColors.black,
              ),
              decoration: InputDecoration(
                hintText: hintText,
                hintStyle: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                  color: AppColors.coolGray,
                ),
                border: InputBorder.none,
                isCollapsed: true, 
              ),
            ),
          ),
        ],
      ),
    );
  }
}
