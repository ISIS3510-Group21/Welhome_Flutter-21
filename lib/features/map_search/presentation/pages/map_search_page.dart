import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:welhome/core/widgets/app_search_bar.dart';
import 'package:welhome/core/widgets/custom_bottom_nav_bar.dart';
import 'package:welhome/core/constants/app_colors.dart';
import 'package:welhome/core/constants/app_text_styles.dart';
import 'package:welhome/core/widgets/item_post_list.dart';

class MapSearchPage extends StatefulWidget {
  const MapSearchPage({super.key});

  @override
  State<MapSearchPage> createState() => _MapSearchPageState();
}

class _MapSearchPageState extends State<MapSearchPage> {
  GoogleMapController? _mapController;
  LatLng? _userLocation; // 🔥 ubicación dinámica del usuario

  @override
  void initState() {
    super.initState();
    _getUserLocation();
  }

  Future<void> _getUserLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return;

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        return;
      }
    }

    final position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    setState(() {
      _userLocation = LatLng(position.latitude, position.longitude);
    });
  }

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
                height: 325,
                width: double.infinity,
                child: _userLocation == null
                    ? const Center(child: CircularProgressIndicator())
                    : GoogleMap(
                        initialCameraPosition: CameraPosition(
                          target: _userLocation!,
                          zoom: 14,
                        ),
                        markers: {
                          Marker(
                            markerId: const MarkerId("user_location"),
                            position: _userLocation!,
                            infoWindow: const InfoWindow(
                              title: "Tu ubicación",
                            ),
                          ),
                        },
                        onMapCreated: (controller) {
                          _mapController = controller;
                        },
                      ),
              ),
            ),

            // 👉 Lista de ítems mockeada
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: const [
                  ItemPostList(
                    title: "Portal de los Rosales",
                    rating: 4.95,
                    price: "\$700’000 /month",
                    imageUrl:
                        "https://images.unsplash.com/photo-1512918728675-ed5a9ecdebfd",
                  ),
                  SizedBox(height: 12),
                  ItemPostList(
                    title: "Parque Central Bavaria",
                    rating: 4.75,
                    price: "\$850’000 /month",
                    imageUrl:
                        "https://images.unsplash.com/photo-1512918728675-ed5a9ecdebfd",
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


