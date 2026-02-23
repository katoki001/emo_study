import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../data/music_data.dart';
import '../models/music.dart';
import '../providers/music_player_provider.dart';
import 'music_player_screen.dart';

class PlaylistScreen extends StatelessWidget {
  const PlaylistScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lofi Playlist'),
        backgroundColor: Colors.blueGrey[900],
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.blueGrey[900]!, Colors.blueGrey[800]!],
          ),
        ),
        child: ListView.builder(
          itemCount: MusicData.lofiPlaylist.length,
          itemBuilder: (context, index) {
            final music = MusicData.lofiPlaylist[index];
            return _buildPlaylistItem(context, music, index);
          },
        ),
      ),
    );
  }

  Widget _buildPlaylistItem(BuildContext context, Music music, int index) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: Colors.blueGrey[800],
      child: ListTile(
        leading: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            image: DecorationImage(
              image: AssetImage(music.coverArt),
              fit: BoxFit.cover,
            ),
          ),
        ),
        title: Text(
          music.title,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(
          '${music.artist} • ${music.duration}',
          style: const TextStyle(color: Colors.white70),
        ),
        trailing: IconButton(
          icon: const Icon(Icons.play_circle_filled, color: Colors.teal),
          onPressed: () async {
            final provider =
                Provider.of<MusicPlayerProvider>(context, listen: false);
            await provider.initializePlaylist(MusicData.lofiPlaylist);

            // Set to specific song
            // Note: You'll need to modify the provider to set specific index
            // For now, it plays from start

            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const MusicPlayerScreen(),
              ),
            );
          },
        ),
      ),
    );
  }
}
