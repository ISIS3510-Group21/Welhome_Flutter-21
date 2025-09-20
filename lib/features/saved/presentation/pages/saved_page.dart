import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:welhome/core/widgets/app_search_bar.dart';
import 'package:welhome/core/widgets/custom_bottom_nav_bar.dart';
import 'package:welhome/core/constants/app_colors.dart';
import 'package:welhome/core/constants/app_text_styles.dart';
import 'package:welhome/features/saved/presentation/widgets/saved_card.dart';

class SavedPage extends StatelessWidget {
  const SavedPage({super.key});

  @override
  Widget build(BuildContext context) {
    final savedProperties = [
      {
        'imageUrl':
            'https://images.unsplash.com/photo-1512918728675-ed5a9ecdebfd',
        'title': 'Living 72',
        'rating': 4.95,
        'price': '\$700’000 /month',
      },
      {
        'imageUrl':
            'https://images.unsplash.com/photo-1506744038136-46273834b3fb',
        'title': 'Portal de los Rosales',
        'rating': 4.90,
        'price': '\$650’000 /month',
      },
    ];

    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: AppSearchBar(),
            ),

            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                itemCount: savedProperties.length + 1,
                itemBuilder: (context, index) {
                  if (index == 0) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12.0),
                      child: Text(
                        'Saved Posts',
                        style: AppTextStyles.titleLarge,
                      ),
                    );
                  }

                  final item = savedProperties[index - 1];
                  return SavedItemCard(
                    imageUrl: item['imageUrl'] as String,
                    title: item['title'] as String,
                    rating: item['rating'] as double,
                    price: item['price'] as String,
                  );
                },
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
            child: SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.violetBlue,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                onPressed: () {
                  debugPrint("Navegar a Map Search");
                },
                child: Text(
                  'Map Search',
                  style: GoogleFonts.poppins(
                    color: AppColors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
          CustomBottomNavBar(
            currentIndex: 1,
            onTap: (index) {
              debugPrint("Navegaste al índice $index");
            },
          ),
        ],
      ),
    );
  }
}
