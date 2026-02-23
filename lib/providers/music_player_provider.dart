import 'package:flutter/material.dart';
import '../models/music.dart';
import '../services/audio_service.dart';

class MusicPlayerProvider extends ChangeNotifier {
  late AudioService _audioService;
  bool _isInitialized = false;
  Duration _currentPosition = Duration.zero;
  Duration? _totalDuration;

  MusicPlayerProvider() {
    _audioService = AudioService();
    _setupListeners();
  }

  void _setupListeners() {
    // You can add periodic updates for position
    Future.delayed(const Duration(milliseconds: 500), () {
      if (_audioService.isPlaying) {
        _currentPosition = _audioService.currentPosition;
        notifyListeners();
      }
    });
  }

  Future<void> initializePlaylist(List<Music> playlist) async {
    await _audioService.initializePlaylist(playlist);
    _isInitialized = true;
    notifyListeners();
  }

  Future<void> play() async {
    await _audioService.play();
    notifyListeners();
  }

  Future<void> pause() async {
    await _audioService.pause();
    notifyListeners();
  }

  Future<void> next() async {
    await _audioService.next();
    notifyListeners();
  }

  Future<void> previous() async {
    await _audioService.previous();
    notifyListeners();
  }

  Future<void> seek(Duration position) async {
    await _audioService.seek(position);
    notifyListeners();
  }

  bool get isPlaying => _audioService.isPlaying;
  bool get isInitialized => _isInitialized;
  Music? get currentMusic => _audioService.currentMusic;
  Duration get currentPosition => _audioService.currentPosition;
  Duration? get totalDuration => _audioService.totalDuration;

  double get progressPercentage {
    if (totalDuration == null || totalDuration!.inSeconds == 0) {
      return 0;
    }
    return currentPosition.inSeconds / totalDuration!.inSeconds;
  }

  @override
  void dispose() {
    _audioService.dispose();
    super.dispose();
  }
}
