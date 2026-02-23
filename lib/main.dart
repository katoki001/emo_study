import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'screens/home_screen.dart';
import 'models/user_progress.dart';
import 'providers/music_player_provider.dart';
import 'screens/playlist_screen.dart';
import 'screens/music_player_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => UserProgress()),
        ChangeNotifierProvider(create: (context) => MusicPlayerProvider()),
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
      title: 'AI Learning Companion',
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
        useMaterial3: true,
      ),
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      routes: {
        '/': (context) => const HomeScreen(),
        '/playlist': (context) => const PlaylistScreen(),
        '/music-player': (context) => const MusicPlayerScreen(),
      },
    );
  }
}
