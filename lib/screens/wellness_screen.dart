import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/settings_provider.dart';
import '../l10n/app_strings.dart';
import 'body_scan_screen.dart';
import 'mindful_grounding_screen.dart';

class WellnessScreen extends StatelessWidget {
  const WellnessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();
    final lang = settings.language;
    final isDark = settings.isDark;

    final List<Map<String, dynamic>> exercises = [
      {
        'titleKey': 'box_breathing',
        'descKey': 'box_breathing_desc',
        'icon': Icons.air,
        'color': const Color(0xFF6B8CFF),
        'duration': '5 min',
        'phaseType': 'box',
      },
      {
        'titleKey': '478_breathing',
        'descKey': '478_breathing_desc',
        'icon': Icons.self_improvement,
        'color': const Color(0xFF8B6FFF),
        'duration': '3 min',
        'phaseType': '478',
      },
      {
        'titleKey': 'body_scan',
        'descKey': 'body_scan_desc',
        'icon': Icons.accessibility_new,
        'color': const Color(0xFF6FBBFF),
        'duration': '10 min',
        'phaseType': 'bodyscan',
      },
      {
        'titleKey': 'mindful_grounding',
        'descKey': 'mindful_grounding_desc',
        'icon': Icons.spa,
        'color': const Color(0xFF6FFFD4),
        'duration': '5 min',
        'phaseType': 'grounding',
      },
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF6B8CFF), Color(0xFF8B6FFF)],
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppStrings.get('how_are_you_feeling', lang),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  AppStrings.get('wellness_subtitle', lang),
                  style: const TextStyle(color: Colors.white70, fontSize: 14),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          Text(
            AppStrings.get('mood_today', lang),
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
          const SizedBox(height: 12),
          //_MoodTracker(isDark: isDark, lang: lang),

          const SizedBox(height: 24),

          Text(
            AppStrings.get('relaxation_exercises', lang),
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
          const SizedBox(height: 12),
          ...exercises.map((e) => _ExerciseCard(
                exercise: e,
                isDark: isDark,
                lang: lang,
              )),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Mood Tracker
// ─────────────────────────────────────────────
// ─────────────────────────────────────────────
// Exercise Card
// ─────────────────────────────────────────────

class _ExerciseCard extends StatelessWidget {
  final Map<String, dynamic> exercise;
  final bool isDark;
  final String lang;

  const _ExerciseCard({
    required this.exercise,
    required this.isDark,
    required this.lang,
  });

  @override
  Widget build(BuildContext context) {
    final color = exercise['color'] as Color;
    final title = AppStrings.get(exercise['titleKey'] as String, lang);
    final desc = AppStrings.get(exercise['descKey'] as String, lang);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E2A3A) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.3 : 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.withOpacity(0.15),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(exercise['icon'] as IconData, color: color, size: 28),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: isDark ? Colors.white : Colors.black87,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              desc,
              style: TextStyle(
                color: isDark ? Colors.white54 : Colors.grey[600],
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                Icon(Icons.timer_outlined,
                    size: 14,
                    color: isDark ? Colors.white38 : Colors.grey[500]),
                const SizedBox(width: 4),
                Text(
                  exercise['duration'] as String,
                  style: TextStyle(
                    color: isDark ? Colors.white38 : Colors.grey[500],
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ],
        ),
        trailing: const Icon(Icons.chevron_right, color: Colors.deepPurple),
        onTap: () {
          final phaseType = exercise['phaseType'] as String;
          if (phaseType == 'bodyscan') {
            Navigator.push(
              context,
              MaterialPageRoute(
                // ✅ lang and isDark now passed through
                builder: (_) => BodyScanScreen(lang: lang, isDark: isDark),
              ),
            );
          } else if (phaseType == 'grounding') {
            Navigator.push(
              context,
              MaterialPageRoute(
                // ✅ lang and isDark now passed through
                builder: (_) =>
                    MindfulGroundingScreen(lang: lang, isDark: isDark),
              ),
            );
          } else {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => _BreathingAnimationScreen(
                  title: title,
                  description: desc,
                  color: color,
                  phaseType: phaseType,
                  isDark: isDark,
                  lang: lang,
                ),
              ),
            );
          }
        },
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Breathing Animation Screen
// ─────────────────────────────────────────────

class _BreathingAnimationScreen extends StatefulWidget {
  final String title;
  final String description;
  final Color color;
  final String phaseType;
  final bool isDark;
  final String lang;

  const _BreathingAnimationScreen({
    required this.title,
    required this.description,
    required this.color,
    required this.phaseType,
    required this.isDark,
    required this.lang,
  });

  @override
  State<_BreathingAnimationScreen> createState() =>
      _BreathingAnimationScreenState();
}

class _BreathingAnimationScreenState extends State<_BreathingAnimationScreen>
    with TickerProviderStateMixin {
  late AnimationController _breathController;
  late AnimationController _pulseController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _pulseAnimation;
  late Animation<Color?> _colorAnimation;

  int _currentPhase = 0;
  String _phaseLabel = '';
  bool _isRunning = false;
  int _cycleCount = 0;
  int _countdown = 0;

  late List<Map<String, dynamic>> _phases;

  @override
  void initState() {
    super.initState();
    _phases = _getPhasesForType(widget.phaseType);
    _phaseLabel = AppStrings.get('get_ready', widget.lang);

    _breathController = AnimationController(
      vsync: this,
      duration: Duration(seconds: _phases[0]['duration'] as int),
    );

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    _scaleAnimation = Tween<double>(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(parent: _breathController, curve: Curves.easeInOut),
    );
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.08).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    _colorAnimation = ColorTween(
      begin: const Color(0xFF6B8CFF),
      end: const Color(0xFF8B6FFF),
    ).animate(_breathController);
  }

  List<Map<String, dynamic>> _getPhasesForType(String type) {
    switch (type) {
      case 'box':
        return [
          {'labelKey': 'inhale', 'duration': 4, 'expand': true},
          {'labelKey': 'hold', 'duration': 4, 'expand': false},
          {'labelKey': 'exhale', 'duration': 4, 'expand': false},
          {'labelKey': 'hold', 'duration': 4, 'expand': false},
        ];
      case '478':
        return [
          {'labelKey': 'inhale', 'duration': 4, 'expand': true},
          {'labelKey': 'hold', 'duration': 7, 'expand': false},
          {'labelKey': 'exhale', 'duration': 8, 'expand': false},
        ];
      default:
        return [
          {'labelKey': 'inhale', 'duration': 4, 'expand': true},
          {'labelKey': 'exhale', 'duration': 4, 'expand': false},
        ];
    }
  }

  void _startBreathing() {
    setState(() {
      _isRunning = true;
      _cycleCount = 0;
      _currentPhase = 0;
    });
    _runPhase(0);
  }

  void _stopBreathing() {
    _breathController.stop();
    _breathController.reset();
    setState(() {
      _isRunning = false;
      _phaseLabel = AppStrings.get('get_ready', widget.lang);
      _currentPhase = 0;
      _countdown = 0;
    });
  }

  void _runPhase(int phaseIndex) async {
    if (!mounted || !_isRunning) return;

    final phase = _phases[phaseIndex];
    final duration = phase['duration'] as int;
    final expand = phase['expand'] as bool;

    setState(() {
      _currentPhase = phaseIndex;
      _phaseLabel = AppStrings.get(phase['labelKey'] as String, widget.lang);
      _countdown = duration;
    });

    _breathController.duration = Duration(seconds: duration);

    if (expand) {
      _breathController.forward(from: _breathController.value);
    } else if (phase['labelKey'] == 'exhale') {
      _breathController.reverse(from: _breathController.value);
    }

    for (int i = duration; i > 0; i--) {
      if (!mounted || !_isRunning) return;
      setState(() => _countdown = i);
      await Future.delayed(const Duration(seconds: 1));
    }

    if (!mounted || !_isRunning) return;

    final nextPhase = (phaseIndex + 1) % _phases.length;
    if (nextPhase == 0) setState(() => _cycleCount++);
    _runPhase(nextPhase);
  }

  @override
  void dispose() {
    _breathController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final lang = widget.lang;
    final isDark = widget.isDark;

    return Scaffold(
      backgroundColor:
          isDark ? const Color(0xFF1A1A2E) : const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: Text(widget.title),
        backgroundColor: isDark ? const Color(0xFF16213E) : Colors.transparent,
        elevation: 0,
        foregroundColor: isDark ? Colors.white : Colors.deepPurple,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
            child: Text(
              widget.description,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: isDark ? Colors.white54 : Colors.grey[600],
                fontSize: 14,
              ),
            ),
          ),
          const Spacer(),
          Center(
            child: AnimatedBuilder(
              animation:
                  Listenable.merge([_breathController, _pulseController]),
              builder: (context, child) {
                final scale = _scaleAnimation.value;
                final pulse = _isRunning ? 1.0 : _pulseAnimation.value;
                final animColor = _colorAnimation.value ?? widget.color;

                return Stack(
                  alignment: Alignment.center,
                  children: [
                    ...List.generate(3, (i) {
                      return Container(
                        width: 220 + (i * 30.0) + (scale * 40),
                        height: 220 + (i * 30.0) + (scale * 40),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: animColor
                              .withOpacity(0.04 - (i * 0.01).clamp(0.0, 0.04)),
                        ),
                      );
                    }),
                    Transform.scale(
                      scale: pulse,
                      child: Container(
                        width: 180 + (scale * 80),
                        height: 180 + (scale * 80),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: RadialGradient(
                            colors: [
                              animColor.withOpacity(0.9),
                              animColor.withOpacity(0.6),
                            ],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: animColor.withOpacity(0.4),
                              blurRadius: 30 + (scale * 20),
                              spreadRadius: 5,
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              _isRunning
                                  ? _phaseLabel
                                  : AppStrings.get('tap_start', lang),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            if (_isRunning && _countdown > 0) ...[
                              const SizedBox(height: 8),
                              Text(
                                '$_countdown',
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 36,
                                  fontWeight: FontWeight.w300,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
          const Spacer(),
          if (_isRunning)
            Text(
              '${AppStrings.get('cycles_completed', lang)}: $_cycleCount',
              style: TextStyle(
                color: isDark ? Colors.white38 : Colors.grey[500],
                fontSize: 13,
              ),
            ),
          const SizedBox(height: 16),
          if (_isRunning)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(_phases.length, (i) {
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: _currentPhase == i ? 24 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: _currentPhase == i
                        ? Colors.deepPurple
                        : (isDark ? Colors.white24 : Colors.grey[300]),
                    borderRadius: BorderRadius.circular(4),
                  ),
                );
              }),
            ),
          const SizedBox(height: 24),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: _isRunning
                      ? (isDark ? Colors.white24 : Colors.grey[300])
                      : Colors.deepPurple,
                  foregroundColor: _isRunning
                      ? (isDark ? Colors.white70 : Colors.grey[700])
                      : Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 0,
                ),
                onPressed: _isRunning ? _stopBreathing : _startBreathing,
                child: Text(
                  _isRunning
                      ? AppStrings.get('stop', lang)
                      : AppStrings.get('start_breathing', lang),
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }
}
