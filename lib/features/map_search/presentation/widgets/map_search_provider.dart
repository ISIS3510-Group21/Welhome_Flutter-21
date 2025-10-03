// features/map_search/widgets/map_search_provider.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:welhome/core/data/repositories/housing_repository.dart';
import '../cubit/map_search_cubit.dart';

class MapSearchProvider extends StatelessWidget {
  final Widget child;

  const MapSearchProvider({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => MapSearchCubit(
        HousingRepository(),
      )..getUserLocation(), // Start inmediately the loading of user's location
      child: child,
    );
  }
}