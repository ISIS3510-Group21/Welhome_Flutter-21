import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:welhome/core/constants/app_text_styles.dart';
import 'package:welhome/core/widgets/app_search_bar.dart';
import 'package:welhome/core/widgets/custom_bottom_nav_bar.dart';
import 'package:welhome/core/constants/app_colors.dart';
import 'package:welhome/core/widgets/category_card.dart';
import 'package:welhome/core/widgets/filter_chip_custom.dart';
import 'package:welhome/core/widgets/recommended_rail_horizontal.dart';

class FilterPage extends StatelessWidget {
  const FilterPage({super.key});

  @override
  Widget build(BuildContext context) {
    final products = [
      {
        'imageUrl':
            'https://images.unsplash.com/photo-1506744038136-46273834b3fb',
        'title': 'Portal de los Rosales',
        'rating': 4.95,
        'reviews': 22,
        'price': '\$700\'000',
      },
      {
        'imageUrl':
            'https://images.unsplash.com/photo-1512918728675-ed5a9ecdebfd',
        'title': 'Living 72',
        'rating': 4.95,
        'reviews': 25,
        'price': '\$700\'000',
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
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 🔹 Título
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Text(
                        'Filter by',
                        style: AppTextStyles.titleLarge,
                      ),
                    ),
                    const SizedBox(height: 12),

                    // 🔹 Categorías fila 1
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Row(
                        children: [
                          CategoryCard(
                            icon: Icons.house_rounded,
                            label: 'Houses',
                            onTap: () => debugPrint("Filtro: Houses"),
                          ),
                          const SizedBox(width: 8),
                          CategoryCard(
                            icon: Icons.meeting_room_rounded,
                            label: 'Rooms',
                            onTap: () => debugPrint("Filtro: Rooms"),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),

                    // 🔹 Categorías fila 2
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Row(
                        children: [
                          CategoryCard(
                            icon: Icons.cabin_rounded,
                            label: 'Cabins',
                            onTap: () => debugPrint("Filtro: Cabins"),
                          ),
                          const SizedBox(width: 8),
                          CategoryCard(
                            icon: Icons.apartment_rounded,
                            label: 'Apartments',
                            onTap: () => debugPrint("Filtro: Apartments"),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // 🔹 Filtros horizontales
                    SizedBox(
                      height: 48,
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Row(
                          children: [
                            FilterChipCustom(
                              label: 'Private Backyard',
                              selected: true,
                              onTap: () =>
                                  debugPrint("Filtro: Private Backyard"),
                            ),
                            FilterChipCustom(
                              label: 'Vape Free',
                              onTap: () => debugPrint("Filtro: Vape Free"),
                            ),
                            FilterChipCustom(
                              label: 'Car Parking',
                              onTap: () => debugPrint("Filtro: Car Parking"),
                            ),
                            FilterChipCustom(
                              label: 'Pet Friendly',
                              onTap: () => debugPrint("Filtro: Pet Friendly"),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // 🔹 Rail horizontal de productos
                    SizedBox(
                      height: 320,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: products.length,
                        separatorBuilder: (_, __) =>
                            const SizedBox(width: 16),
                        itemBuilder: (context, index) {
                          final product = products[index];
                          return ProductCard(
                            imageUrl: product['imageUrl'] as String,
                            title: product['title'] as String,
                            rating: product['rating'] as double,
                            reviews: product['reviews'] as int,
                            price: product['price'] as String,
                            onTap: () {},
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),

      // 🔹 Botón Map Search fijo abajo
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
          // 🔹 Bottom Nav fijo
          CustomBottomNavBar(
            currentIndex: 0,
            onTap: (index) {
              debugPrint("Navegaste al índice $index");
            },
          ),
        ],
      ),
    );
  }
}
