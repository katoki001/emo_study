import 'package:flutter/material.dart';
import 'body_scan_screen.dart';
import 'mindful_grounding_screen.dart';

class WellnessScreen extends StatelessWidget {
  const WellnessScreen({super.key});

  final List<Map<String, dynamic>> _exercises = const [
    {
      'title': 'Box Breathing',
      'description': '4-4-4-4 breathing technique to calm your mind',
      'icon': Icons.air,
      'color': Color(0xFF6B8CFF),
      'duration': '5 min',
      'steps': [
        'Inhale slowly for 4 seconds',
        'Hold your breath for 4 seconds',
        'Exhale slowly for 4 seconds',
        'Hold empty for 4 seconds',
        'Repeat 4 times',
      ],
    },
    {
      'title': '4-7-8 Breathing',
      'description': 'Relaxing breath technique to reduce anxiety',
      'icon': Icons.self_improvement,
      'color': Color(0xFF8B6FFF),
      'duration': '3 min',
      'steps': [
        'Inhale quietly through nose for 4 seconds',
        'Hold your breath for 7 seconds',
        'Exhale completely through mouth for 8 seconds',
        'Repeat 3-4 times',
      ],
    },
    {
      'title': 'Body Scan',
      'description': 'Progressive relaxation from head to toe',
      'icon': Icons.accessibility_new,
      'color': Color(0xFF6FBBFF),
      'duration': '10 min',
      'steps': [
        'Close your eyes and breathe naturally',
        'Focus attention on the top of your head',
        'Slowly move awareness down to your face',
        'Continue down through neck, shoulders, arms',
        'Move through chest, stomach, hips',
        'Finally relax your legs and feet',
      ],
    },
    {
      'title': 'Mindful Grounding',
      'description': '5-4-3-2-1 technique to stay present',
      'icon': Icons.spa,
      'color': Color(0xFF6FFFD4),
      'duration': '5 min',
      'steps': [
        'Name 5 things you can see',
        'Name 4 things you can touch',
        'Name 3 things you can hear',
        'Name 2 things you can smell',
        'Name 1 thing you can taste',
      ],
    },
  ];

