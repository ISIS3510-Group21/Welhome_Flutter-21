import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:welhome/core/widgets/item_post_list.dart';
import '../cubit/map_search_cubit.dart';
import '../cubit/map_search_state.dart';
import 'loading_state_widget.dart';
import 'error_state_widget.dart';
import 'package:welhome/core/data/models/housing_post.dart';
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
        // React only to selection changes and loaded/refreshing transitions
        String? prevSelected;
        String? currSelected;
        if (previous is MapSearchLoaded) prevSelected = previous.selectedPostId;
        if (previous is MapSearchRefreshing) prevSelected = previous.selectedPostId;
        if (current is MapSearchLoaded) currSelected = current.selectedPostId;
        if (current is MapSearchRefreshing) currSelected = current.selectedPostId;
        return prevSelected != currSelected;
      },
      listener: (context, state) {
        String? selectedId;
        List<HousingPostWithDistance> posts = const [];
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
        // Fallback: approximate scroll based on index if widget not built yet
        final allKeys = _itemKeys.keys.toList();
        final index = allKeys.indexOf(postId);
        if (index >= 0 && _scrollController.hasClients) {
          final estimatedExtent = 180.0; // conservative estimate
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
      return const LoadingStateWidget(message: "Getting your location...");
    }

    if (state is MapSearchLoadingPosts) {
      return LoadingStateWidget(message: state.message);
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
      return ErrorStateWidget(
        message: state.message,
        onRetry: state.canRetry
            ? () => context.read<MapSearchCubit>().retryLastAction()
            : () {},
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
          // Results counter
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
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
          // Posts list
          Expanded(
            child: _buildPostsList(housingPostsWithDistance),
          ),
        ],
      );
    }

    return const LoadingStateWidget(message: "Starting search...");
  }

    Widget _buildPostsList(List<HousingPostWithDistance> posts) {
  final random = Random();
  final defaultPlaceholders = [
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

      final hasNetworkImage = post.thumbnail != null && post.thumbnail!.isNotEmpty;
      final placeholderAsset = defaultPlaceholders[random.nextInt(defaultPlaceholders.length)];

      return Column(
        key: key,
        children: [
          ItemPostList(
            title: post.title,
            rating: post.rating,
            price: "\$${post.price.toInt()} /month",
            imageUrl: hasNetworkImage ? post.thumbnail! : null,
            placeholderAsset: placeholderAsset,
            subtitle: post.formattedDistance != null
                ? "${post.formattedDistance} away"
                : null,
            onTap: () {
              context.read<MapSearchCubit>().selectPost(post.id);

              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => HousingDetailPage(postId: post.id),
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
}
