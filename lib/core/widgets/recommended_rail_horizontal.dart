import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:welhome/features/housing/domain/entities/housing_post_entity.dart';
import 'package:welhome/features/housing/data/repositories/housing_repository_impl.dart';
import 'package:welhome/features/housing/data/repositories/reviews_repository_impl.dart';
import 'package:welhome/features/housing/data/repositories/student_user_profile_repository_impl.dart';
import 'package:welhome/features/postDetail/domain/usecases/get_post_details.dart';
import 'package:welhome/features/postDetail/presentation/pages/housing_detail_page.dart';
import 'package:welhome/features/postDetail/presentation/cubit/housing_detail_cubit.dart';
import 'housing_post_card.dart';

class RecommendedRailHorizontal extends StatelessWidget {
  final List<HousingPostEntity> posts;

  const RecommendedRailHorizontal({super.key, required this.posts});

  @override
  Widget build(BuildContext context) {
    if (posts.isEmpty) {
      return const Center(child: Text('No recommended posts available.'));
    }

    return SizedBox(
      height: 285,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: posts.length,
        separatorBuilder: (context, index) => const SizedBox(width: 16),
        itemBuilder: (context, index) {
          final post = posts[index];
          return HousingPostCard(
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
          );
        },
      ),
    );
  }
}