import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'firebase_options.dart';
import 'screens/home_screen.dart';
import 'screens/splash_screen.dart';
import 'screens/playlist_screen.dart';
import 'screens/music_player_screen.dart';
import 'screens/sign_in_screen.dart';
import 'screens/sign_up_screen.dart';
import 'screens/lectures_screen.dart';
import 'models/user_progress.dart';
import 'providers/music_player_provider.dart';
import 'providers/settings_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  usePathUrlStrategy();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UserProgress()),
        ChangeNotifierProvider(create: (_) => MusicPlayerProvider()),
        ChangeNotifierProvider(create: (_) => SettingsProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<SettingsProvider>(
      builder: (context, settings, _) {
        return MaterialApp(
          title: 'WorldClassroom',
          themeMode: settings.themeMode,
          theme: ThemeData(
            colorSchemeSeed: Colors.deepPurple,
            brightness: Brightness.light,
            useMaterial3: true,
            fontFamily: 'Nunito',
          ),
          darkTheme: ThemeData(
            colorSchemeSeed: Colors.deepPurple,
            brightness: Brightness.dark,
            useMaterial3: true,
            fontFamily: 'Nunito',
          ),
          debugShowCheckedModeBanner: false,
          initialRoute: '/splash',
          routes: {
            '/splash': (context) => const SplashScreen(),
            '/sign-in': (context) => const SignInScreen(),
            '/sign-up': (context) => const SignUpScreen(),
            '/': (context) => const HomeScreen(),
            '/playlist': (context) => const PlaylistScreen(),
            '/music-player': (context) => const MusicPlayerScreen(),
            LecturesScreen.routeName: (context) => const LecturesScreen(),
            FlashcardsScreen.routeName: (context) => const FlashcardsScreen(),
          },
        );
      },
    );
  }
}
