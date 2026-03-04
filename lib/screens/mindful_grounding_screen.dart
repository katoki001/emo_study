import 'package:flutter/material.dart';
import '../l10n/app_strings.dart';

class MindfulGroundingScreen extends StatefulWidget {
  final String lang;
  final bool isDark;
  const MindfulGroundingScreen(
      {super.key, this.lang = 'en', this.isDark = true});

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

  List<Map<String, dynamic>> get _steps => [
        {
          'sense': AppStrings.get('mg_see', widget.lang),
          'prompt': AppStrings.get('mg_see_prompt', widget.lang),
          'count': 5,
          'color': const Color(0xFF6FBBFF),
          'emoji': '👁️',
        },
        {
          'sense': AppStrings.get('mg_touch', widget.lang),
          'prompt': AppStrings.get('mg_touch_prompt', widget.lang),
          'count': 4,
          'color': const Color(0xFF8B6FFF),
          'emoji': '✋',
        },
        {
          'sense': AppStrings.get('mg_hear', widget.lang),
          'prompt': AppStrings.get('mg_hear_prompt', widget.lang),
          'count': 3,
          'color': const Color(0xFF6FFFD4),
          'emoji': '👂',
        },
        {
          'sense': AppStrings.get('mg_smell', widget.lang),
          'prompt': AppStrings.get('mg_smell_prompt', widget.lang),
          'count': 2,
          'color': const Color(0xFFFFB86F),
          'emoji': '👃',
        },
        {
          'sense': AppStrings.get('mg_taste', widget.lang),
          'prompt': AppStrings.get('mg_taste_prompt', widget.lang),
          'count': 1,
          'color': const Color(0xFFFF6F9C),
          'emoji': '👅',
        },
      ];

  int _currentStep = 0;
  int _remaining = 5;

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

    await _tapController.forward();
    _tapController.reverse();

    final newRemaining = _remaining - 1;

    if (newRemaining <= 0) {
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
    final isDark = widget.isDark;
    final steps = _steps;
    final step = steps[_currentStep];
    final color = step['color'] as Color;
    final totalForStep = step['count'] as int;
    final progress = _started && !_finished
        ? (totalForStep - _remaining) / totalForStep
        : 0.0;

    // Theme-aware colors
    final scaffoldBg =
        isDark ? const Color(0xFF0D1B2A) : const Color(0xFFF0F6FF);
    final cardBg = isDark ? Colors.white.withOpacity(0.07) : Colors.white;
    final cardBorder =
        isDark ? Colors.white.withOpacity(0.1) : Colors.blue.withOpacity(0.15);
    final titleColor = isDark ? Colors.white : const Color(0xFF0D1B2A);
    final subtitleColor = isDark ? Colors.white70 : Colors.black54;
    final dotInactive = isDark
        ? Colors.white.withOpacity(0.15)
        : Colors.black.withOpacity(0.10);
    final resetBtnBg =
        isDark ? Colors.white.withOpacity(0.1) : Colors.black.withOpacity(0.08);
    final resetBtnFg = isDark ? Colors.white : Colors.black87;

    return Scaffold(
      backgroundColor: scaffoldBg,
      appBar: AppBar(
        title: Text(
          AppStrings.get('mindful_grounding', widget.lang),
          style: TextStyle(color: titleColor),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: titleColor),
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
                color: cardBg,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: cardBorder),
                boxShadow: isDark
                    ? []
                    : [
                        BoxShadow(
                          color: Colors.blue.withOpacity(0.07),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        )
                      ],
              ),
              child: _finished
                  ? Column(
                      children: [
                        const Text('🌿', style: TextStyle(fontSize: 32)),
                        const SizedBox(height: 8),
                        Text(
                          AppStrings.get('well_done', widget.lang),
                          style: TextStyle(
                            color: titleColor,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          AppStrings.get('grounding_complete', widget.lang),
                          textAlign: TextAlign.center,
                          style: TextStyle(color: subtitleColor, fontSize: 13),
                        ),
                      ],
                    )
                  : !_started
                      ? Column(
                          children: [
                            Text(
                              '5-4-3-2-1 ${AppStrings.get('mindful_grounding', widget.lang)}',
                              style: TextStyle(
                                color: titleColor,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              AppStrings.get('mg_intro', widget.lang),
                              textAlign: TextAlign.center,
                              style:
                                  TextStyle(color: subtitleColor, fontSize: 13),
                            ),
                          ],
                        )
                      : Column(
                          children: [
                            Text(
                              '${step['emoji']}  ${step['sense']}',
                              style: TextStyle(
                                color: titleColor,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              step['prompt'] as String,
                              textAlign: TextAlign.center,
                              style:
                                  TextStyle(color: subtitleColor, fontSize: 13),
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
                            backgroundColor: isDark
                                ? Colors.white.withOpacity(0.1)
                                : Colors.black.withOpacity(0.08),
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
                                    .withOpacity(isDark ? 0.35 : 0.25),
                                blurRadius: 30,
                                spreadRadius: 4,
                              ),
                            ],
                          ),
                          child: _finished
                              ? Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Text('✓',
                                        style: TextStyle(
                                            fontSize: 52, color: Colors.white)),
                                    Text(
                                      AppStrings.get('done', widget.lang),
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                )
                              : !_started
                                  ? Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        const Text('5',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 64,
                                              fontWeight: FontWeight.w200,
                                            )),
                                        Text(
                                          AppStrings.get(
                                              'tap_to_start', widget.lang),
                                          style: const TextStyle(
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
                                          AppStrings.get(
                                              'tap_each_one', widget.lang),
                                          style: const TextStyle(
                                            color: Colors.white70,
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
                children: List.generate(steps.length, (i) {
                  final isDone =
                      i < _currentStep || (_finished && i == _currentStep);
                  final isCurrent = i == _currentStep && !_finished;
                  final stepColor = steps[i]['color'] as Color;
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
                              : dotInactive,
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
                      ? resetBtnBg
                      : const Color(0xFF6FFFD4).withOpacity(0.85),
                  foregroundColor: _started ? resetBtnFg : Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 0,
                ),
                onPressed: _started ? _reset : _start,
                child: Text(
                  _finished
                      ? AppStrings.get('start_again', widget.lang)
                      : _started
                          ? AppStrings.get('reset', widget.lang)
                          : AppStrings.get('start_grounding', widget.lang),
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
