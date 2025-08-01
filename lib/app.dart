// lib/app.dart
import 'package:flutter/material.dart';
import 'package:fruit_game/config/app_theme.dart';
import 'package:fruit_game/utils/app_router.dart';

class FruitGameApp extends StatelessWidget {
  const FruitGameApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Fruit Game',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme, // Apply our dark theme
      initialRoute: AppRouter.homeRoute,
      routes: AppRouter.routes,
    );
  }
}
