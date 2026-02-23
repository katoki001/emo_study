import 'package:audioplayers/audioplayers.dart';
import '../models/music.dart';

class AudioService {
  final AudioPlayer _audioPlayer = AudioPlayer();
  List<Music> _playlist = [];
  int _currentIndex = 0;
  bool _isPlaying = false;
  Duration _currentPosition = Duration.zero;
  Duration? _totalDuration;

  AudioService() {
    _setupAudioPlayer();
  }

  void _setupAudioPlayer() {
    // Set source to local assets only
    _audioPlayer.setSource(UrlSource('')); // REMOVE THIS LINE COMPLETELY

    // Listen to position changes
    _audioPlayer.onPositionChanged.listen((position) {
      _currentPosition = position;
    });

    // Listen to state changes
    _audioPlayer.onPlayerStateChanged.listen((state) {
      print('Player state: $state');
      _isPlaying = state == PlayerState.playing;
    });

    // Listen to duration changes
    _audioPlayer.onDurationChanged.listen((duration) {
      _totalDuration = duration;
      print('Duration: $duration');
    });

    // Listen to completion
    _audioPlayer.onPlayerComplete.listen((event) {
      print('Track completed, playing next');
      next();
    });
  }

  Future<void> initializePlaylist(List<Music> playlist) async {
    _playlist = playlist;
    if (_playlist.isNotEmpty) {
      await _loadTrack(0);
    }
  }

  Future<void> _loadTrack(int index) async {
    if (index >= 0 && index < _playlist.length) {
      _currentIndex = index;
      final music = _playlist[index];

      try {
        print('========== PLAYING TRACK ==========');
        print('Title: ${music.title}');
        print('Asset path: ${music.assetPath}');
        print('===================================');

        // Stop current playback
        await _audioPlayer.stop();

        // ✅ ONLY use local assets - NO URLs
        await _audioPlayer.play(AssetSource(music.assetPath));

        print('✅ Successfully playing from assets');
      } catch (e) {
        print('❌ ERROR: $e');
        print('❌ Could not play: ${music.assetPath}');
        print('❌ Make sure the file exists in assets/audio/');
      }
    }
  }

  Future<void> play() async {
    try {
      await _audioPlayer.resume();
    } catch (e) {
      print('Error playing: $e');
    }
  }

  Future<void> pause() async {
    try {
      await _audioPlayer.pause();
    } catch (e) {
      print('Error pausing: $e');
    }
  }

  Future<void> stop() async {
    try {
      await _audioPlayer.stop();
    } catch (e) {
      print('Error stopping: $e');
    }
  }

  Future<void> next() async {
    if (_currentIndex < _playlist.length - 1) {
      await _loadTrack(_currentIndex + 1);
    } else {
      // Loop back to first
      await _loadTrack(0);
    }
  }

  Future<void> previous() async {
    if (_currentIndex > 0) {
      await _loadTrack(_currentIndex - 1);
    }
  }

  Future<void> seek(Duration position) async {
    await _audioPlayer.seek(position);
  }

  // Getters
  bool get isPlaying => _isPlaying;
  int get currentIndex => _currentIndex;
  Music? get currentMusic =>
      _playlist.isNotEmpty ? _playlist[_currentIndex] : null;
  Duration get currentPosition => _currentPosition;
  Duration? get totalDuration => _totalDuration;

  void dispose() {
    _audioPlayer.dispose();
  }
}
