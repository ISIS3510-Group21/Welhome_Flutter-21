import 'package:flutter/material.dart';
import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:welhome/core/widgets/filter_list_item.dart';
import 'package:welhome/features/filter/presentation/bloc/filter_bloc.dart';
import 'package:welhome/features/filter/presentation/bloc/filter_event.dart';
import 'package:welhome/features/filter/presentation/bloc/filter_state.dart';
import 'package:welhome/core/widgets/filter_chip_custom.dart';
import 'package:welhome/features/filter/domain/usecases/get_properties_usecase.dart';
import 'package:welhome/features/filter/domain/usecases/get_all_tags_usecase.dart';

class FilterPage extends StatefulWidget {
  const FilterPage({super.key});

  @override
  State<FilterPage> createState() => _FilterPageState();
}

class _FilterPageState extends State<FilterPage> {
  bool _isOffline = true;
  final Set<String> _selectedAmenities = {};
  late final FilterBloc _filterBloc;

  @override
  void initState() {
    super.initState();
    _checkConnectivity();
    _setupConnectivityListener();
    _initializeBloc();
  }

  void _initializeBloc() {
    _filterBloc = FilterBloc(
      getPropertiesUseCase: GetIt.I<GetPropertiesUseCase>(),
      getAllTagsUseCase: GetIt.I<GetAllTagsUseCase>(),
    );
    _filterBloc.add(LoadInitialProperties());
  }

  void _setupConnectivityListener() {
    Connectivity().onConnectivityChanged.listen((result) {
      setState(() {
        _isOffline = result == ConnectivityResult.none;
      });
    });
  }

  Future<void> _checkConnectivity() async {
    try {
      final result = await Connectivity().checkConnectivity();
      setState(() {
        _isOffline = result == ConnectivityResult.none;
      });
    } catch (e) {
      debugPrint('Error checking connectivity: $e');
      setState(() => _isOffline = true);
    }
  }

  @override
  void dispose() {
    _filterBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => _filterBloc,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () => Navigator.of(context).pop(),
          ),
          title: const Text('Filtros', style: TextStyle(color: Colors.black)),
        ),
        body: Column(
          children: [
            if (_isOffline)
              Container(
                width: double.infinity,
                color: Colors.orange,
                padding:
                    const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                child: const Row(
                  children: [
                    Icon(Icons.wifi_off, color: Colors.white),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Sin conexión - Mostrando datos almacenados',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
            Expanded(
              child: BlocBuilder<FilterBloc, FilterState>(
                builder: (context, state) {
                  if (state is FilterLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (state is FilterLoaded) {
                    final amenities =
                        state.availableTags['amenities'] as List<String>? ?? [];

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Sección de Amenidades
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Text(
                            'Amenidades',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 50,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            itemCount: amenities.length,
                            itemBuilder: (context, index) {
                              final amenity = amenities[index];
                              return Padding(
                                padding: const EdgeInsets.only(right: 8),
                                child: FilterChipCustom(
                                  label: amenity,
                                  isSelected:
                                      _selectedAmenities.contains(amenity),
                                  onTap: () {
                                    setState(() {
                                      if (_selectedAmenities
                                          .contains(amenity)) {
                                        _selectedAmenities.remove(amenity);
                                      } else {
                                        _selectedAmenities.add(amenity);
                                      }
                                    });

                                    _filterBloc.add(UpdateFilters(
                                      selectedAmenities:
                                          _selectedAmenities.toList(),
                                      selectedHousingTags: const [],
                                    ));
                                  },
                                ),
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Lista de Posts Filtrados
                        Expanded(
                          child: state.properties.isEmpty
                              ? const Center(
                                  child: Text('No se encontraron propiedades'),
                                )
                              : ListView.separated(
                                  padding: const EdgeInsets.all(16),
                                  itemCount: state.properties.length,
                                  separatorBuilder: (context, index) =>
                                      const SizedBox(height: 16),
                                  itemBuilder: (context, index) {
                                    final property = state.properties[index];
                                    return FilterListItem(
                                      property: property,
                                      onTap: () {
                                        Navigator.of(context).pushNamed(
                                          '/property-detail',
                                          arguments: property.id,
                                        );
                                      },
                                    );
                                  },
                                ),
                        ),
                      ],
                    );
                  }

                  return const SizedBox.shrink();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
