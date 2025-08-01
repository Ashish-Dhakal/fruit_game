// lib/providers/game_provider.dart
import 'dart:async';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart'; // For Offset
import 'package:fruit_game/config/app_constants.dart';
import 'package:fruit_game/services/local_storage_service.dart';

enum GameDifficulty { easy, hard }
enum GameState { ready, playing, gameOver }

class GameProvider with ChangeNotifier {
  // Game State
  int _score = 0;
  int _highScore = 0;
  int _timeLeft = AppConstants.gameTimeSeconds;
  GameState _gameState = GameState.ready;
  List<List<int>> _gameGrid = []; // 2D list for 10x17 grid (0 means empty)
  int _targetSum = AppConstants.easyModeTargetSum; // Default to easy
  GameDifficulty _difficulty = GameDifficulty.easy;
  Timer? _gameTimer;

  // Selection State
  Offset? _selectionStart;
  Offset? _selectionEnd;
  List<Offset> _currentSelectedCells = [];

  GameProvider() {
    _loadHighScore();
    _initializeGame(); // Initialize grid on startup
  }

  // --- Getters ---
  int get score => _score;
  int get highScore => _highScore;
  int get timeLeft => _timeLeft;
  GameState get gameState => _gameState;
  List<List<int>> get gameGrid => _gameGrid;
  int get targetSum => _targetSum;
  GameDifficulty get difficulty => _difficulty;
  List<Offset> get currentSelectedCells => _currentSelectedCells;

  // --- Initialization & State Management ---

  void _loadHighScore() {
    _highScore = LocalStorageService.getSinglePlayerHighScore();
    notifyListeners();
  }

  void _saveHighScore(int newScore) {
    if (newScore > _highScore) {
      _highScore = newScore;
      LocalStorageService.saveSinglePlayerHighScore(newScore);
      notifyListeners();
    }
  }

  void _initializeGame() {
    _score = 0;
    _timeLeft = AppConstants.gameTimeSeconds;
    _gameState = GameState.ready; // Or playing if you want to auto-start
    _gameGrid = _generateNewGrid();
    _currentSelectedCells.clear();
    _selectionStart = null;
    _selectionEnd = null;
    _gameTimer?.cancel(); // Ensure any previous timer is stopped
    notifyListeners();
  }

  void startGame() {
    if (_gameState == GameState.playing) return; // Prevent multiple starts
    _initializeGame();
    _gameState = GameState.playing;
    _startTimer();
    notifyListeners();
  }

  void resetGame() {
    _gameTimer?.cancel();
    _initializeGame();
    // Decide if reset should restart immediately or go back to ready
    // For now, let's reset to ready, then user clicks to start.
    // If you want it to auto-restart, call startGame() here.
    notifyListeners();
  }

  // --- Grid Generation ---

  List<List<int>> _generateNewGrid() {
    final random = Random();
    return List.generate(
      AppConstants.gameGridRows,
      (row) => List.generate(
        AppConstants.gameGridCols,
        (col) => random.nextInt(9) + 1, // Numbers from 1 to 9
      ),
    );
  }

  // --- Timer Logic ---

