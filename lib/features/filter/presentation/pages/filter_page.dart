import 'package:flutter/material.dart';
import 'package:welhome/core/constants/app_colors.dart';
import 'package:welhome/core/widgets/app_search_bar.dart';
import 'package:welhome/core/widgets/custom_bottom_nav_bar.dart';
import 'package:welhome/core/widgets/filter_chip_custom.dart';
import 'package:welhome/core/widgets/recommended_rail_horizontal.dart';

class FilterPage extends StatelessWidget {
  const FilterPage({super.key});

  static final List<Map<String, dynamic>> typeFilters = [
    {'label': 'Houses', 'icon': Icons.home},
    {'label': 'Rooms', 'icon': Icons.bed},
    {'label': 'Cabins', 'icon': Icons.cabin},
    {'label': 'Apartments', 'icon': Icons.apartment},
  ];

  static final List<Map<String, dynamic>> amenityFilters = [
    {'label': 'Private Backyard', 'icon': Icons.yard},
    {'label': 'Vape Free', 'icon': Icons.smoke_free},
    {'label': 'Car Parking', 'icon': Icons.local_parking},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: AppSearchBar(),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                'Filter by',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Wrap(
                spacing: 12,
                runSpacing: 12,
                children: typeFilters.map((filter) {
                  return FilterChipCustom(
                    label: filter['label'] as String,
                    isSelected: false,
                    onTap: () {},
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Wrap(
                spacing: 12,
                runSpacing: 12,
                children: amenityFilters.map((filter) {
                  return FilterChipCustom(
                    label: filter['label'] as String,
                    isSelected: false,
                    onTap: () {},
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 320,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: products.length,
                separatorBuilder: (_, __) => const SizedBox(width: 16),
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
            const Spacer(),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.violetBlue,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () {},
                  child: const Text(
                    'Map Search',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: 1, // Asumiendo que esta es la segunda pestaña
        onTap: (index) {
          debugPrint("Navegaste al índice $index");
        },
      ),
    );
  }
}

// Reutilizamos los mismos datos de ejemplo
final products = [
  {
    'imageUrl': 'https://images.unsplash.com/photo-1506744038136-46273834b3fb',
    'title': 'Portal de los Rosales',
    'rating': 4.95,
    'reviews': 22,
    'price': '\$700\'000',
  },
  {
    'imageUrl': 'https://images.unsplash.com/photo-1512918728675-ed5a9ecdebfd',
    'title': 'Living 72',
    'rating': 4.95,
    'reviews': 25,
    'price': '\$700\'000',
  },
];