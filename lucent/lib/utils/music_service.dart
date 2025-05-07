import 'package:just_audio/just_audio.dart';
import 'package:audio_session/audio_session.dart';
import 'package:flutter/foundation.dart';
import 'dart:math';

// Explicitly use the RepeatMode from just_audio
export 'package:just_audio/just_audio.dart' show RepeatMode;

class Song {
  final String title;
  final String artist;
  final String albumArt;
  final String audioFile;

  Song({
    required this.title,
    required this.artist,
    required this.albumArt,
    required this.audioFile,
  });
}

class MusicService extends ChangeNotifier {
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isInitialized = false;
  bool _isShuffleEnabled = false;
  
  // Use direct LoopMode enum from just_audio
  LoopMode _loopMode = LoopMode.off;
  
  // Add flag to track if we are manually handling song completion
  bool _processingCompletion = false;
  
  List<Song> _playlist = [
    Song(
      title: 'I Wanna Be Yours',
      artist: 'Arctic Monkeys',
      albumArt: 'I Wanna Be Yours',
      audioFile: 'I Wanna Be Yours.mp3',
    ),
    Song(
      title: 'Sunflower',
      artist: 'Post Malone & Swae Lee',
      albumArt: 'Sunflower',
      audioFile: 'Sunflower.mp3',
    ),
    Song(
      title: 'Memory Box',
      artist: 'Peter Cat Recording Co.',
      albumArt: 'Memory Box',
      audioFile: 'Memory Box.mp3',
    ),
    Song(
      title: 'No. 1 Party Anthem',
      artist: 'Arctic Monkeys',
      albumArt: 'No. 1 Party Anthem',
      audioFile: 'No. 1 Party Anthem.mp3',
    ),
  ];
  
  List<int> _shuffleIndices = [];
  int _currentIndex = 0;
  
  // Public getters
  AudioPlayer get audioPlayer => _audioPlayer;
  bool get isPlaying => _audioPlayer.playing;
  bool get isShuffleEnabled => _isShuffleEnabled;
  Duration get currentPosition => _audioPlayer.position;
  Duration get totalDuration => _audioPlayer.duration ?? Duration.zero;
  LoopMode get repeatMode => _loopMode;
  
  Song get currentSong {
    if (_playlist.isEmpty) {
      return Song(
        title: 'No songs available',
        artist: 'Unknown',
        albumArt: '',
        audioFile: '',
      );
    }
    
    if (_isShuffleEnabled) {
      return _playlist[_shuffleIndices[_currentIndex]];
    } else {
      return _playlist[_currentIndex];
    }
  }

  // Initialize the audio player
  Future<void> init() async {
    if (_isInitialized) return;
    
    final session = await AudioSession.instance;
    await session.configure(const AudioSessionConfiguration.music());
    
    // Listen for player state changes
    _audioPlayer.playerStateStream.listen((playerState) {
      final processingState = playerState.processingState;
      
      // When a song completes
      if (processingState == ProcessingState.completed && !_processingCompletion) {
        _processingCompletion = true;
        
        // Handle song completion based on repeat mode
        if (_loopMode == LoopMode.one) {
          // For 'repeat one', loop the current song
          _audioPlayer.seek(Duration.zero).then((_) {
            _audioPlayer.play();
            _processingCompletion = false;
          });
        } else if (_loopMode == LoopMode.all) {
          // For 'repeat all', go to the next song (with wrap-around)
          _playNextSong(true).then((_) {
            _processingCompletion = false;
          });
        } else {
          // For 'no repeat', go to next song if available
          if (_currentIndex < _playlist.length - 1) {
            _playNextSong(false).then((_) {
              _processingCompletion = false;
            });
          } else {
            // End of playlist reached with no repeat
            _processingCompletion = false;
          }
        }
      }
      
      notifyListeners();
    });
    
    _audioPlayer.positionStream.listen((_) {
      notifyListeners();
    });
    
    // Initialize shuffle indices
    _resetShuffleIndices();
    
    // Load first song
    if (_playlist.isNotEmpty) {
      await _loadSong(_currentIndex);
    }
    
    _isInitialized = true;
  }
  
