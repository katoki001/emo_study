import 'package:flutter/material.dart';

class AppColors {
  // Primary Colors
  static const primary = Color(0xFF6C63FF);
  static const secondary = Color(0xFF4A90E2);
  static const accent = Color(0xFF00D4AA);

  // Background Colors
  static const background = Color(0xFFF5F7FA);
  static const cardBackground = Color(0xFFFFFFFF);
  static const dialogBackground = Color(0xFFFFFFFF);

  // Text Colors
  static const textPrimary = Color(0xFF333333);
  static const textSecondary = Color(0xFF666666);
  static const textHint = Color(0xFF999999);
  static const textLight = Color(0xFFFFFFFF);

  // Status Colors
  static const success = Color(0xFF4CAF50);
  static const warning = Color(0xFFFF9800);
  static const error = Color(0xFFF44336);
  static const info = Color(0xFF2196F3);

  // Emotion Colors (for your emotion chart)
  static const emotionFocus = Color(0xFF4A90E2);
  static const emotionMotivation = Color(0xFF00D4AA);
  static const emotionStress = Color(0xFFFF6B6B);
  static const emotionRest = Color(0xFF9B59B6);
  static const emotionConfidence = Color(0xFFF1C40F);

  // Subject Colors (for your education screen)
  static const subjectPhysics = Color(0xFF3498DB);
  static const subjectMath = Color(0xFF9B59B6);
  static const subjectChemistry = Color(0xFF2ECC71);
  static const subjectBiology = Color(0xFF1ABC9C);
  static const subjectCS = Color(0xFFE74C3C);
  static const subjectHistory = Color(0xFFE67E22);
  static const subjectLanguages = Color(0xFFF1C40F);
  static const subjectArt = Color(0xFFE84393);

  // Gradient Colors
  static const gradientPrimary = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF6C63FF), Color(0xFF4A90E2)],
  );

  static const gradientSuccess = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF00D4AA), Color(0xFF00B894)],
  );

  static const gradientWarning = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFFF9F43), Color(0xFFFF7F00)],
  );
}

class AppStrings {
  // App Info
  static const appName = 'AI Learning Companion';
  static const appTagline = 'Personalized Education with AI';
  static const appVersion = '1.0.0';

  // AI Assistant
  static const aiAssistantName = 'Study Assistant';
  static const aiAssistantWelcome =
      'Hello! I\'m your AI learning companion. How can I help you today?';

  // Welcome Messages
  static const defaultWelcome = 'Welcome back!';
  static const morningWelcome = 'Good morning! Ready to learn?';
  static const afternoonWelcome = 'Good afternoon! Keep going!';
  static const eveningWelcome = 'Good evening! Time to review!';

  // Education Screen
  static const chooseSubject = 'Choose Your Subject';
  static const startAssessment = 'Start AI Assessment';
  static const assessmentDescription =
      'AI will assess your knowledge and create a personalized learning plan';

  // Progress Screen
  static const weeklyProgress = 'Weekly Progress';
  static const emotionAnalysis = 'Emotion Analysis';
  static const studyRecommendations = 'Study Recommendations';

  // Timer Screen
  static const studyTime = 'Study Time';
  static const breakTime = 'Break Time';
  static const focusMode = 'Focus Mode';
  static const relaxMode = 'Relax Mode';

  // AI Recommendations
  static const lowRestRecommendation =
      'Your rest score is low. Consider taking a 15-minute break and doing a quick meditation exercise to improve focus.';
  static const lowFocusRecommendation =
      'Try the Pomodoro technique: 25 minutes focused study, 5 minutes break.';
  static const lowMotivationRecommendation =
      'Set small, achievable goals and reward yourself after completing them!';

  // Button Texts
  static const startLearning = 'Start Learning';
  static const continueLearning = 'Continue Learning';
  static const takeBreak = 'Take a Break';
  static const askAI = 'Ask AI Assistant';
  static const updateProgress = 'Update Progress';
}

class AppDimens {
  // Padding & Margins
  static const double screenPadding = 16.0;
  static const double cardPadding = 20.0;
  static const double buttonPadding = 16.0;
  static const double elementSpacing = 12.0;
  static const double largeSpacing = 24.0;

