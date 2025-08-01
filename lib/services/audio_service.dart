// lib/services/audio_service.dart
import 'package:audioplayers/audioplayers.dart';
import 'package:vibration/vibration.dart';

class AudioService {
  late AudioPlayer _audioPlayer;

  AudioService() {
    _audioPlayer = AudioPlayer();
    _audioPlayer.setReleaseMode(ReleaseMode.release); // Release resources after playback
  }

  // Plays a success sound
  Future<void> playSuccessSound() async {
    await _audioPlayer.play(AssetSource('audio/success.mp3'));
  }

  // Plays an error sound
  Future<void> playErrorSound() async {
    await _audioPlayer.play(AssetSource('audio/error.mp3'));
  }

  // Triggers mobile vibration for incorrect selection

  Future<void> vibrate() async {
    if (await Vibration.hasVibrator() ?? false) {
      Vibration.vibrate(duration: 100);
    }
  }

  void dispose() {
    _audioPlayer.dispose();
  }
}