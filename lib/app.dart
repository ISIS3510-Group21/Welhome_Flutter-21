import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'features/filter/presentation/pages/filter_page.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Welhome',
      theme: ThemeData(primarySwatch: Colors.blue),
      
      home: const FilterPage(),
    );
  }
}