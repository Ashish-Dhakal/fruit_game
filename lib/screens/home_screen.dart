// lib/screens/home_screen.dart
import 'package:flutter/material.dart';
import 'package:fruit_game/widgets/common_buttons.dart';
import 'package:provider/provider.dart';
import 'package:fruit_game/config/app_colors.dart';
import 'package:fruit_game/config/app_constants.dart';
import 'package:fruit_game/providers/profile_provider.dart';
import 'package:fruit_game/utils/app_router.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _isProfileCheckDone = false; // Flag to ensure check runs only once

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final profileProvider = Provider.of<ProfileProvider>(
      context,
      listen: false,
    );

    // Perform the check here, but only once
    if (!_isProfileCheckDone) {
      _isProfileCheckDone = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (profileProvider.userName == AppConstants.defaultProfileName) {
          Navigator.of(
            context,
          ).pushReplacementNamed(AppRouter.profileSetupRoute);
        }
      });
    }

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage(
              'assets/images/background_stars.png',
            ), // Placeholder background
            fit: BoxFit.cover,
          ),
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(flex: 2),
                Text(
                  AppConstants.appName,
                  style: textTheme.displayMedium?.copyWith(
                    color: AppColors.textPrimary,
                    letterSpacing: 2,
                    shadows: [
                      Shadow(
                        offset: const Offset(2.0, 2.0),
                        blurRadius: 3.0,
                        color: Colors.black.withOpacity(0.5),
                      ),
                    ],
                  ),
                ),
                Text(
                  AppConstants.appSlogan,
                  style: textTheme.bodyLarge?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 30),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 10,
                      height: 10,
                      decoration: const BoxDecoration(
                        color: AppColors.onlineIndicator,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '0 players online', // Static for now
                      style: textTheme.bodyMedium,
                    ),
                  ],
                ),
                const Spacer(flex: 1),
                _buildGameModeButton(
                  context,
                  icon: Icons.person,
                  title: 'Single Player',
                  subtitle: 'Practice your skills',
                  onTap: () {
                    Navigator.of(context).pushNamed(AppRouter.gameRoute);
                  },
                ),
                const SizedBox(height: 16),
                _buildGameModeButton(
                  context,
                  icon: Icons.flash_on,
                  title: 'Quick Play',
                  subtitle: 'Find a random match online',
                  isEnabled: false, // Static for now
                ),
                const SizedBox(height: 16),
                _buildGameModeButton(
                  context,
                  icon: Icons.people,
                  title: 'Custom Room',
                  subtitle: 'Play with friends',
                  isEnabled: false, // Static for now
                ),
                const SizedBox(height: 30),
                FruitGameElevatedButton(
                  text: 'Leaderboard',
                  icon: Icons.emoji_events,
                  onPressed: () {
                    Navigator.of(context).pushNamed(AppRouter.leaderboardRoute);
                  },
                ),
                const Spacer(flex: 1),
                Text(
                  'Tap and drag to select numbers that add up to 10',
                  style: textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
                const Spacer(flex: 1),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGameModeButton(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    VoidCallback? onTap,
    bool isEnabled = true,
  }) {
    final textTheme = Theme.of(context).textTheme;
    return Card(
      elevation: 0,
      color: AppColors.secondaryBackground.withOpacity(isEnabled ? 1.0 : 0.5),
      child: InkWell(
        onTap: isEnabled ? onTap : null,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
          child: Row(
            children: [
              Icon(
                icon,
                color: AppColors.textPrimary.withOpacity(isEnabled ? 1.0 : 0.5),
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: textTheme.titleMedium?.copyWith(
                      color: AppColors.textPrimary.withOpacity(
                        isEnabled ? 1.0 : 0.5,
                      ),
                    ),
                  ),
                  Text(
                    subtitle,
                    style: textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary.withOpacity(
                        isEnabled ? 1.0 : 0.5,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
