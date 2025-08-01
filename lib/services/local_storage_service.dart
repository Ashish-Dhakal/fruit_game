// lib/services/local_storage_service.dart
import 'package:shared_preferences/shared_preferences.dart';

class LocalStorageService {
  static SharedPreferences? _preferences;

  static Future<void> init() async {
    _preferences = await SharedPreferences.getInstance();
  }

  // User Profile
  static Future<void> saveUserName(String name) async {
    await _preferences?.setString('userName', name);
  }

  static String? getUserName() {
    return _preferences?.getString('userName');
  }

  // High Score (Single Player)
  static Future<void> saveSinglePlayerHighScore(int score) async {
    final currentHighScore = getSinglePlayerHighScore();
    if (score > currentHighScore) {
      await _preferences?.setInt('singlePlayerHighScore', score);
    }
  }

  static int getSinglePlayerHighScore() {
    return _preferences?.getInt('singlePlayerHighScore') ?? 0;
  }

  // You can add more methods here for saving game stats, settings, etc.
}