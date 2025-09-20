import 'package:flutter/material.dart';
import 'package:welhome/core/widgets/app_search_bar.dart';
import 'package:welhome/core/widgets/custom_bottom_nav_bar.dart';
import 'package:welhome/core/constants/app_colors.dart';
import 'package:welhome/core/constants/app_text_styles.dart';
import 'package:welhome/core/widgets/item_post_list.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class MapSearchPage extends StatelessWidget {
  const MapSearchPage({super.key});

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

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                'Map Search',
                style: AppTextStyles.titleLarge,
              ),
            ),
            
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: SizedBox(
                height: 200,
                width: double.infinity,
                child: FlutterMap(
                  options: const MapOptions(
                    initialCenter: LatLng(4.7110, -74.0721), // Bogotá
                    initialZoom: 12,
                  ),
                  children: [
                    TileLayer(
                      urlTemplate:
                          "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
                      userAgentPackageName: "com.example.welhome",
                    ),
                  ],
                ),
              ),
            ),

            // 👉 Lista de ítems (mockeada)
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: const [
                  ItemPostList(
                    title: "Portal de los Rosales",
                    rating: 4.95,
                    price: "\$700’000 /month",
                    useColorPlaceholder: true,
                  ),
                  SizedBox(height: 12),
                  ItemPostList(
                    title: "Parque Central Bavaria",
                    rating: 4.75,
                    price: "\$850’000 /month",
                    useColorPlaceholder: true,
                  ),
                  SizedBox(height: 12),
                  ItemPostList(
                    title: "La Candelaria Colonial",
                    rating: 4.88,
                    price: "\$1’200’000 /month",
                    useColorPlaceholder: true,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),

      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: 3,
        onTap: (index) {
          debugPrint("Navegaste al índice $index");
        },
      ),
    );
  }
}

