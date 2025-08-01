// lib/main.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // For system overlays
import 'package:provider/provider.dart';

import 'package:fruit_game/app.dart';
import 'package:fruit_game/providers/game_provider.dart'; // Will be used later
import 'package:fruit_game/providers/profile_provider.dart';
import 'package:fruit_game/services/audio_service.dart';
import 'package:fruit_game/services/local_storage_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize local storage
  await LocalStorageService.init();

  // Set preferred orientations (optional, but good for games)
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Set system UI overlay style (for status bar color)
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent, // Transparent status bar
      statusBarIconBrightness:
          Brightness.light, // Light icons for dark background
      systemNavigationBarColor: Colors.black, // Nav bar color
      systemNavigationBarIconBrightness: Brightness.light, // Nav bar icons
    ),
  );

  runApp(
    MultiProvider(
      providers: [
        Provider<AudioService>(
          create: (_) => AudioService(),
          dispose: (_, audioService) => audioService.dispose(),
        ),
        ChangeNotifierProvider(create: (_) => ProfileProvider()),
        ChangeNotifierProvider(
          create: (_) => GameProvider(),
        ), // Initialize GameProvider
      ],
      child: const FruitGameApp(),
    ),
  );
}
