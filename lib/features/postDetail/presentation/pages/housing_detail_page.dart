import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:welhome/core/constants/app_colors.dart';
import 'package:welhome/core/data/repositories/housing_repository.dart';
import 'package:welhome/core/widgets/custom_divider.dart';
import 'package:welhome/features/postDetail/presentation/cubit/housing_detail_cubit.dart';
import 'package:welhome/features/postDetail/presentation/widgets/housing_detail_amenities.dart';
import 'package:welhome/features/postDetail/presentation/widgets/housing_detail_header.dart';
import 'package:welhome/features/postDetail/presentation/widgets/housing_detail_roomates.dart';

class HousingDetailPage extends StatefulWidget {
  final String postId;

  const HousingDetailPage({Key? key, required this.postId}) : super(key: key);

  @override
  State<HousingDetailPage> createState() => _HousingDetailPageState();
}

class _HousingDetailPageState extends State<HousingDetailPage> {
  late final HousingDetailCubit _cubit;

  @override
  void initState() {
    super.initState();
    _cubit = HousingDetailCubit(housingRepository: HousingRepository());
    _cubit.fetchHousingPost(widget.postId);
  }

  @override
  void dispose() {
    _cubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _cubit,
      child: Scaffold(
        backgroundColor: AppColors.white,
        appBar: AppBar(
          title: const Text("Housing Detail"),
        ),
        body: BlocBuilder<HousingDetailCubit, HousingDetailState>(
          builder: (context, state) {
            if (state is HousingDetailLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is HousingDetailLoaded) {
              final post = state.post;

              return SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Carrusel dinámico
                    if (post.pictures.isNotEmpty)
                      HousingDetailHeader(
                        imageUrls:
                            post.pictures.map((pic) => pic.photoPath).toList(),
                            rating: post.rating,
                            reviewsCount: 4,
                            title: post.title,
                            price: post.price,
                      )
                    else
                      Container(
                        height: 212,
                        alignment: Alignment.center,
                        child: const Text("No images available"),
                      ),
                      CustomDivider(),
                      HousingDetailAmenities(amenities: post.ammenities),
                      HousingDetailRoommates(roommates: post.roomateProfile),
                  ],
                ),
              );
            } else if (state is HousingDetailError) {
              return Center(
                child: Text("Error: ${state.message}"),
              );
            }
            return const SizedBox.shrink(); // estado inicial vacío
          },
        ),
      ),
    );
  }
}
