import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/music_player_provider.dart';
import '../screens/music_player_screen.dart';

class MiniPlayer extends StatelessWidget {
  const MiniPlayer({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<MusicPlayerProvider>(
      builder: (context, provider, child) {
        if (provider.currentMusic == null) {
          return const SizedBox.shrink();
        }

        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const MusicPlayerScreen(),
              ),
            );
          },
          child: Container(
            height: 70,
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, -2),
                ),
              ],
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(12),
                bottomRight: Radius.circular(12),
              ),
            ),
            child: Row(
              children: [
                // Album art
                Container(
                  width: 50,
                  height: 50,
                  margin: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    image: DecorationImage(
                      image: AssetImage(provider.currentMusic!.coverArt),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                // Song info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        provider.currentMusic!.title,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        provider.currentMusic!.artist,
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 12,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                // Progress indicator - using the provider's properties directly
                SizedBox(
                  width: 40,
                  child: LinearProgressIndicator(
                    value: provider.progressPercentage,
                    backgroundColor: Colors.grey[300],
                    valueColor:
                        const AlwaysStoppedAnimation<Color>(Colors.deepPurple),
                  ),
                ),
                // Controls
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.skip_previous, size: 20),
                      color: Colors.deepPurple,
                      onPressed: provider.previous,
                    ),
                    IconButton(
                      icon: Icon(
                        provider.isPlaying ? Icons.pause : Icons.play_arrow,
                        size: 28,
                      ),
                      color: Colors.deepPurple,
                      onPressed:
                          provider.isPlaying ? provider.pause : provider.play,
                    ),
                    IconButton(
                      icon: const Icon(Icons.skip_next, size: 20),
                      color: Colors.deepPurple,
                      onPressed: provider.next,
                    ),
                  ],
                ),
                const SizedBox(width: 8),
              ],
            ),
          ),
        );
      },
    );
  }
}