  @override
  Widget build(BuildContext context) {
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
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'How are you feeling?',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  'Track your mood and take a moment to relax',
                  style: TextStyle(color: Colors.white70, fontSize: 14),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Mood Tracker
          const Text(
            'Mood Today',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          _MoodTracker(),

          const SizedBox(height: 24),

          // Breathing Exercises
          const Text(
            'Relaxation Exercises',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          ..._exercises.map((exercise) => _ExerciseCard(exercise: exercise)),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Mood Tracker Widget
// ─────────────────────────────────────────────

class _MoodTracker extends StatefulWidget {
  @override
  State<_MoodTracker> createState() => _MoodTrackerState();
}

class _MoodTrackerState extends State<_MoodTracker> {
  int? _selectedMood;

  final List<Map<String, dynamic>> _moods = [
    {'emoji': '😔', 'label': 'Sad'},
    {'emoji': '😟', 'label': 'Stressed'},
    {'emoji': '😐', 'label': 'Neutral'},
    {'emoji': '🙂', 'label': 'Good'},
    {'emoji': '😄', 'label': 'Great'},
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(_moods.length, (index) {
          final isSelected = _selectedMood == index;
          return GestureDetector(
            onTap: () => setState(() => _selectedMood = index),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isSelected
                    ? Colors.deepPurple.withOpacity(0.15)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isSelected ? Colors.deepPurple : Colors.transparent,
                  width: 2,
                ),
              ),
              child: Column(
                children: [
                  Text(
                    _moods[index]['emoji'],
                    style: TextStyle(fontSize: isSelected ? 32 : 26),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _moods[index]['label'],
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight:
                          isSelected ? FontWeight.bold : FontWeight.normal,
                      color: isSelected ? Colors.deepPurple : Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Exercise Card Widget
// ─────────────────────────────────────────────

class _ExerciseCard extends StatelessWidget {
  final Map<String, dynamic> exercise;
  const _ExerciseCard({required this.exercise});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
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
            color: (exercise['color'] as Color).withOpacity(0.15),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            exercise['icon'] as IconData,
            color: exercise['color'] as Color,
            size: 28,
          ),
        ),
        title: Text(
          exercise['title'],
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              exercise['description'],
              style: TextStyle(color: Colors.grey[600], fontSize: 13),
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                Icon(Icons.timer_outlined, size: 14, color: Colors.grey[500]),
                const SizedBox(width: 4),
                Text(
                  exercise['duration'],
                  style: TextStyle(color: Colors.grey[500], fontSize: 12),
                ),
              ],
            ),
          ],
        ),
        trailing: const Icon(Icons.chevron_right, color: Colors.deepPurple),
        onTap: () {
          if (exercise['title'] == 'Body Scan') {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const BodyScanScreen()),
            );
          } else if (exercise['title'] == 'Mindful Grounding') {
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => const MindfulGroundingScreen()),
            );
          } else {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    _BreathingAnimationScreen(exercise: exercise),
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
  final Map<String, dynamic> exercise;
  const _BreathingAnimationScreen({required this.exercise});

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
  String _phaseLabel = 'Get Ready';
  bool _isRunning = false;
  int _cycleCount = 0;
  int _countdown = 0;

  late List<Map<String, dynamic>> _phases;

  @override
  void initState() {
    super.initState();

    _phases = _getPhasesForExercise(widget.exercise['title']);

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

  List<Map<String, dynamic>> _getPhasesForExercise(String title) {
    switch (title) {
      case 'Box Breathing':
        return [
          {'label': 'Inhale', 'duration': 4, 'expand': true},
          {'label': 'Hold', 'duration': 4, 'expand': false},
          {'label': 'Exhale', 'duration': 4, 'expand': false},
          {'label': 'Hold', 'duration': 4, 'expand': false},
        ];
      case '4-7-8 Breathing':
        return [
          {'label': 'Inhale', 'duration': 4, 'expand': true},
          {'label': 'Hold', 'duration': 7, 'expand': false},
          {'label': 'Exhale', 'duration': 8, 'expand': false},
        ];
      default:
        return [
          {'label': 'Inhale', 'duration': 4, 'expand': true},
          {'label': 'Exhale', 'duration': 4, 'expand': false},
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
      _phaseLabel = 'Get Ready';
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
      _phaseLabel = phase['label'] as String;
      _countdown = duration;
    });

    _breathController.duration = Duration(seconds: duration);

    if (expand) {
      _breathController.forward(from: _breathController.value);
    } else if (phase['label'] == 'Exhale' || phase['label'] == 'Breathe Out') {
      _breathController.reverse(from: _breathController.value);
    }

    for (int i = duration; i > 0; i--) {
      if (!mounted || !_isRunning) return;
      setState(() => _countdown = i);
      await Future.delayed(const Duration(seconds: 1));
    }

    if (!mounted || !_isRunning) return;

    final nextPhase = (phaseIndex + 1) % _phases.length;
    if (nextPhase == 0) {
      setState(() => _cycleCount++);
    }
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
    final color = widget.exercise['color'] as Color;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: Text(widget.exercise['title'] as String),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.deepPurple,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
            child: Text(
              widget.exercise['description'] as String,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[600], fontSize: 14),
            ),
          ),

          const Spacer(),

          // Animated breathing circle
          Center(
            child: AnimatedBuilder(
              animation:
                  Listenable.merge([_breathController, _pulseController]),
              builder: (context, child) {
                final scale = _scaleAnimation.value;
                final pulse = _isRunning ? 1.0 : _pulseAnimation.value;
                final animColor = _colorAnimation.value ?? color;

                return Stack(
                  alignment: Alignment.center,
                  children: [
                    // Outer glow rings
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

                    // Main circle
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
                              _isRunning ? _phaseLabel : 'Tap Start',
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

          // Cycle counter
          if (_isRunning)
            Text(
              'Cycles completed: $_cycleCount',
              style: TextStyle(color: Colors.grey[500], fontSize: 13),
            ),

          const SizedBox(height: 16),

          // Phase indicator dots
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
                        : Colors.grey[300],
                    borderRadius: BorderRadius.circular(4),
                  ),
                );
              }),
            ),

          const SizedBox(height: 24),

          // Start / Stop button
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      _isRunning ? Colors.grey[300] : Colors.deepPurple,
                  foregroundColor: _isRunning ? Colors.grey[700] : Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 0,
                ),
                onPressed: _isRunning ? _stopBreathing : _startBreathing,
                child: Text(
                  _isRunning ? 'Stop' : 'Start Breathing',
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