  // Toggle repeat mode cycling through off -> all -> one
  Future<void> toggleRepeat() async {
    switch (_loopMode) {
      case LoopMode.off:
        _loopMode = LoopMode.all;
        break;
      case LoopMode.all:
        _loopMode = LoopMode.one;
        break;
      case LoopMode.one:
        _loopMode = LoopMode.off;
        break;
    }
    
    // Only use native loop for LoopMode.one
    // We handle LoopMode.all ourselves for more control
    await _audioPlayer.setLoopMode(_loopMode == LoopMode.one ? LoopMode.one : LoopMode.off);
    
    notifyListeners();
  }
  
  // Helper method to play the next song
  Future<void> _playNextSong(bool allowWrapAround) async {
    int nextIndex = _currentIndex + 1;
    
    // If we're at the end of the playlist
    if (nextIndex >= _playlist.length) {
      // Only wrap around if allowed (for LoopMode.all)
      if (allowWrapAround) {
        nextIndex = 0;
      } else {
        // End of playlist with no repeat
        return;
      }
    }
    
    await _loadSong(nextIndex);
    await _audioPlayer.play();
  }
  
  // Load a song by index
  Future<void> _loadSong(int index) async {
    if (index < 0 || index >= _playlist.length) return;
    
    final songIndex = _isShuffleEnabled ? _shuffleIndices[index] : index;
    final assetPath = 'assets/Music/${_playlist[songIndex].audioFile}';
    
    try {
      await _audioPlayer.setAsset(assetPath);
      _currentIndex = index;
      notifyListeners();
    } catch (e) {
      if (kDebugMode) {
        print('Error loading audio: $e');
      }
    }
  }
  
  // Reset shuffle indices
  void _resetShuffleIndices() {
    _shuffleIndices = List.generate(_playlist.length, (index) => index);
    if (_isShuffleEnabled) {
      _shuffleIndices.shuffle();
    }
  }
  
  // Play/pause toggle
  Future<void> playPause() async {
    if (isPlaying) {
      await _audioPlayer.pause();
    } else {
      await _audioPlayer.play();
    }
    notifyListeners();
  }
  
  // Skip to next song
  Future<void> next() async {
    bool allowWrapAround = _loopMode == LoopMode.all;
    await _playNextSong(allowWrapAround);
  }
  
  // Skip to previous song
  Future<void> previous() async {
    int prevIndex = _currentIndex - 1;
    
    // If we're at the beginning, wrap around only if in repeat all mode
    if (prevIndex < 0) {
      if (_loopMode == LoopMode.all) {
        prevIndex = _playlist.length - 1;
      } else {
        // At beginning with no repeat, just restart current song
        await _audioPlayer.seek(Duration.zero);
        if (isPlaying) {
          await _audioPlayer.play();
        }
        return;
      }
    }
    
    await _loadSong(prevIndex);
    if (isPlaying) {
      await _audioPlayer.play();
    }
  }
  
  // Toggle shuffle mode
  Future<void> toggleShuffle() async {
    _isShuffleEnabled = !_isShuffleEnabled;
    
    // Remember current song
    final currentSongPath = currentSong.audioFile;
    
    // Reset shuffle indices
    _resetShuffleIndices();
    
    // Find the index of the current song in the new shuffle order
    if (_isShuffleEnabled) {
      for (int i = 0; i < _shuffleIndices.length; i++) {
        if (_playlist[_shuffleIndices[i]].audioFile == currentSongPath) {
          _currentIndex = i;
          break;
        }
      }
    } else {
      for (int i = 0; i < _playlist.length; i++) {
        if (_playlist[i].audioFile == currentSongPath) {
          _currentIndex = i;
          break;
        }
      }
    }
    
    notifyListeners();
  }
  
  // Seek to a specific position
  Future<void> seekTo(Duration position) async {
    await _audioPlayer.seek(position);
    notifyListeners();
  }
  
  // Clean up resources
  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }
} 