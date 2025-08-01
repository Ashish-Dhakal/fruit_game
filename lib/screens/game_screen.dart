// lib/screens/game_screen.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fruit_game/config/app_colors.dart';
import 'package:fruit_game/config/app_constants.dart';
import 'package:fruit_game/providers/game_provider.dart';
import 'package:fruit_game/services/audio_service.dart';
import 'package:fruit_game/utils/app_router.dart';
import 'package:fruit_game/widgets/fruit_tile.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  bool _isSoundOn = true; // State for sound toggle
  GlobalKey _gridKey = GlobalKey(); // Key to get the size and position of the grid
  RenderBox? _gridRenderBox;
  double _tileWidth = 0;
  double _tileHeight = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Initialize game when the screen is built
      Provider.of<GameProvider>(context, listen: false).startGame();
      _calculateTileSizes();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Recalculate tile sizes if dependencies change (e.g., orientation)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _calculateTileSizes();
    });
  }

  void _calculateTileSizes() {
    _gridRenderBox = _gridKey.currentContext?.findRenderObject() as RenderBox?;
    if (_gridRenderBox != null) {
      final gridSize = _gridRenderBox!.size;
      _tileWidth = gridSize.width / AppConstants.gameGridCols;
      _tileHeight = gridSize.height / AppConstants.gameGridRows;
      setState(() {}); // Rebuild to update grid layout if needed
    }
  }

  // --- Helper to convert local position to grid coordinates (col, row) ---
  Offset? _getGridCoordinates(Offset localPosition) {
    if (_tileWidth == 0 || _tileHeight == 0 || _gridRenderBox == null) return null;

    final relativeX = localPosition.dx;
    final relativeY = localPosition.dy;

    if (relativeX < 0 || relativeY < 0 || relativeX > _gridRenderBox!.size.width || relativeY > _gridRenderBox!.size.height) {
      return null; // Out of bounds
    }

    final col = (relativeX / _tileWidth).floor();
    final row = (relativeY / _tileHeight).floor();

    if (col >= 0 && col < AppConstants.gameGridCols && row >= 0 && row < AppConstants.gameGridRows) {
      return Offset(col.toDouble(), row.toDouble());
    }
    return null;
  }

  // --- Gesture Handlers ---
  void _onPanStart(DragStartDetails details, GameProvider gameProvider) {
    final gridCoords = _getGridCoordinates(details.localPosition);
    if (gridCoords != null) {
      gameProvider.startSelection(gridCoords);
    }
  }

  void _onPanUpdate(DragUpdateDetails details, GameProvider gameProvider) {
    final gridCoords = _getGridCoordinates(details.localPosition);
    if (gridCoords != null) {
      gameProvider.updateSelection(gridCoords);
    }
  }

  void _onPanEnd(DragEndDetails details, GameProvider gameProvider, AudioService audioService) {
    int correctMove = gameProvider.score; // Store current score before processing
    gameProvider.endSelection();
    if (gameProvider.score > correctMove) { // If score increased, it was a correct move
      if (_isSoundOn) audioService.playSuccessSound();
    } else {
      audioService.vibrate();
      if (_isSoundOn) audioService.playErrorSound(); // Play error sound if incorrect
    }
  }

  // --- Game State Callbacks ---
  void _onGameReset(GameProvider gameProvider) {
    gameProvider.resetGame();
    // After reset, if you want it to automatically start again
    gameProvider.startGame();
  }

  void _onGameDifficultyChange(GameProvider gameProvider, GameDifficulty newDifficulty) {
    gameProvider.setDifficulty(newDifficulty);
  }


  @override
  Widget build(BuildContext context) {
    final gameProvider = Provider.of<GameProvider>(context);
    final audioService = Provider.of<AudioService>(context, listen: false);

    String formatTime(int seconds) {
      final minutes = (seconds ~/ 60).toString().padLeft(2, '0');
      final remainingSeconds = (seconds % 60).toString().padLeft(2, '0');
      return '$minutes:$remainingSeconds';
    }

    // Determine the text color for the timer based on remaining time
    Color timerColor = AppColors.textPrimary;
    if (gameProvider.timeLeft <= 10 && gameProvider.gameState == GameState.playing) {
      timerColor = Colors.red; // Flash red when time is low
    }


    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        titleSpacing: 0,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 16.0),
              child: TextButton(
                onPressed: () {
                  gameProvider.stopTimer(); // Stop timer before leaving game
                  Navigator.of(context).pushReplacementNamed(AppRouter.homeRoute);
                },
                style: TextButton.styleFrom(
                  backgroundColor: AppColors.secondaryBackground,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
                child: const Text('Menu', style: TextStyle(color: AppColors.textPrimary)),
              ),
            ),
            Row(
              children: [
                const Icon(Icons.apple, color: AppColors.redApple, size: 28),
                const SizedBox(width: 8),
                Text('Fruit Box', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: TextButton.icon(
                onPressed: () {
                  setState(() {
                    _isSoundOn = !_isSoundOn;
                    // Additional logic to mute/unmute audio service
                  });
                },
                style: TextButton.styleFrom(
                  backgroundColor: AppColors.secondaryBackground,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
                icon: Icon(_isSoundOn ? Icons.volume_up : Icons.volume_off, color: AppColors.textPrimary),
                label: Text(_isSoundOn ? 'Sound On' : 'Sound Off', style: const TextStyle(color: AppColors.textPrimary)),
              ),
            ),
          ],
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/background_stars.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildStatBox('SCORE', gameProvider.score.toString()),
                  _buildStatBox('HIGH', gameProvider.highScore.toString()),
                  TextButton(
                    onPressed: () => _onGameReset(gameProvider),
                    style: TextButton.styleFrom(
                      backgroundColor: AppColors.secondaryBackground,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    ),
                    child: Text(
                      'Reset',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(color: AppColors.textPrimary),
                    ),
                  ),
                  _buildStatBox('TIME', formatTime(gameProvider.timeLeft), valueColor: timerColor),
                ],
              ),
            ),
            // Difficulty Selection
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 5),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ChoiceChip(
                    label: Text('Easy (Sum to ${AppConstants.easyModeTargetSum})'),
                    selected: gameProvider.difficulty == GameDifficulty.easy,
                    onSelected: (selected) {
                      if (selected) _onGameDifficultyChange(gameProvider, GameDifficulty.easy);
                    },
                    selectedColor: AppColors.accentGreen,
                    backgroundColor: AppColors.secondaryBackground,
                    labelStyle: TextStyle(
                      color: gameProvider.difficulty == GameDifficulty.easy ? AppColors.primaryBackground : AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(width: 10),
                  ChoiceChip(
                    label: Text('Hard (Sum to ${gameProvider.targetSum})'),
                    selected: gameProvider.difficulty == GameDifficulty.hard,
                    onSelected: (selected) {
                      if (selected) _onGameDifficultyChange(gameProvider, GameDifficulty.hard);
                    },
                    selectedColor: AppColors.accentGreen,
                    backgroundColor: AppColors.secondaryBackground,
                    labelStyle: TextStyle(
                      color: gameProvider.difficulty == GameDifficulty.hard ? AppColors.primaryBackground : AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10), // Space before the grid

            // Target Sum Display
            Text(
              'Draw a box over apples that sum to ${gameProvider.targetSum}!',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(color: AppColors.textPrimary),
            ),
            const SizedBox(height: 10),

            Expanded(
              child: gameProvider.gameState == GameState.gameOver
                  ? _buildGameOverScreen(gameProvider)
                  : LayoutBuilder(
                      builder: (context, constraints) {
                        // This ensures _tileWidth and _tileHeight are calculated based on actual available space
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          _calculateTileSizes();
                        });

                        return GestureDetector(
                          onPanStart: (details) => _onPanStart(details, gameProvider),
                          onPanUpdate: (details) => _onPanUpdate(details, gameProvider),
                          onPanEnd: (details) => _onPanEnd(details, gameProvider, audioService),
                          child: Container(
                            key: _gridKey,
                            padding: const EdgeInsets.all(8.0), // Padding around the grid
                            alignment: Alignment.center,
                            child: GridView.builder(
                              physics: const NeverScrollableScrollPhysics(), // Prevent scrolling
                              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: AppConstants.gameGridCols,
                                childAspectRatio: 1.0, // Make tiles square
                                crossAxisSpacing: 4.0, // Spacing between columns
                                mainAxisSpacing: 4.0, // Spacing between rows
                              ),
                              itemCount: AppConstants.gameGridRows * AppConstants.gameGridCols,
                              itemBuilder: (context, index) {
                                final row = index ~/ AppConstants.gameGridCols;
                                final col = index % AppConstants.gameGridCols;
                                final number = gameProvider.gameGrid[row][col];
                                final isSelected = gameProvider.currentSelectedCells.contains(Offset(col.toDouble(), row.toDouble()));

                                return FruitTile(
                                  number: number,
                                  isSelected: isSelected,
                                  // isTargetHighlight: isTargetHighlight // Could add highlight for potential valid cells
                                );
                              },
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatBox(String label, String value, {Color? valueColor}) {
    return Column(
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(color: AppColors.textSecondary),
        ),
        Text(
          value,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(color: valueColor ?? AppColors.textPrimary),
        ),
      ],
    );
  }

  Widget _buildGameOverScreen(GameProvider gameProvider) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Game Over!',
            style: Theme.of(context).textTheme.displaySmall?.copyWith(color: AppColors.textPrimary),
          ),
          const SizedBox(height: 20),
          Text(
            'Your Score: ${gameProvider.score}',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(color: AppColors.accentYellow),
          ),
          const SizedBox(height: 10),
          Text(
            'High Score: ${gameProvider.highScore}',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: AppColors.textPrimary),
          ),
          const SizedBox(height: 30),
          ElevatedButton(
            onPressed: () {
              gameProvider.startGame(); // Restart the game
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.accentGreen,
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: Text(
              'Play Again',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(color: AppColors.primaryBackground),
            ),
          ),
          const SizedBox(height: 15),
          ElevatedButton(
            onPressed: () {
              gameProvider.stopTimer(); // Ensure timer is stopped
              Navigator.of(context).pushReplacementNamed(AppRouter.homeRoute); // Go back to menu
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.secondaryBackground,
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: Text(
              'Back to Menu',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(color: AppColors.textPrimary),
            ),
          ),
        ],
      ),
    );
  }
}