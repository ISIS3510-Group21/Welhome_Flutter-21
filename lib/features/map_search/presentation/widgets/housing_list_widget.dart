import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:welhome/core/widgets/item_post_list.dart';
import 'package:welhome/features/postDetail/presentation/pages/housing_detail_page.dart';
import '../cubit/map_search_cubit.dart';

class HousingListWidget extends StatelessWidget {
  const HousingListWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MapSearchCubit, MapSearchState>(
      builder: (context, state) {
        if (state is MapSearchLoading || state is MapSearchInitial) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is MapSearchError) {
          return Center(child: Text(state.message));
        }

        if (state is MapSearchLoaded) {
          if (state.properties.isEmpty) {
            return const Center(child: Text('No accommodations available.'));
          }

          return ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: state.properties.length,
            itemBuilder: (context, index) {
              final post = state.properties[index];

              return Column(
                children: [
                  ItemPostList(
                    title: post.title,
                    rating: post.reviews.rating,
                    price: "\$${post.price.toInt()} /month",
                    imageUrl: post.thumbnail,
                    subtitle: post.address,
                    onTap: () {
                      context.read<MapSearchCubit>().selectProperty(post);
                      // Navegación a detalle (opcional, ya que el mapa lo maneja)
                      // Navigator.push(
                      //   context,
                      //   MaterialPageRoute(
                      //     builder: (_) => HousingDetailPage(postId: post.id),
                      //   ),
                      // );
                    },
                  ),
                  if (index < state.properties.length - 1) const SizedBox(height: 12),
                ],
              );
            },
          );
        }
        return const Center(child: Text("Starting search..."));
      },
    );
  }
}