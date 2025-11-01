import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'features/filter/presentation/bloc/filter_bloc.dart';
import 'features/filter/domain/usecases/get_properties_usecase.dart';
import 'features/filter/domain/usecases/get_all_tags_usecase.dart';
import 'features/filter/data/repositories/property_repository_impl.dart';
import 'features/filter/data/datasources/property_remote_datasource.dart';
import 'features/filter/data/services/property_cache_service.dart';
import 'features/login/presentation/pages/login_page.dart';

final getIt = GetIt.instance;

Future<void> initializeDependencies() async {
  // Initialize SharedPreferences
  final sharedPreferences = await SharedPreferences.getInstance();
  
  // Register Services
  getIt.registerSingleton<PropertyCacheService>(
    PropertyCacheService(sharedPreferences)
  );
  
  // Register DataSources
  getIt.registerSingleton<PropertyRemoteDataSource>(
    PropertyRemoteDataSource(
      firestore: FirebaseFirestore.instance,
      cacheService: getIt<PropertyCacheService>(),
    )
  );
  
  // Register Repositories
  getIt.registerSingleton<PropertyRepositoryImpl>(
    PropertyRepositoryImpl(getIt<PropertyRemoteDataSource>())
  );
  
  // Register Use Cases
  getIt.registerSingleton<GetPropertiesUseCase>(
    GetPropertiesUseCase(getIt<PropertyRepositoryImpl>())
  );
  
  getIt.registerSingleton<GetAllTagsUseCase>(
    GetAllTagsUseCase(getIt<PropertyRepositoryImpl>())
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Welhome',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: BlocProvider(
        create: (context) => FilterBloc(
          getPropertiesUseCase: getIt<GetPropertiesUseCase>(),
          getAllTagsUseCase: getIt<GetAllTagsUseCase>(),
        ),
        child: const LoginPage(),
      ),
    );
  }
}