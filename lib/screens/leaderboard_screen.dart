// lib/screens/leaderboard_screen.dart
import 'package:flutter/material.dart';
import 'package:fruit_game/config/app_colors.dart';

class LeaderboardScreen extends StatelessWidget {
  const LeaderboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        title: Text(
          'Leaderboard',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        centerTitle: true,
      ),
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/background_stars.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: Center(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildStatCard('20', 'Players'),
                    _buildStatCard('26', 'Games'),
                    _buildStatCard('900', 'High Score'),
                    _buildStatCard('69', 'Avg Score'),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildFilterButton('Single Player', true),
                    _buildFilterButton('Multiplayer', false),
                    _buildFilterButton('Quick Play', false),
                    _buildFilterButton('All Modes', false),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: ListView.builder(
                  itemCount: 5, // Just dummy items for display
                  itemBuilder: (context, index) {
                    return _buildLeaderboardEntry(index + 1);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(String value, String label) {
    return Card(
      color: AppColors.secondaryBackground,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Column(
          children: [
            Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
            Text(label, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterButton(String text, bool isSelected) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: isSelected ? AppColors.accentYellow : AppColors.secondaryBackground,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: isSelected ? AppColors.primaryBackground : AppColors.textPrimary,
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _buildLeaderboardEntry(int rank) {
    // Dummy data for now, will connect to models later
    String name = (rank == 1) ? 'Seth' : 'Anonymous';
    int score = (rank == 1) ? 900 : 60 + (5 - rank); // Decreasing scores
    String date = '7/15/2025';
    String type = 'Single Player';

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      color: AppColors.secondaryBackground,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            if (rank == 1)
              const Icon(Icons.emoji_events, color: AppColors.accentYellow)
            else
              Text('#$rank', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textSecondary)),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.primaryBackground,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(type, style: const TextStyle(fontSize: 10, color: AppColors.textSecondary)),
                      ),
                      const SizedBox(width: 8),
                      Text(date, style: const TextStyle(fontSize: 10, color: AppColors.textSecondary)),
                    ],
                  ),
                ],
              ),
            ),
            Text(
              score.toString(),
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
            ),
            const SizedBox(width: 8),
            const Text('2:00', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
          ],
        ),
      ),
    );
  }
}