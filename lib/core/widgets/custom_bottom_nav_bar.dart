import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:welhome/features/home/presentation/pages/home_page.dart';
import 'package:welhome/features/housing/data/repositories/housing_repository_impl.dart';
import 'package:welhome/features/housing/data/repositories/reviews_repository_impl.dart';
import 'package:welhome/features/housing/data/repositories/student_user_profile_repository_impl.dart';
import 'package:welhome/features/map_search/presentation/cubit/map_search_cubit.dart';
import 'package:welhome/features/map_search/presentation/pages/map_search_page.dart';
import 'package:welhome/features/filter/presentation/pages/filter_page.dart';
import 'package:welhome/features/post/presentation/pages/create_post_page.dart';
import 'package:welhome/features/saved/presentation/pages/saved_page.dart';
import '../constants/app_colors.dart';

class CustomBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const CustomBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      currentIndex: currentIndex,
      onTap: (index) {
        // Llama primero al callback original
        onTap(index);
        
        // Navegación simple sin remover páginas
        if (index == 0) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const HomePage(userId: 'Profile_Student10',)),
          );
        }
        if (index == 1) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const SavedPage()),
          );
        }
        if (index == 2) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const CreateHousingPostPage()),
          );
        }
        if (index == 3) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) {
              // 1. Crear Repositorios
              final reviewsRepository = ReviewsRepositoryImpl(FirebaseFirestore.instance);
              final housingRepository = HousingRepositoryImpl(
                FirebaseFirestore.instance,
                StudentUserProfileRepositoryImpl(FirebaseFirestore.instance),
                reviewsRepository,
              );

              // 2. Proveer el Cubit a la página del mapa
              return BlocProvider(
                create: (context) => MapSearchCubit(housingRepository: housingRepository)..loadProperties(),
                child: const MapSearchPage(),
              );
            }),
          );
        }
        if (index == 4) {
          // Página de perfil temporal
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => Scaffold(
              appBar: AppBar(title: const Text('Perfil')),
              body: const Center(
                child: Text('Página de Perfil - En desarrollo'),
              ),
            )),
          );
        }
      },
      backgroundColor: AppColors.white,
      selectedItemColor: AppColors.violetBlue,
      unselectedItemColor: AppColors.coolGray,
      selectedLabelStyle: GoogleFonts.poppins(
        fontSize: 11,
        fontWeight: FontWeight.w600,
      ),
      unselectedLabelStyle: GoogleFonts.poppins(
        fontSize: 11,
        fontWeight: FontWeight.w600,
      ),
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home_outlined),
          activeIcon: Icon(Icons.home),
          label: "Home",
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.bookmark_border),
          activeIcon: Icon(Icons.bookmark),
          label: "Saved",
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.add_circle_outline),
          activeIcon: Icon(Icons.add_circle),
          label: "Post",
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.map_outlined),
          activeIcon: Icon(Icons.map),
          label: "Map",
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person_outline),
          activeIcon: Icon(Icons.person),
          label: "Profile",
        ),
      ],
    );
  }
}