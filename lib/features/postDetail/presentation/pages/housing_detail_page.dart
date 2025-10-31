import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:welhome/core/constants/app_colors.dart';
import 'package:welhome/features/housing/data/repositories/housing_repository_impl.dart';
import 'package:welhome/features/housing/data/repositories/student_user_profile_repository_impl.dart';
import 'package:welhome/features/housing/domain/repositories/housing_repository.dart' as domain_repo;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:welhome/features/postDetail/domain/usecases/get_post_details.dart';
import 'package:welhome/core/widgets/custom_divider.dart';
import 'package:welhome/core/widgets/generic_bottom_button.dart';
import 'package:welhome/features/postDetail/presentation/cubit/housing_detail_cubit.dart';
import 'package:welhome/features/postDetail/presentation/widgets/housing_detail_amenities.dart';
import 'package:welhome/features/postDetail/presentation/widgets/housing_detail_header.dart';
import 'package:welhome/features/postDetail/presentation/widgets/housing_detail_host.dart';
import 'package:welhome/features/postDetail/presentation/widgets/housing_detail_location_map.dart';
import 'package:welhome/features/postDetail/presentation/widgets/housing_detail_roomates.dart';

class HousingDetailPage extends StatelessWidget {
  final String postId;

  const HousingDetailPage({super.key, required this.postId});

  @override
  Widget build(BuildContext context) {
    final domain_repo.HousingRepository housingRepository = HousingRepositoryImpl(
      FirebaseFirestore.instance,
      StudentUserProfileRepositoryImpl(FirebaseFirestore.instance),
    );
    final getPostDetails = GetPostDetails(housingRepository);

    return BlocProvider(
      create: (_) =>
          HousingDetailCubit(getPostDetails: getPostDetails)..fetchHousingPost(postId),
      child: Scaffold(
        appBar: AppBar(
          title: const SizedBox.shrink(),
          elevation: 0,
          backgroundColor: AppColors.white,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        body: BlocBuilder<HousingDetailCubit, HousingDetailState>(
          builder: (context, state) {
            if (state is HousingDetailLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is HousingDetailLoaded) {
              final post = state.post;

              return SafeArea(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      HousingDetailHeader(post: post),
                      const CustomDivider(),
                      HousingDetailAmenities(amenities: post.amenities),
                      const CustomDivider(),
                      HousingDetailRoommates(roommates: post.roomateProfile),
                      const CustomDivider(),
                      HousingDetailHost(hostName: post.host),
                      const CustomDivider(),
                      HousingDetailLocationMap(
                        location: GeoPoint(post.location.lat, post.location.lng),
                        address: post.address,
                      ),
                      const CustomDivider(),
                      GenericBottomButton(
                        text: 'Book Visit',
                        onPressed: () {
                          debugPrint('Book Visit pressed');
                        },
                      )
                    ],
                  ),
                ),
              );
            } else if (state is HousingDetailError) {
              return Center(
                child: Text("Error: ${state.message}"),
              );
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }
}
