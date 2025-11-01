import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:welhome/core/constants/app_text_styles.dart';
import 'package:welhome/features/housing/domain/entities/housing_post_entity.dart';
import 'package:welhome/features/housing/data/repositories/housing_repository_impl.dart';
import 'package:welhome/features/housing/data/repositories/reviews_repository_impl.dart';
import 'package:welhome/features/housing/data/repositories/student_user_profile_repository_impl.dart';
import 'package:welhome/features/postDetail/domain/usecases/get_post_details.dart';
import 'package:welhome/features/postDetail/presentation/pages/housing_detail_page.dart';
import 'package:welhome/features/postDetail/presentation/cubit/housing_detail_cubit.dart';
import 'recently_viewed_item.dart';

class RecentlyViewedSection extends StatelessWidget {
  final List<HousingPostEntity> posts;

  const RecentlyViewedSection({super.key, required this.posts});

  @override
  Widget build(BuildContext context) {
    if (posts.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Text(
            'Recently seen',
            style: AppTextStyles.tittleMedium.copyWith(
              fontSize: 22,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const SizedBox(height: 12),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: posts.length,
          itemBuilder: (context, index) {
            final post = posts[index];
            return Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: RecentlyViewedItem(
                post: post,
                onTap: () {
                  // La creación de dependencias ahora ocurre aquí, antes de navegar.
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) {
                        // 1. Crear Repositorios
                        final reviewsRepository = ReviewsRepositoryImpl(FirebaseFirestore.instance);
                        final housingRepository = HousingRepositoryImpl(
                          FirebaseFirestore.instance,
                          StudentUserProfileRepositoryImpl(FirebaseFirestore.instance),
                          reviewsRepository,
                        );
                        // 2. Crear Caso de Uso
                        final getPostDetails = GetPostDetails(housingRepository);

                        // 3. Proveer el Cubit a la página de detalle
                        return BlocProvider(
                          create: (context) => HousingDetailCubit(getPostDetails: getPostDetails),
                          child: HousingDetailPage(postId: post.id),
                        );
                      },
                    ),
                  );
                },
              ),
            );
          },
        ),
      ],
    );
  }
}