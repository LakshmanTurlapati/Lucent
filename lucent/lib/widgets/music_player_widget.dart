import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:just_audio/just_audio.dart';
import 'dart:async';
import 'dart:math' as math;
import '../utils/asset_helper.dart';
import '../utils/music_service.dart';

class MusicPlayerWidget extends StatefulWidget {
  const MusicPlayerWidget({super.key});

  @override
  State<MusicPlayerWidget> createState() => _MusicPlayerWidgetState();
}

class _MusicPlayerWidgetState extends State<MusicPlayerWidget> {
  // Timer to refresh UI periodically to update position
  Timer? _positionTimer;
  
  @override
  void initState() {
    super.initState();
    
    // Initialize the audio service
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final musicService = context.read<MusicService>();
      musicService.init();
    });
    
    // Set up timer to refresh UI for position updates
    _positionTimer = Timer.periodic(const Duration(milliseconds: 200), (_) {
      if (mounted) setState(() {});
    });
  }
  
  @override
  void dispose() {
    _positionTimer?.cancel();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    // Spotify green color
    final Color spotifyGreen = const Color(0xFF1DB954);
    
    return Consumer<MusicService>(
      builder: (context, musicService, child) {
        final currentSong = musicService.currentSong;
        final isPlaying = musicService.isPlaying;
        final isShuffle = musicService.isShuffleEnabled;
        final position = musicService.currentPosition;
        final duration = musicService.totalDuration;
        
        return Container(
          decoration: BoxDecoration(
            color: const Color(0xFF171717), // Dark background
            borderRadius: BorderRadius.circular(16.0),
          ),
          width: double.infinity,
          height: double.infinity,
          child: LayoutBuilder(
            builder: (context, constraints) {
              // Calculate proportional sizes based on available dimensions
              final double width = constraints.maxWidth;
              final double height = constraints.maxHeight;
              
              // Scale up all sizes by ~15%
              final double albumArtSize = math.min(width * 0.21, height * 0.25);
              final double titleFontSize = math.min(width * 0.057, height * 0.069);
              final double artistFontSize = math.min(width * 0.044, height * 0.052);
              final double controlIconSize = math.min(width * 0.08, height * 0.086);
              final double playButtonSize = math.min(width * 0.138, height * 0.138);
              final double timeFontSize = math.min(width * 0.037, height * 0.04);
              
              return Padding(
                padding: const EdgeInsets.all(9.2), // Increased padding
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    // Album art and song info
                    Row(
                      children: [
                        // Album art
                        AssetHelper.loadAlbumArt(
                          artPath: currentSong.albumArt,
                          width: albumArtSize,
                          height: albumArtSize,
                          placeholderColor: Colors.grey[800],
                        ),
                        
                        SizedBox(width: width * 0.035), // Increased spacing
                        
                        // Song title and artist
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                currentSong.title,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: titleFontSize,
                                  fontWeight: FontWeight.w600,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              SizedBox(height: height * 0.009), // Slightly increased spacing
                              Text(
                                currentSong.artist,
                                style: TextStyle(
                                  color: Colors.grey[400],
                                  fontSize: artistFontSize,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    
                    // Progress slider
                    SliderTheme(
                      data: SliderThemeData(
                        trackHeight: height * 0.008, // Slightly thicker
                        thumbColor: Colors.white,
                        thumbShape: RoundSliderThumbShape(enabledThumbRadius: height * 0.018),
                        overlayShape: RoundSliderOverlayShape(overlayRadius: height * 0.035),
                        activeTrackColor: spotifyGreen,
                        inactiveTrackColor: Colors.grey[800],
                      ),
                      child: Slider(
                        value: math.max(0, math.min(position.inMilliseconds.toDouble(), 
                            duration.inMilliseconds.toDouble())),
                        max: math.max(1, duration.inMilliseconds.toDouble()),
                        onChanged: (value) {
                          // Seek to position when slider is moved
                          musicService.seekTo(Duration(milliseconds: value.toInt()));
                        },
                      ),
                    ),
                    
                    // Time indicators
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: width * 0.046),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            _formatDuration(position),
                            style: TextStyle(
                              color: Colors.grey[400],
                              fontSize: timeFontSize,
                            ),
                          ),
                          Text(
                            _formatDuration(duration),
                            style: TextStyle(
                              color: Colors.grey[400],
                              fontSize: timeFontSize,
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    // Playback controls
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        // Shuffle button
                        IconButton(
                          icon: Icon(
                            Icons.shuffle,
                            color: isShuffle ? spotifyGreen : Colors.white,
                          ),
                          iconSize: controlIconSize * 0.8, // Slightly larger
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          onPressed: () => musicService.toggleShuffle(),
                        ),
                        
                        // Previous button
                        IconButton(
                          icon: const Icon(Icons.skip_previous),
                          color: Colors.white,
                          iconSize: controlIconSize,
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          onPressed: () => musicService.previous(),
                        ),
                        
                        // Play/Pause button
                        Container(
                          width: playButtonSize,
                          height: playButtonSize,
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                          child: IconButton(
                            icon: Icon(
                              isPlaying ? Icons.pause : Icons.play_arrow,
                              color: Colors.black,
                            ),
                            iconSize: controlIconSize,
                            padding: EdgeInsets.zero,
                            onPressed: () => musicService.playPause(),
                          ),
                        ),
                        
                        // Next button
                        IconButton(
                          icon: const Icon(Icons.skip_next),
                          color: Colors.white,
                          iconSize: controlIconSize,
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          onPressed: () => musicService.next(),
                        ),
                        
                        // Repeat button
                        IconButton(
                          icon: Icon(
                            musicService.repeatMode == LoopMode.off ? Icons.repeat :
                            musicService.repeatMode == LoopMode.one ? Icons.repeat_one :
                            Icons.repeat,
                            color: musicService.repeatMode == LoopMode.off ? Colors.white : spotifyGreen,
                          ),
                          color: Colors.white,
                          iconSize: controlIconSize * 0.8, // Slightly larger
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          onPressed: () => musicService.toggleRepeat(),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            }
          ),
        );
      }
    );
  }
  
  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }
} 