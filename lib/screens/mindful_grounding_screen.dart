import 'package:flutter/material.dart';

class MindfulGroundingScreen extends StatefulWidget {
  const MindfulGroundingScreen({super.key});

  @override
  State<MindfulGroundingScreen> createState() => _MindfulGroundingScreenState();
}

class _MindfulGroundingScreenState extends State<MindfulGroundingScreen>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _tapController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _tapScaleAnimation;
  late Animation<double> _tapOpacityAnimation;

  bool _started = false;
  bool _finished = false;

  // Steps: sense name, count, color, emoji
  final List<Map<String, dynamic>> _steps = [
    {
      'sense': 'See',
      'prompt': 'Look around and name things you can see',
      'count': 5,
      'color': const Color(0xFF6FBBFF),
      'emoji': '👁️',
    },
    {
      'sense': 'Touch',
      'prompt': 'Notice things you can physically touch or feel',
      'count': 4,
      'color': const Color(0xFF8B6FFF),
      'emoji': '✋',
    },
    {
      'sense': 'Hear',
      'prompt': 'Listen carefully for sounds around you',
      'count': 3,
      'color': const Color(0xFF6FFFD4),
      'emoji': '👂',
    },
    {
      'sense': 'Smell',
      'prompt': 'Notice any scents or smells in the air',
      'count': 2,
      'color': const Color(0xFFFFB86F),
      'emoji': '👃',
    },
    {
      'sense': 'Taste',
      'prompt': 'Notice any taste in your mouth right now',
      'count': 1,
      'color': const Color(0xFFFF6F9C),
      'emoji': '👅',
    },
  ];

  int _currentStep = 0;
  int _remaining = 5; // taps left for current step

  @override
  void initState() {
    super.initState();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);

    _tapController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.06).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _tapScaleAnimation = Tween<double>(begin: 1.0, end: 0.88).animate(
      CurvedAnimation(parent: _tapController, curve: Curves.easeOut),
    );

    _tapOpacityAnimation = Tween<double>(begin: 1.0, end: 0.6).animate(
      CurvedAnimation(parent: _tapController, curve: Curves.easeOut),
    );
  }

  void _start() {
    setState(() {
      _started = true;
      _currentStep = 0;
      _remaining = _steps[0]['count'] as int;
      _finished = false;
    });
  }

  void _reset() {
    setState(() {
      _started = false;
      _finished = false;
      _currentStep = 0;
      _remaining = _steps[0]['count'] as int;
    });
  }

  void _onCircleTap() async {
    if (!_started || _finished) return;

    // Tap animation
    await _tapController.forward();
    _tapController.reverse();

    final newRemaining = _remaining - 1;

    if (newRemaining <= 0) {
      // Move to next step
      final nextStep = _currentStep + 1;
      if (nextStep >= _steps.length) {
        setState(() {
          _remaining = 0;
          _finished = true;
        });
      } else {
        setState(() {
          _currentStep = nextStep;
          _remaining = _steps[nextStep]['count'] as int;
        });
      }
    } else {
      setState(() => _remaining = newRemaining);
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _tapController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final step = _steps[_currentStep];
    final color = step['color'] as Color;
    final totalForStep = step['count'] as int;
    final progress = _started && !_finished
        ? (totalForStep - _remaining) / totalForStep
        : 0.0;

    return Scaffold(
      backgroundColor: const Color(0xFF0D1B2A),
      appBar: AppBar(
        title: const Text('Mindful Grounding'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // Top instruction card
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 400),
            child: Container(
              key: ValueKey('$_currentStep-$_started-$_finished'),
              margin: const EdgeInsets.fromLTRB(24, 8, 24, 0),
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.07),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white.withOpacity(0.1)),
              ),
              child: _finished
                  ? const Column(
                      children: [
                        Text('🌿', style: TextStyle(fontSize: 32)),
                        SizedBox(height: 8),
                        Text(
                          'Well done!',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'You\'ve completed the grounding exercise.\nTake a moment to notice how you feel.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    )
                  : !_started
                      ? const Column(
                          children: [
                            Text(
                              '5-4-3-2-1 Grounding',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 6),
                            Text(
                              'Each time you find something, tap the circle.\nIt will count down for you.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        )
                      : Column(
                          children: [
                            Text(
                              '${step['emoji']}  ${step['sense']}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              step['prompt'] as String,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.7),
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
            ),
          ),

          const Spacer(),

          // Main circle
          GestureDetector(
            onTap: _onCircleTap,
            child: AnimatedBuilder(
              animation: Listenable.merge([_pulseController, _tapController]),
              builder: (context, child) {
                final pulse =
                    (_started && !_finished) ? _pulseAnimation.value : 1.0;
                return Transform.scale(
                  scale: _tapScaleAnimation.value * pulse,
                  child: Opacity(
                    opacity: _tapOpacityAnimation.value,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // Glow rings
                        if (_started && !_finished)
                          ...List.generate(3, (i) {
                            return Container(
                              width: 230 + (i * 28.0),
                              height: 230 + (i * 28.0),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: color.withOpacity(
                                    (0.06 - i * 0.015).clamp(0.0, 1.0)),
                              ),
                            );
                          }),

                        // Progress ring
                        SizedBox(
                          width: 220,
                          height: 220,
                          child: CircularProgressIndicator(
                            value: _finished ? 1.0 : progress,
                            strokeWidth: 5,
                            backgroundColor: Colors.white.withOpacity(0.1),
                            valueColor: AlwaysStoppedAnimation<Color>(
                              _finished ? const Color(0xFF6FFFD4) : color,
                            ),
                          ),
                        ),

                        // Main filled circle
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 400),
                          width: 200,
                          height: 200,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: RadialGradient(
                              colors: _finished
                                  ? [
                                      const Color(0xFF6FFFD4).withOpacity(0.8),
                                      const Color(0xFF6FFFD4).withOpacity(0.4),
                                    ]
                                  : [
                                      color.withOpacity(0.85),
                                      color.withOpacity(0.5),
                                    ],
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: (_finished
                                        ? const Color(0xFF6FFFD4)
                                        : color)
                                    .withOpacity(0.35),
                                blurRadius: 30,
                                spreadRadius: 4,
                              ),
                            ],
                          ),
                          child: _finished
                              ? const Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text('✓',
                                        style: TextStyle(
                                            fontSize: 52, color: Colors.white)),
                                    Text(
                                      'Done!',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                )
                              : !_started
                                  ? const Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text('5',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 64,
                                              fontWeight: FontWeight.w200,
                                            )),
                                        Text(
                                          'Tap to Start',
                                          style: TextStyle(
                                            color: Colors.white70,
                                            fontSize: 14,
                                          ),
                                        ),
                                      ],
                                    )
                                  : Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          step['emoji'] as String,
                                          style: const TextStyle(fontSize: 32),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          '$_remaining',
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 64,
                                            fontWeight: FontWeight.w200,
                                          ),
                                        ),
                                        Text(
                                          'tap each one',
                                          style: TextStyle(
                                            color:
                                                Colors.white.withOpacity(0.7),
                                            fontSize: 13,
                                          ),
                                        ),
                                      ],
                                    ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          const Spacer(),

          // Step indicators
          if (_started)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(_steps.length, (i) {
                  final isDone =
                      i < _currentStep || (_finished && i == _currentStep);
                  final isCurrent = i == _currentStep && !_finished;
                  final stepColor = _steps[i]['color'] as Color;
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: isCurrent ? 24 : 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: isDone
                          ? stepColor.withOpacity(0.5)
                          : isCurrent
                              ? stepColor
                              : Colors.white.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(5),
                    ),
                  );
                }),
              ),
            ),

          // Button
          Padding(
            padding: const EdgeInsets.fromLTRB(40, 0, 40, 36),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: _started
                      ? Colors.white.withOpacity(0.1)
                      : const Color(0xFF6FFFD4).withOpacity(0.85),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 0,
                ),
                onPressed: _started ? _reset : _start,
                child: Text(
                  _finished
                      ? 'Start Again'
                      : _started
                          ? 'Reset'
                          : 'Start Grounding',
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
