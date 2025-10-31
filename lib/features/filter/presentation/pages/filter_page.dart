import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:welhome/core/constants/app_text_styles.dart';
import 'package:welhome/core/widgets/app_search_bar.dart';
import 'package:welhome/core/widgets/custom_bottom_nav_bar.dart';
import 'package:welhome/core/constants/app_colors.dart';
import 'package:welhome/core/widgets/category_card.dart';
import 'package:welhome/core/widgets/filter_chip_custom.dart';
import 'package:welhome/core/widgets/product_card.dart';
import 'package:welhome/features/filter/data/services/property_service.dart';
import 'package:welhome/features/filter/domain/entities/property.dart';

class FilterPage extends StatefulWidget {
  const FilterPage({super.key});

  @override
  State<FilterPage> createState() => _FilterPageState();
}

class _FilterPageState extends State<FilterPage> {
  final PropertyService _propertyService = PropertyService();
  List<Property> _properties = [];
  final List<String> _selectedAmenities = [];
  final List<String> _selectedHousingTags = [];
  Map<String, dynamic> _availableTags = {
    'amenities': <dynamic>[],
    'housingTags': <dynamic>[],
  };

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    final tags = await _propertyService.getAllTags();
    final properties = await _propertyService.getProperties();

    setState(() {
      _availableTags = tags;
      _properties = properties;
    });
  }

  void _updateFilters() async {
    final filteredProperties = await _propertyService.getProperties(
      selectedAmenities: _selectedAmenities,
      selectedHousingTags: _selectedHousingTags,
    );

    setState(() {
      _properties = filteredProperties;
    });
  }

  void _toggleHousingTag(String tag) {
    setState(() {
      if (_selectedHousingTags.contains(tag)) {
        _selectedHousingTags.remove(tag);
      } else {
        _selectedHousingTags.add(tag);
      }
    });
    _updateFilters();
  }

  void _toggleAmenity(String amenity) {
    setState(() {
      if (_selectedAmenities.contains(amenity)) {
        _selectedAmenities.remove(amenity);
      } else {
        _selectedAmenities.add(amenity);
      }
    });
    _updateFilters();
  }

  IconData _getIconForHousingType(String type) {
    switch (type) {
      case 'House':
        return Icons.house_rounded;
      case 'Room':
        return Icons.meeting_room_rounded;
      case 'Cabin':
        return Icons.cabin_rounded;
      case 'Apartment':
        return Icons.apartment_rounded;
      default:
        return Icons.home_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const AppSearchBar(),
                  const SizedBox(height: 16),
                  Text(
                    'Filters',
                    style: AppTextStyles.titleLarge,
                  ),
                  const SizedBox(height: 16),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        // Housing Type Filters
                        ...(_availableTags['housingTags'] as List<dynamic>? ?? [])
                            .map((tag) => Padding(
                                  padding: const EdgeInsets.only(right: 8),
                                  child: FilterChipCustom(
                                    label: tag.toString(),
                                    icon: _getIconForHousingType(tag.toString()),
                                    isSelected: _selectedHousingTags.contains(tag),
                                    onTap: () => _toggleHousingTag(tag.toString()),
                                  ),
                                ))
                            .toList(),
                        // Separator
                        if ((_availableTags['housingTags'] as List<dynamic>? ?? []).isNotEmpty &&
                            (_availableTags['amenities'] as List<dynamic>? ?? []).isNotEmpty)
                          Container(
                            height: 32,
                            width: 1,
                            color: AppColors.coolGray.withOpacity(0.3),
                            margin: const EdgeInsets.symmetric(horizontal: 8),
                          ),
                        // Amenity Filters
                        ...(_availableTags['amenities'] as List<dynamic>? ?? [])
                            .map((amenity) => Padding(
                                  padding: const EdgeInsets.only(right: 8),
                                  child: FilterChipCustom(
                                    label: amenity.toString(),
                                    isSelected: _selectedAmenities.contains(amenity),
                                    onTap: () => _toggleAmenity(amenity.toString()),
                                  ),
                                ))
                            .toList(),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Property Results
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _properties.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 16),
                        itemBuilder: (context, index) {
                          final property = _properties[index];
                          return SizedBox(
                            width: double.infinity,
                            child: ProductCard(
                              imageUrl: property.pictures.isNotEmpty
                                  ? property.pictures.first
                                  : 'https://via.placeholder.com/300x200',
                              title: property.title,
                              rating: property.rating,
                              reviews:
                                  0, // TODO: Agregar reviews cuando estén disponibles
                              price: '\$${property.price.toStringAsFixed(2)}',
                              onTap: () {},
                            ),
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