  // Border Radius
  static const double borderRadiusSmall = 8.0;
  static const double borderRadiusMedium = 12.0;
  static const double borderRadiusLarge = 20.0;
  static const double borderRadiusXLarge = 30.0;

  // Card Dimensions
  static const double cardElevation = 4.0;
  static const double cardBorderWidth = 1.0;

  // Button Dimensions
  static const double buttonHeight = 48.0;
  static const double buttonBorderRadius = 24.0;

  // Icon Sizes
  static const double iconSizeSmall = 16.0;
  static const double iconSizeMedium = 24.0;
  static const double iconSizeLarge = 40.0;
  static const double iconSizeXLarge = 60.0;

  // Chart Dimensions
  static const double chartHeight = 200.0;
  static const double chartBarWidth = 20.0;

  // Avatar Sizes
  static const double avatarSmall = 32.0;
  static const double avatarMedium = 48.0;
  static const double avatarLarge = 64.0;
}

class AppAssets {
  // Image Paths (you'll create these in assets/images/ folder)
  static const String aiBrain = 'assets/images/ai_brain.png';
  static const String welcomeIllustration =
      'assets/images/welcome_illustration.png';
  static const String progressChart = 'assets/images/progress_chart.png';
  static const String emptyState = 'assets/images/empty_state.png';

  // Icon Paths
  static const String physicsIcon = 'assets/icons/physics.png';
  static const String mathIcon = 'assets/icons/math.png';
  static const String chemistryIcon = 'assets/icons/chemistry.png';
  static const String biologyIcon = 'assets/icons/biology.png';

  // Sound Paths (for your ambient sounds)
  static const String rainSound = 'assets/sounds/rain.mp3';
  static const String forestSound = 'assets/sounds/forest.mp3';
  static const String focusSound = 'assets/sounds/focus.mp3';
  static const String pianoSound = 'assets/sounds/piano.mp3';

  // Lottie Animations (optional)
  static const String loadingAnimation = 'assets/animations/loading.json';
  static const String successAnimation = 'assets/animations/success.json';
  static const String celebrationAnimation =
      'assets/animations/celebration.json';
}

class AppRoutes {
  // Screen Routes
  static const String home = '/';
  static const String education = '/education';
  static const String progress = '/progress';
  static const String aiSupporter = '/ai-supporter';
  static const String studyTimer = '/study-timer';
  static const String subjectDetail = '/subject-detail';
  static const String settings = '/settings';
  static const String profile = '/profile';
}

// Helper function to get greeting based on time
String getTimeBasedGreeting() {
  final hour = DateTime.now().hour;

  if (hour < 12) {
    return AppStrings.morningWelcome;
  } else if (hour < 17) {
    return AppStrings.afternoonWelcome;
  } else {
    return AppStrings.eveningWelcome;
  }
}

// Helper function to get subject color
Color getSubjectColor(String subject) {
  switch (subject.toLowerCase()) {
    case 'physics':
      return AppColors.subjectPhysics;
    case 'mathematics':
    case 'math':
      return AppColors.subjectMath;
    case 'chemistry':
      return AppColors.subjectChemistry;
    case 'biology':
      return AppColors.subjectBiology;
    case 'computer science':
    case 'cs':
      return AppColors.subjectCS;
    case 'history':
      return AppColors.subjectHistory;
    case 'languages':
      return AppColors.subjectLanguages;
    case 'art':
    case 'music':
      return AppColors.subjectArt;
    default:
      return AppColors.primary;
  }
}

// Helper function to get subject icon
IconData getSubjectIcon(String subject) {
  switch (subject.toLowerCase()) {
    case 'physics':
      return Icons.rocket_launch;
    case 'mathematics':
    case 'math':
      return Icons.calculate;
    case 'chemistry':
      return Icons.science;
    case 'biology':
      return Icons.eco;
    case 'computer science':
    case 'cs':
      return Icons.code;
    case 'history':
      return Icons.history;
    case 'languages':
      return Icons.language;
    case 'art':
    case 'music':
      return Icons.music_note;
    default:
      return Icons.school;
  }
}
