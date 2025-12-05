import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:welhome/core/widgets/item_post_list.dart';
import 'package:welhome/features/housing/data/repositories/housing_repository_impl.dart';
import 'package:welhome/features/housing/data/repositories/reviews_repository_impl.dart';
import 'package:welhome/features/housing/data/repositories/student_user_profile_repository_impl.dart';
import 'package:welhome/features/housing/domain/entities/housing_post_with_distance_entity.dart';
import 'package:welhome/features/map_search/presentation/cubit/map_search_cubit.dart';
import 'package:welhome/features/map_search/presentation/cubit/map_search_state.dart';
import 'package:welhome/features/postDetail/domain/usecases/get_post_details.dart';
import 'package:welhome/features/postDetail/presentation/cubit/housing_detail_cubit.dart';
import 'package:welhome/features/postDetail/presentation/pages/housing_detail_page.dart';

class HousingListWidget extends StatefulWidget {
  const HousingListWidget({super.key});

  @override
  State<HousingListWidget> createState() => _HousingListWidgetState();
}

class _HousingListWidgetState extends State<HousingListWidget> {
  final ScrollController _scrollController = ScrollController();
  final Map<String, GlobalKey> _itemKeys = {};

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<MapSearchCubit, MapSearchState>(
      listenWhen: (previous, current) {
        String? prevSelected;
        String? currSelected;
        if (previous is MapSearchLoaded) prevSelected = previous.selectedPostId;
        if (previous is MapSearchRefreshing) {
          prevSelected = previous.selectedPostId;
        }
        if (current is MapSearchLoaded) currSelected = current.selectedPostId;
        if (current is MapSearchRefreshing) {
          currSelected = current.selectedPostId;
        }
        return prevSelected != currSelected;
      },
      listener: (context, state) {
        String? selectedId;
        List<HousingPostWithDistanceEntity> posts = [];
        if (state is MapSearchLoaded) {
          selectedId = state.selectedPostId;
          posts = state.housingPostsWithDistance;
        } else if (state is MapSearchRefreshing) {
          selectedId = state.selectedPostId;
          posts = state.currentPosts;
        }

        if (selectedId != null && posts.isNotEmpty) {
          _scrollToPost(selectedId);
        }
      },
      builder: (context, state) {
        return _buildListContent(context, state);
      },
    );
  }

  void _scrollToPost(String postId) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final key = _itemKeys[postId];
      final contextForItem = key?.currentContext;
      if (contextForItem != null) {
        Scrollable.ensureVisible(
          contextForItem,
          duration: const Duration(milliseconds: 350),
          curve: Curves.easeInOut,
          alignment: 0.1,
        );
      } else {
        final allKeys = _itemKeys.keys.toList();
        final index = allKeys.indexOf(postId);
        if (index >= 0 && _scrollController.hasClients) {
          const estimatedExtent = 180.0;
          _scrollController.animateTo(
            index * estimatedExtent,
            duration: const Duration(milliseconds: 350),
            curve: Curves.easeInOut,
          );
        }
      }
    });
  }

  Widget _buildListContent(BuildContext context, MapSearchState state) {
    if (state is MapSearchLoadingLocation) {
      return _buildLoadingState("Getting your location...");
    }

    if (state is MapSearchLoadingPosts) {
      return _buildLoadingState(state.message);
    }

    if (state is MapSearchRefreshing) {
      return Column(
        children: [
          const LinearProgressIndicator(),
          const SizedBox(height: 16),
          Expanded(
            child: _buildPostsList(state.currentPosts),
          ),
        ],
      );
    }

    if (state is MapSearchError) {
      return _buildErrorState(
        context,
        state.message,
        state.canRetry
            ? () => context.read<MapSearchCubit>().retryLastAction()
            : null,
      );
    }

    if (state is MapSearchNoResults) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.search_off,
                size: 64,
                color: Colors.grey[400],
              ),
              const SizedBox(height: 16),
              Text(
                'No accommodations found within ${state.searchRadiusKm.toInt()} km',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Colors.grey[600],
                    ),
              ),
            ],
          ),
        ),
      );
    }

    if (state is MapSearchLoaded) {
      final housingPostsWithDistance = state.housingPostsWithDistance;

      if (housingPostsWithDistance.isEmpty) {
        return const Center(
          child: Text('No accommodations available.'),
        );
      }

      return Column(
        children: [
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Row(
              children: [
                Text(
                  '${state.totalResults} accommodations found',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey[600],
                      ),
                ),
              ],
            ),
          ),
          Expanded(
            child: _buildPostsList(housingPostsWithDistance),
          ),
        ],
      );
    }

    return _buildLoadingState("Starting search...");
  }

  Widget _buildLoadingState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 16),
          Text(message),
        ],
      ),
    );
  }

  Widget _buildErrorState(
      BuildContext context, String message, VoidCallback? onRetry) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(message, textAlign: TextAlign.center),
          if (onRetry != null) ...[
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: onRetry,
              child: const Text('Reintentar'),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPostsList(List<HousingPostWithDistanceEntity> posts) {
    final random = Random();
    const defaultPlaceholders = [
      'lib/assets/images/fallback1.jpg',
      'lib/assets/images/fallback2.jpg',
    ];

    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: posts.length,
      itemBuilder: (context, index) {
        final post = posts[index];
        final key = _itemKeys.putIfAbsent(post.id, () => GlobalKey());

        // IMPROVED VALIDATION: Check for valid URL
        final hasValidNetworkImage = post.thumbnail != null &&
            post.thumbnail!.isNotEmpty &&
            _isValidImageUrl(post.thumbnail!);

        final placeholderAsset =
            defaultPlaceholders[random.nextInt(defaultPlaceholders.length)];

        return Column(
          key: key,
          children: [
            ItemPostList(
              title: post.title,
              rating: post.rating,
              price: "\$${post.price.toInt()} /month",
              imageUrl: hasValidNetworkImage ? post.thumbnail! : null,
              placeholderAsset: placeholderAsset,
              subtitle: post.formattedDistance,
              onTap: () {
                context.read<MapSearchCubit>().selectPost(post.id);

                // Obtén las dependencias necesarias
                final reviewsRepository =
                    ReviewsRepositoryImpl(FirebaseFirestore.instance);
                final housingRepository = HousingRepositoryImpl(
                  FirebaseFirestore.instance,
                  StudentUserProfileRepositoryImpl(FirebaseFirestore.instance),
                  reviewsRepository,
                );

                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => BlocProvider(
                      create: (context) => HousingDetailCubit(
                        getPostDetails: GetPostDetails(housingRepository),
                      ),
                      child: HousingDetailPage(postId: post.id),
                    ),
                  ),
                );
              },
            ),
            if (index < posts.length - 1) const SizedBox(height: 12),
          ],
        );
      },
    );
  }

// IMPROVED URL VALIDATION METHOD
  bool _isValidImageUrl(String url) {
    if (url.isEmpty) return false;

    try {
      final uri = Uri.parse(url);
      return uri.isAbsolute &&
          uri.host.isNotEmpty &&
          (uri.scheme == 'http' || uri.scheme == 'https');
    } catch (e) {
      return false;
    }
  }
}