  void _startTimer() {
    _gameTimer?.cancel(); // Cancel any existing timer
    _gameTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_timeLeft > 0) {
        _timeLeft--;
        notifyListeners();
      } else {
        _gameTimer?.cancel();
        _gameState = GameState.gameOver;
        _saveHighScore(_score); // Save high score when game ends
        notifyListeners();
        // You could add a callback here to show game over screen/dialog
      }
    });
  }

  void stopTimer() {
    _gameTimer?.cancel();
    notifyListeners();
  }

  // --- Difficulty Setting ---

  void setDifficulty(GameDifficulty newDifficulty) {
    _difficulty = newDifficulty;
    if (newDifficulty == GameDifficulty.easy) {
      _targetSum = AppConstants.easyModeTargetSum;
    } else {
      final random = Random();
      _targetSum = random.nextInt(AppConstants.hardModeMaxTargetSum - AppConstants.hardModeMinTargetSum + 1) + AppConstants.hardModeMinTargetSum;
    }
    // If game is playing, reset with new difficulty
    if (_gameState == GameState.playing) {
      resetGame(); // Or call startGame() to immediately start a new game
    }
    notifyListeners();
  }

  // --- Selection Logic ---

  void startSelection(Offset start) {
    if (_gameState != GameState.playing) return;
    _selectionStart = start;
    _selectionEnd = start;
    _updateSelectedCells();
    notifyListeners();
  }

  void updateSelection(Offset current) {
    if (_gameState != GameState.playing) return;
    _selectionEnd = current;
    _updateSelectedCells();
    notifyListeners();
  }

  void endSelection() {
    if (_gameState != GameState.playing) {
      _resetSelection();
      return;
    }

    if (_currentSelectedCells.length < 2) {
      // Must select at least 2 cells for a sum
      _resetSelection();
      notifyListeners();
      return;
    }

    _processSelection();
    _resetSelection(); // Clear selection for next move
    notifyListeners();
  }

  void _updateSelectedCells() {
    _currentSelectedCells.clear();
    if (_selectionStart == null || _selectionEnd == null) return;

    // Convert global offsets to grid coordinates (rough estimate for now)
    // This will need actual grid geometry passed from the GameScreen.
    // For now, let's assume `Offset` contains `row` and `col` directly.
    // In actual implementation, we'll map screen coordinates to grid indices.
    // For this provider's logic, we'll assume a bounding box for now.

    // Mock conversion (replace with actual logic based on tile size/position)
    final startRow = _selectionStart!.dy.round();
    final startCol = _selectionStart!.dx.round();
    final endRow = _selectionEnd!.dy.round();
    final endCol = _selectionEnd!.dx.round();

    final minRow = min(startRow, endRow).clamp(0, AppConstants.gameGridRows - 1);
    final maxRow = max(startRow, endRow).clamp(0, AppConstants.gameGridRows - 1);
    final minCol = min(startCol, endCol).clamp(0, AppConstants.gameGridCols - 1);
    final maxCol = max(startCol, endCol).clamp(0, AppConstants.gameGridCols - 1);

    // Determine if it's a line or a rectangle
    bool isHorizontalLine = (minRow == maxRow);
    bool isVerticalLine = (minCol == maxCol);
    bool isRectangle = !isHorizontalLine && !isVerticalLine;

    // We allow rectangular, horizontal, or vertical selection
    if (isHorizontalLine) {
      for (int col = minCol; col <= maxCol; col++) {
        _currentSelectedCells.add(Offset(minCol.toDouble(), minRow.toDouble())); // Using Offset(col, row)
        _currentSelectedCells.add(Offset(col.toDouble(), minRow.toDouble())); // Add to selected cells
      }
    } else if (isVerticalLine) {
      for (int row = minRow; row <= maxRow; row++) {
        _currentSelectedCells.add(Offset(minCol.toDouble(), row.toDouble())); // Add to selected cells
      }
    } else if (isRectangle) {
      for (int row = minRow; row <= maxRow; row++) {
        for (int col = minCol; col <= maxCol; col++) {
          _currentSelectedCells.add(Offset(col.toDouble(), row.toDouble())); // Add to selected cells
        }
      }
    }
    // Remove duplicates if any (e.g., from line logic)
    _currentSelectedCells = _currentSelectedCells.toSet().toList();
  }

  void _resetSelection() {
    _selectionStart = null;
    _selectionEnd = null;
    _currentSelectedCells.clear();
  }

  void _processSelection() {
    int sum = 0;
    List<Offset> cellsToRemove = [];

    // Ensure _currentSelectedCells contains actual grid indices (col, row)
    // Here we convert them back to (row, col) to access the 2D list.
    for (final cellOffset in _currentSelectedCells) {
      final col = cellOffset.dx.toInt();
      final row = cellOffset.dy.toInt();

      if (row >= 0 && row < AppConstants.gameGridRows && col >= 0 && col < AppConstants.gameGridCols) {
        if (_gameGrid[row][col] != 0) { // Only sum non-empty cells
          sum += _gameGrid[row][col];
          cellsToRemove.add(cellOffset);
        }
      }
    }

    if (sum == _targetSum && cellsToRemove.isNotEmpty) {
      // Success!
      _score += cellsToRemove.length; // Score based on number of apples removed
      _saveHighScore(_score);

      for (final cellOffset in cellsToRemove) {
        final col = cellOffset.dx.toInt();
        final row = cellOffset.dy.toInt();
        _gameGrid[row][col] = 0; // Set to 0 to make it disappear
      }
      // This is where AudioService.playSuccessSound() would be called in GameScreen
    } else {
      // Failure!
      // This is where AudioService.vibrate() would be called in GameScreen
    }
    notifyListeners();
  }

  @override
  void dispose() {
    _gameTimer?.cancel();
    super.dispose();
  }
}