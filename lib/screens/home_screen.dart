import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'ai_supporter_screen.dart';
import 'education.dart';
import 'study_timer.dart';
import 'music_player_screen.dart';
import '../providers/music_player_provider.dart';
import '../widgets/mini_player.dart';
import 'wellness_screen.dart'; // ADD THIS IMPORT

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    EducationScreen(),
    const AISupporterScreen(),
    const WellnessScreen(),
    const StudyTimerScreen(),
  ];

  final List<String> _appBarTitles = [
    'Education Hub',
    'AI Supporter',
    'Wellness',
    'Study Timer'
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _appBarTitles[_selectedIndex],
          style: const TextStyle(
            fontSize: 18.0,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: Colors.deepPurple[50],
        elevation: 0,
        actions: [
          // Music button with status indicator
          Consumer<MusicPlayerProvider>(
            builder: (context, musicProvider, child) {
              return Stack(
                clipBehavior: Clip.none,
                children: [
                  IconButton(
                    icon: Icon(
                      musicProvider.isPlaying
                          ? Icons.music_note
                          : Icons.music_note_outlined,
                      color: musicProvider.isPlaying
                          ? Colors.deepPurple
                          : Colors.grey[700],
                    ),
                    onPressed: () {
                      Navigator.pushNamed(context, '/playlist');
                    },
                    tooltip: musicProvider.isPlaying
                        ? 'Now Playing: ${musicProvider.currentMusic?.title ?? "Music"}'
                        : 'Open Music Player',
                  ),
                  if (musicProvider.isPlaying)
                    Positioned(
                      right: 8,
                      top: 8,
                      child: Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: Colors.green,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              // Open settings
            },
            tooltip: 'Settings',
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFF5F7FA),
              Color(0xFFE4E7EB),
            ],
          ),
        ),
        child: Column(
          children: [
            // Mini player shows when music is playing
            Consumer<MusicPlayerProvider>(
              builder: (context, musicProvider, child) {
                if (musicProvider.currentMusic != null) {
                  return const MiniPlayer();
                }
                return const SizedBox.shrink();
              },
            ),
            // Main content
            Expanded(
              child: _screens[_selectedIndex],
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.deepPurple,
        unselectedItemColor: Colors.grey[600],
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.school),
            label: 'Learn',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.assistant),
            label: 'AI Helper',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite_outline),
            label: 'Wellness',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.timer),
            label: 'Timer',
          ),
        ],
      ),
    );
  }
}
