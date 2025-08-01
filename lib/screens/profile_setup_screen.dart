// lib/screens/profile_setup_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fruit_game/config/app_colors.dart';
import 'package:fruit_game/providers/profile_provider.dart';
import 'package:fruit_game/utils/app_router.dart';
import 'package:fruit_game/widgets/common_buttons.dart';

class ProfileSetupScreen extends StatefulWidget {
  const ProfileSetupScreen({super.key});

  @override
  State<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends State<ProfileSetupScreen> {
  final TextEditingController _nameController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    // Pre-fill with existing name if available
    _nameController.text = Provider.of<ProfileProvider>(
      context,
      listen: false,
    ).userName;
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _saveProfile() {
    if (_formKey.currentState?.validate() ?? false) {
      Provider.of<ProfileProvider>(
        context,
        listen: false,
      ).setUserName(_nameController.text.trim());
      Navigator.of(context).pushReplacementNamed(AppRouter.homeRoute);
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            // Only allow back if a name is already set
            if (Provider.of<ProfileProvider>(context, listen: false).userName !=
                'Anonymous') {
              Navigator.of(context).pop();
            }
          },
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/background_stars.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Set up your profile',
                style: textTheme.headlineMedium?.copyWith(
                  color: AppColors.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Enter the name other players will see',
                style: textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              Form(
                key: _formKey,
                child: TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    hintText: 'e.g. AppleMaster',
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter a name';
                    }
                    if (value.trim().length < 3) {
                      return 'Name must be at least 3 characters';
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(height: 32),
              FruitGameElevatedButton(
                text: 'Continue',
                backgroundColor: AppColors.accentGreen,
                onPressed: _saveProfile,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
