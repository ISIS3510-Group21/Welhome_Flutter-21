import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:welhome/core/constants/app_colors.dart';
import 'package:welhome/core/widgets/app_search_bar.dart';
import 'package:welhome/core/widgets/custom_bottom_nav_bar.dart';
import 'package:welhome/core/widgets/recently_viewed_section.dart';
import 'package:welhome/core/widgets/recommended_rail_horizontal.dart';
import 'package:welhome/features/home/presentation/cubit/home_cubit.dart';
import 'package:welhome/features/housing/domain/repositories/housing_repository.dart' as domain_repo;
import 'package:welhome/features/home/domain/usecases/get_recommended_posts.dart';
import 'package:welhome/features/home/domain/usecases/get_recently_viewed_posts.dart';
import 'package:welhome/features/housing/data/repositories/housing_repository_impl.dart'; // NEW: Importa la implementación concreta del repositorio de vivienda
import 'package:welhome/features/housing/data/repositories/student_user_profile_repository_impl.dart';
import 'package:welhome/features/housing/data/repositories/reviews_repository_impl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class HomePage extends StatelessWidget {
  final String userId;

  const HomePage({super.key, required this.userId});
  
  @override
  Widget build(BuildContext context) {
    final reviewsRepository = ReviewsRepositoryImpl(FirebaseFirestore.instance);
    final domain_repo.HousingRepository housingRepository = HousingRepositoryImpl(
      FirebaseFirestore.instance,
      StudentUserProfileRepositoryImpl(FirebaseFirestore.instance),
      reviewsRepository,
    );

    final getRecommendedPosts = GetRecommendedPosts(housingRepository);
    final getRecentlyViewedPosts = GetRecentlyViewedPosts(housingRepository);

    return BlocProvider(
      create: (_) => HomeCubit(getRecommendedPosts: getRecommendedPosts, getRecentlyViewedPosts: getRecentlyViewedPosts, userId: userId)..loadHomeData(),
      child: Scaffold(
        backgroundColor: AppColors.white,
        body: SafeArea(
          child: BlocBuilder<HomeCubit, HomeState>(
            builder: (context, state) {
              if (state is HomeLoading || state is HomeInitial) {
                return SingleChildScrollView(
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
                            Container(
                              width: 180,
                              height: 24,
                              color: Colors.grey[300],
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
                          itemCount: 3, // número de placeholders
                          separatorBuilder: (_, __) => const SizedBox(width: 16),
                          itemBuilder: (context, index) {
                            return Container(
                              width: 280,
                              decoration: BoxDecoration(
                                color: Colors.grey[300],
                                borderRadius: BorderRadius.circular(16),
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Placeholder para recently viewed
                      SizedBox(
                        height: 250,
                        child: ListView.builder(
                          itemCount: 2,
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemBuilder: (context, index) {
                            return Container(
                              height: 200,
                              margin: const EdgeInsets.only(bottom: 16),
                              decoration: BoxDecoration(
                                color: Colors.grey[300],
                                borderRadius: BorderRadius.circular(16),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                );
              } else if (state is HomeError) {
                return Center(child: Text("Error: ${state.message}"));
              } else if (state is HomeLoaded) {
                return SingleChildScrollView(
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
                      RecommendedRailHorizontal(posts: state.recommendedPosts),
                      RecentlyViewedSection(posts: state.recentlyViewedPosts),
                    ],
                  ),
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ),
        bottomNavigationBar: CustomBottomNavBar(
          currentIndex: 0,
          onTap: (index) => debugPrint("Navegaste al índice $index"),
        ),
      ),
    );
  }
}
