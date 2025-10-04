import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:welhome/features/home/presentation/pages/home_page.dart';
import 'package:welhome/features/map_search/presentation/widgets/map_search_provider.dart';
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
            MaterialPageRoute(builder: (context) => const HomePage()),
          );
        }
        if (index == 1) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const CreateHousingPostPage()),
          );
        }
        if (index == 2) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const FilterPage()),
          );
        }
        if (index == 3) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => MapSearchProvider(
              child: const MapSearchPage(),
            )),
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
          icon: Icon(Icons.forum_outlined),
          activeIcon: Icon(Icons.forum),
          label: "Forum",
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.calendar_month_outlined),
          activeIcon: Icon(Icons.calendar_month),
          label: "Visits",
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