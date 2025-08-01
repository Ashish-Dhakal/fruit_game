// lib/providers/profile_provider.dart
import 'package:flutter/foundation.dart';
import 'package:fruit_game/config/app_constants.dart';
import 'package:fruit_game/services/local_storage_service.dart';

class ProfileProvider with ChangeNotifier {
  String _userName = AppConstants.defaultProfileName;

  ProfileProvider() {
    _loadUserName();
  }

  String get userName => _userName;

  Future<void> _loadUserName() async {
    _userName = LocalStorageService.getUserName() ?? AppConstants.defaultProfileName;
    notifyListeners();
  }

  Future<void> setUserName(String name) async {
    _userName = name;
    await LocalStorageService.saveUserName(name);
    notifyListeners();
  }
}