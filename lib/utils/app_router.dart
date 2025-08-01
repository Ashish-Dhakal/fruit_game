// lib/utils/app_router.dart
import 'package:flutter/material.dart';
import 'package:fruit_game/screens/home_screen.dart';
import 'package:fruit_game/screens/profile_setup_screen.dart';
import 'package:fruit_game/screens/leaderboard_screen.dart';
import 'package:fruit_game/screens/game_screen.dart';

class AppRouter {
  static const String homeRoute = '/';
  static const String profileSetupRoute = '/profile_setup';
  static const String leaderboardRoute = '/leaderboard';
  static const String gameRoute = '/game';

  static Map<String, WidgetBuilder> routes = {
    homeRoute: (context) => const HomeScreen(),
    profileSetupRoute: (context) => const ProfileSetupScreen(),
    leaderboardRoute: (context) => const LeaderboardScreen(),
    gameRoute: (context) => const GameScreen(),
  };
}
