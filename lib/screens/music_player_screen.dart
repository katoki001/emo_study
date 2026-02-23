import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/music_player_provider.dart';

class MusicPlayerScreen extends StatefulWidget {
  const MusicPlayerScreen({super.key});

  @override
  State<MusicPlayerScreen> createState() => _MusicPlayerScreenState();
}

class _MusicPlayerScreenState extends State<MusicPlayerScreen> {
  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<MusicPlayerProvider>(context);
    final currentMusic = provider.currentMusic;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.deepPurple),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Now Playing',
          style: TextStyle(
            color: Colors.deepPurple,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: currentMusic == null
          ? const Center(
              child: CircularProgressIndicator(color: Colors.deepPurple),
            )
          : Column(
              children: [
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Album art with shadow
                      Container(
                        width: 280,
                        height: 280,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          image: DecorationImage(
                            image: AssetImage(currentMusic.coverArt),
                            fit: BoxFit.cover,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.deepPurple.withOpacity(0.3),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 40),
                      // Song title
                      Text(
                        currentMusic.title,
                        style: const TextStyle(
                          color: Colors.deepPurple,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      // Artist name
                      Text(
                        currentMusic.artist,
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 18,
                        ),
                      ),
                    ],
                  ),
                ),
                // Progress section
                _buildProgressSection(provider),
                // Controls
                _buildControls(provider),
                const SizedBox(height: 30),
              ],
            ),
    );
  }

  Widget _buildProgressSection(MusicPlayerProvider provider) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          // Time labels
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _formatDuration(provider.currentPosition),
                style: TextStyle(color: Colors.grey[600]),
              ),
              Text(
                _formatDuration(provider.totalDuration ?? Duration.zero),
                style: TextStyle(color: Colors.grey[600]),
              ),
            ],
          ),
          // Progress slider
          SliderTheme(
            data: SliderThemeData(
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
              overlayShape: const RoundSliderOverlayShape(overlayRadius: 16),
              activeTrackColor: Colors.deepPurple,
              inactiveTrackColor: Colors.grey[300],
              thumbColor: Colors.deepPurple,
            ),
            child: Slider(
              value: provider.progressPercentage,
              min: 0,
              max: 1,
              onChanged: (value) {
                // Implement seeking if needed
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildControls(MusicPlayerProvider provider) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        // Previous button
        IconButton(
          icon: const Icon(Icons.skip_previous, size: 40),
          color: Colors.deepPurple,
          onPressed: provider.previous,
        ),
        // Play/Pause button
        Consumer<MusicPlayerProvider>(
          builder: (context, provider, child) {
            return Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.deepPurple.withOpacity(0.3),
                    blurRadius: 15,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: IconButton(
                icon: Icon(
                  provider.isPlaying
                      ? Icons.pause_circle_filled
                      : Icons.play_circle_filled,
                  color: Colors.deepPurple,
                  size: 70,
                ),
                onPressed: provider.isPlaying ? provider.pause : provider.play,
              ),
            );
          },
        ),
        // Next button
        IconButton(
          icon: const Icon(Icons.skip_next, size: 40),
          color: Colors.deepPurple,
          onPressed: provider.next,
        ),
      ],
    );
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }
}
