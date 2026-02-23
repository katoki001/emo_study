import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'screens/home_screen.dart';
import 'screens/splash_screen.dart'; // ← your new splash file
import 'screens/playlist_screen.dart';
import 'screens/music_player_screen.dart';
import 'models/user_progress.dart';
import 'providers/music_player_provider.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UserProgress()),
        ChangeNotifierProvider(create: (_) => MusicPlayerProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'WorldClassroom',
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
        useMaterial3: true,
        fontFamily: 'Nunito',
      ),
      debugShowCheckedModeBanner: false,
      initialRoute: '/splash', // ← starts on splash
      routes: {
        '/splash': (context) => const SplashScreen(), // splash file
        '/': (context) => const HomeScreen(),
        '/playlist': (context) => const PlaylistScreen(),
        '/music-player': (context) => const MusicPlayerScreen(),
      },
    );
  }
}
