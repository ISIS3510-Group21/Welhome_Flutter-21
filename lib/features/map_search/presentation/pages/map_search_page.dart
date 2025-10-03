import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:welhome/core/widgets/app_search_bar.dart';
import 'package:welhome/core/widgets/custom_bottom_nav_bar.dart';
import 'package:welhome/core/constants/app_colors.dart';
import 'package:welhome/core/constants/app_text_styles.dart';
import '../widgets/map_section_widget.dart';
import '../widgets/housing_list_widget.dart';
import '../widgets/map_search_provider.dart';
import '../cubit/map_search_cubit.dart';
import '../cubit/map_search_state.dart';

class MapSearchPage extends StatelessWidget {
  const MapSearchPage({super.key});

  @override
  Widget build(BuildContext context) {
    return MapSearchProvider(
      child: Scaffold(
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
                child: BlocBuilder<MapSearchCubit, MapSearchState>(
                  builder: (context, state) {
                    String title = 'Map Search';
                    if (state is MapSearchLoaded) {
                      final count = state.housingPostsWithDistance.length;
                      title = 'Map Search';
                    } else if (state is MapSearchLoadingPosts) {
                      title = 'Searching...';
                    }
                    return Text(
                      title,
                      style: AppTextStyles.titleLarge,
                    );
                  },
                ),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: MapSectionWidget(),
              ),
              Expanded(
                child: HousingListWidget(),
              ),
            ],
          ),
        ),
        bottomNavigationBar: CustomBottomNavBar(
          currentIndex: 3,
          onTap: (index) {
            debugPrint("Navigating to index $index");
          },
        ),
      ),
    );
  }
}
