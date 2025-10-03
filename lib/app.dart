import 'package:flutter/material.dart';
import 'features/filter/presentation/pages/filter_page.dart';
import 'features/login/presentation/pages/login_page.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Welhome',
      theme: ThemeData(primarySwatch: Colors.blue),
      
      home: const LoginPage(),
    );
  }
}