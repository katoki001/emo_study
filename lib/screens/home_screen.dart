import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'ai_supporter_screen.dart';
import 'education_screen.dart';
import 'study_timer.dart';
import 'music_player_screen.dart';
import '../providers/music_player_provider.dart';
import '../providers/settings_provider.dart';
import '../widgets/mini_player.dart';
import '../l10n/app_strings.dart';
import 'wellness_screen.dart';
import 'settings_screen.dart';

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

  @override
  Widget build(BuildContext context) {
    return Consumer<SettingsProvider>(
      builder: (context, settings, _) {
        final lang = settings.language;
        final isDark = settings.isDark;

        final List<String> appBarTitles = [
          AppStrings.get('education_hub', lang),
          AppStrings.get('ai_supporter', lang),
          AppStrings.get('wellness_title', lang),
          AppStrings.get('study_timer', lang),
        ];

        return Scaffold(
          appBar: AppBar(
            title: Text(
              appBarTitles[_selectedIndex],
              style: const TextStyle(
                fontSize: 18.0,
                fontWeight: FontWeight.w600,
              ),
            ),
            backgroundColor:
                isDark ? const Color(0xFF16213E) : Colors.deepPurple[50],
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
                              : (isDark ? Colors.white70 : Colors.grey[700]),
                        ),
                        onPressed: () {
                          Navigator.pushNamed(context, '/playlist');
                        },
                        tooltip: musicProvider.isPlaying
                            ? '${AppStrings.get('now_playing', lang)}: ${musicProvider.currentMusic?.title ?? "Music"}'
                            : AppStrings.get('open_music', lang),
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
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const SettingsScreen(),
                    ),
                  );
                },
                tooltip: AppStrings.get('settings', lang),
              ),
            ],
          ),
          body: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: isDark
                    ? const [Color(0xFF1A1A2E), Color(0xFF16213E)]
                    : const [Color(0xFFF5F7FA), Color(0xFFE4E7EB)],
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
            unselectedItemColor: isDark ? Colors.white54 : Colors.grey[600],
            backgroundColor: isDark ? const Color(0xFF16213E) : Colors.white,
            items: [
              BottomNavigationBarItem(
                icon: const Icon(Icons.school),
                label: AppStrings.get('learn', lang),
              ),
              BottomNavigationBarItem(
                icon: const Icon(Icons.assistant),
                label: AppStrings.get('ai_helper', lang),
              ),
              BottomNavigationBarItem(
                icon: const Icon(Icons.favorite_outline),
                label: AppStrings.get('wellness', lang),
              ),
              BottomNavigationBarItem(
                icon: const Icon(Icons.timer),
                label: AppStrings.get('timer', lang),
              ),
            ],
          ),
        );
      },
    );
  }
}
