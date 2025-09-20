import 'package:flutter/material.dart';
import 'package:welhome/core/widgets/app_search_bar.dart';
import 'package:welhome/core/widgets/custom_bottom_nav_bar.dart';
import 'package:welhome/core/constants/app_colors.dart';
import 'package:welhome/core/widgets/recommended_rail_horizontal.dart';
import 'package:welhome/core/widgets/recently_viewed_section.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: SingleChildScrollView( // 🔹 Scroll en toda la página
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: AppSearchBar(),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Recommended for you',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.notifications_none, size: 28),
                      onPressed: () {},
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 285,
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
              RecentlyViewedSection(
                recentItems: recentlyViewedProducts,
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: 0,
        onTap: (index) {
          debugPrint("Navegaste al índice $index");
        },
      ),
    );
  }
}

// Ejemplo de productos
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

final recentlyViewedProducts = [
  {
    'imageUrl': 'https://images.unsplash.com/photo-1512917774080-9991f1c4c750',
    'title': 'Living 72',
    'rating': 4.95,
    'reviews': 25,
    'price': '\$700\'000',
  },
  {
    'imageUrl': 'https://images.unsplash.com/photo-1513584684374-8bab748fbf90',
    'title': 'Portal de los Rosales',
    'rating': 4.95,
    'reviews': 22,
    'price': '\$700\'000',
  },
];
