import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:welhome/core/widgets/app_search_bar.dart';
import 'package:welhome/core/widgets/custom_bottom_nav_bar.dart';
import 'package:welhome/core/constants/app_colors.dart';
import 'package:welhome/core/constants/app_text_styles.dart';
import 'package:welhome/features/map_search/presentation/cubit/map_search_state.dart';
import 'package:welhome/features/map_search/presentation/widgets/map_section_widget.dart';
import 'package:welhome/features/map_search/presentation/widgets/housing_list_widget.dart';
import 'package:welhome/features/map_search/presentation/cubit/map_search_cubit.dart';
import 'package:welhome/features/housing/data/repositories/housing_repository_impl.dart';
import 'package:welhome/features/housing/data/repositories/student_user_profile_repository_impl.dart';
import 'package:welhome/features/housing/data/repositories/reviews_repository_impl.dart';

class MapSearchPage extends StatelessWidget {
  const MapSearchPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Mismo patrón que HomePage - Crear repositorios localmente
    final reviewsRepository = ReviewsRepositoryImpl(FirebaseFirestore.instance);
    final housingRepository = HousingRepositoryImpl(
      FirebaseFirestore.instance,
      StudentUserProfileRepositoryImpl(FirebaseFirestore.instance),
      reviewsRepository,
    );

    return BlocProvider(
      create: (_) => MapSearchCubit(housingRepository)..getUserLocation(),
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
              const Expanded(
                child: HousingListWidget(),
              ),
            ],
          ),
        ),
        bottomNavigationBar: CustomBottomNavBar(
          currentIndex: 3,
          onTap: (index) {
            // Navigation is handled in CustomBottomNavBar
          },
        ),
      ),
    );
  }
}