import 'package:flutter/material.dart';
import 'dart:math' as math;

class BodyScanScreen extends StatefulWidget {
  const BodyScanScreen({super.key});

  @override
  State<BodyScanScreen> createState() => _BodyScanScreenState();
}

class _BodyScanScreenState extends State<BodyScanScreen>
    with TickerProviderStateMixin {
  late AnimationController _glowController;
  late AnimationController _progressController;
  late Animation<double> _glowAnimation;

  bool _isRunning = false;
  int _currentStep = 0;
  int _countdown = 0;

  final List<Map<String, dynamic>> _steps = [
    {
      'label': 'Close your eyes',
      'instruction': 'Breathe naturally and settle in',
      'part': BodyPart.none,
      'duration': 5,
    },
    {
      'label': 'Top of Head',
      'instruction': 'Feel the top of your head, release any tension',
      'part': BodyPart.head,
      'duration': 8,
    },
    {
      'label': 'Face & Neck',
      'instruction': 'Relax your jaw, eyes, forehead and neck',
      'part': BodyPart.face,
      'duration': 8,
    },
    {
      'label': 'Shoulders & Arms',
      'instruction': 'Let your shoulders drop, relax down to your fingertips',
      'part': BodyPart.shoulders,
      'duration': 10,
    },
    {
      'label': 'Chest & Stomach',
      'instruction': 'Feel your breath in your chest and belly',
      'part': BodyPart.chest,
      'duration': 10,
    },
    {
      'label': 'Hips & Lower Back',
      'instruction': 'Release tension in your hips and lower back',
      'part': BodyPart.hips,
      'duration': 10,
    },
    {
      'label': 'Legs & Feet',
      'instruction': 'Relax your thighs, calves, and feel your feet',
      'part': BodyPart.legs,
      'duration': 12,
    },
    {
      'label': 'Whole Body',
      'instruction': 'Your entire body is relaxed and at peace',
      'part': BodyPart.all,
      'duration': 8,
    },
  ];

  @override
  void initState() {
    super.initState();

    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);

    _progressController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );

    _glowAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOut),
    );
  }

  void _start() {
    setState(() {
      _isRunning = true;
      _currentStep = 0;
    });
    _runStep(0);
  }

  void _stop() {
    setState(() {
      _isRunning = false;
      _currentStep = 0;
      _countdown = 0;
    });
  }

  void _runStep(int stepIndex) async {
    if (!mounted || !_isRunning) return;
    if (stepIndex >= _steps.length) {
      setState(() {
        _isRunning = false;
        _currentStep = _steps.length - 1;
      });
      return;
    }

    final step = _steps[stepIndex];
    final duration = step['duration'] as int;

    setState(() {
      _currentStep = stepIndex;
      _countdown = duration;
    });

    for (int i = duration; i > 0; i--) {
      if (!mounted || !_isRunning) return;
      setState(() => _countdown = i);
      await Future.delayed(const Duration(seconds: 1));
    }

    if (!mounted || !_isRunning) return;
    _runStep(stepIndex + 1);
  }

  @override
  void dispose() {
    _glowController.dispose();
    _progressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final step = _steps[_isRunning ? _currentStep : 0];
    final activePart = _isRunning ? step['part'] as BodyPart : BodyPart.none;

    return Scaffold(
      backgroundColor: const Color(0xFF0D1B2A),
      appBar: AppBar(
        title: const Text('Body Scan'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // Instruction card
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 500),
            child: Container(
              key: ValueKey(_currentStep),
              margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.07),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: Colors.white.withOpacity(0.1),
                ),
              ),
              child: Column(
                children: [
                  Text(
                    _isRunning
                        ? step['label'] as String
                        : 'Body Scan Meditation',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    _isRunning
                        ? step['instruction'] as String
                        : 'Progressive relaxation from head to toe.\nTap Start to begin.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.7),
                      fontSize: 13,
                    ),
                  ),
                  if (_isRunning) ...[
                    const SizedBox(height: 10),
                    Text(
                      '$_countdown s',
                      style: const TextStyle(
                        color: Color(0xFF6FBBFF),
                        fontSize: 22,
                        fontWeight: FontWeight.w300,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),

          // Body illustration
          Expanded(
            child: Center(
              child: AnimatedBuilder(
                animation: _glowAnimation,
                builder: (context, child) {
                  return CustomPaint(
                    size: const Size(200, 380),
                    painter: BodyPainter(
                      activePart: activePart,
                      glowIntensity: _glowAnimation.value,
                    ),
                  );
                },
              ),
            ),
          ),

          // Progress dots
          if (_isRunning)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(_steps.length, (i) {
                  final isDone = i < _currentStep;
                  final isCurrent = i == _currentStep;
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    width: isCurrent ? 20 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: isDone
                          ? const Color(0xFF6FBBFF).withOpacity(0.5)
                          : isCurrent
                              ? const Color(0xFF6FBBFF)
                              : Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  );
                }),
              ),
            ),

          const SizedBox(height: 8),

          // Button
          Padding(
            padding: const EdgeInsets.fromLTRB(40, 0, 40, 32),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: _isRunning
                      ? Colors.white.withOpacity(0.1)
                      : const Color(0xFF6FBBFF),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 0,
                ),
                onPressed: _isRunning ? _stop : _start,
                child: Text(
                  _isRunning ? 'Stop' : 'Start Body Scan',
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

// ─────────────────────────────────────────────
// Body Parts Enum
// ─────────────────────────────────────────────

enum BodyPart { none, head, face, shoulders, chest, hips, legs, all }

// ─────────────────────────────────────────────
// Body Painter
// ─────────────────────────────────────────────

class BodyPainter extends CustomPainter {
  final BodyPart activePart;
  final double glowIntensity;

  BodyPainter({required this.activePart, required this.glowIntensity});

  static const Color baseColor = Color(0xFF2A3F5F);
  static const Color glowColor = Color(0xFF6FBBFF);
  static const Color outlineColor = Color(0xFF4A6FA5);

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;

    // Helper to get glow paint
    Paint glowPaint(BodyPart part) {
      final isActive = activePart == part || activePart == BodyPart.all;
      return Paint()
        ..color = isActive
            ? glowColor.withOpacity(0.3 + (0.4 * glowIntensity))
            : baseColor.withOpacity(0.8)
        ..style = PaintingStyle.fill;
    }

    Paint outlinePaint(BodyPart part) {
      final isActive = activePart == part || activePart == BodyPart.all;
      return Paint()
        ..color = isActive
            ? glowColor.withOpacity(0.8 + (0.2 * glowIntensity))
            : outlineColor.withOpacity(0.6)
        ..style = PaintingStyle.stroke
        ..strokeWidth = isActive ? 2.0 : 1.0;
    }

    void drawGlowShadow(Canvas canvas, Path path, BodyPart part) {
      if (activePart == part || activePart == BodyPart.all) {
        final shadowPaint = Paint()
          ..color = glowColor.withOpacity(0.25 * glowIntensity)
          ..style = PaintingStyle.fill
          ..maskFilter = MaskFilter.blur(BlurStyle.normal, 12 * glowIntensity);
        canvas.drawPath(path, shadowPaint);
      }
    }

    // ── HEAD ──
    final headPath = Path()
      ..addOval(Rect.fromCenter(
        center: Offset(cx, size.height * 0.09),
        width: 52,
        height: 58,
      ));
    drawGlowShadow(canvas, headPath, BodyPart.head);
    canvas.drawPath(headPath, glowPaint(BodyPart.head));
    canvas.drawPath(headPath, outlinePaint(BodyPart.head));

    // ── NECK ──
    final neckPath = Path()
      ..addRRect(RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(cx, size.height * 0.165),
          width: 22,
          height: 20,
        ),
        const Radius.circular(6),
      ));
    final neckPart =
        (activePart == BodyPart.face) ? BodyPart.face : BodyPart.none;
    drawGlowShadow(canvas, neckPath, neckPart);
    canvas.drawPath(neckPath, glowPaint(neckPart));
    canvas.drawPath(neckPath, outlinePaint(neckPart));

    // ── SHOULDERS & ARMS ──
    // Left arm
    final leftArm = Path()
      ..moveTo(cx - 26, size.height * 0.20)
      ..quadraticBezierTo(
        cx - 58,
        size.height * 0.28,
        cx - 54,
        size.height * 0.46,
      )
      ..quadraticBezierTo(
        cx - 52,
        size.height * 0.50,
        cx - 44,
        size.height * 0.46,
      )
      ..quadraticBezierTo(
        cx - 44,
        size.height * 0.30,
        cx - 18,
        size.height * 0.22,
      )
      ..close();
    drawGlowShadow(canvas, leftArm, BodyPart.shoulders);
    canvas.drawPath(leftArm, glowPaint(BodyPart.shoulders));
    canvas.drawPath(leftArm, outlinePaint(BodyPart.shoulders));

    // Right arm
    final rightArm = Path()
      ..moveTo(cx + 26, size.height * 0.20)
      ..quadraticBezierTo(
        cx + 58,
        size.height * 0.28,
        cx + 54,
        size.height * 0.46,
      )
      ..quadraticBezierTo(
        cx + 52,
        size.height * 0.50,
        cx + 44,
        size.height * 0.46,
      )
      ..quadraticBezierTo(
        cx + 44,
        size.height * 0.30,
        cx + 18,
        size.height * 0.22,
      )
      ..close();
    drawGlowShadow(canvas, rightArm, BodyPart.shoulders);
    canvas.drawPath(rightArm, glowPaint(BodyPart.shoulders));
    canvas.drawPath(rightArm, outlinePaint(BodyPart.shoulders));

    // Left hand
    final leftHand = Path()
      ..addOval(Rect.fromCenter(
        center: Offset(cx - 49, size.height * 0.505),
        width: 16,
        height: 20,
      ));
    drawGlowShadow(canvas, leftHand, BodyPart.shoulders);
    canvas.drawPath(leftHand, glowPaint(BodyPart.shoulders));
    canvas.drawPath(leftHand, outlinePaint(BodyPart.shoulders));

    // Right hand
    final rightHand = Path()
      ..addOval(Rect.fromCenter(
        center: Offset(cx + 49, size.height * 0.505),
        width: 16,
        height: 20,
      ));
    drawGlowShadow(canvas, rightHand, BodyPart.shoulders);
    canvas.drawPath(rightHand, glowPaint(BodyPart.shoulders));
    canvas.drawPath(rightHand, outlinePaint(BodyPart.shoulders));

    // ── TORSO (chest) ──
    final torsoPath = Path()
      ..moveTo(cx - 26, size.height * 0.19)
      ..lineTo(cx - 30, size.height * 0.38)
      ..lineTo(cx - 22, size.height * 0.45)
      ..lineTo(cx + 22, size.height * 0.45)
      ..lineTo(cx + 30, size.height * 0.38)
      ..lineTo(cx + 26, size.height * 0.19)
      ..close();
    drawGlowShadow(canvas, torsoPath, BodyPart.chest);
    canvas.drawPath(torsoPath, glowPaint(BodyPart.chest));
    canvas.drawPath(torsoPath, outlinePaint(BodyPart.chest));

    // ── HIPS ──
    final hipsPath = Path()
      ..moveTo(cx - 22, size.height * 0.45)
      ..lineTo(cx - 28, size.height * 0.54)
      ..lineTo(cx - 14, size.height * 0.565)
      ..lineTo(cx, size.height * 0.56)
      ..lineTo(cx + 14, size.height * 0.565)
      ..lineTo(cx + 28, size.height * 0.54)
      ..lineTo(cx + 22, size.height * 0.45)
      ..close();
    drawGlowShadow(canvas, hipsPath, BodyPart.hips);
    canvas.drawPath(hipsPath, glowPaint(BodyPart.hips));
    canvas.drawPath(hipsPath, outlinePaint(BodyPart.hips));

    // ── LEGS ──
    // Left leg
    final leftLeg = Path()
      ..moveTo(cx - 14, size.height * 0.555)
      ..lineTo(cx - 20, size.height * 0.76)
      ..lineTo(cx - 10, size.height * 0.84)
      ..lineTo(cx - 4, size.height * 0.76)
      ..lineTo(cx - 2, size.height * 0.555)
      ..close();
    drawGlowShadow(canvas, leftLeg, BodyPart.legs);
    canvas.drawPath(leftLeg, glowPaint(BodyPart.legs));
    canvas.drawPath(leftLeg, outlinePaint(BodyPart.legs));

    // Right leg
    final rightLeg = Path()
      ..moveTo(cx + 14, size.height * 0.555)
      ..lineTo(cx + 20, size.height * 0.76)
      ..lineTo(cx + 10, size.height * 0.84)
      ..lineTo(cx + 4, size.height * 0.76)
      ..lineTo(cx + 2, size.height * 0.555)
      ..close();
    drawGlowShadow(canvas, rightLeg, BodyPart.legs);
    canvas.drawPath(rightLeg, glowPaint(BodyPart.legs));
    canvas.drawPath(rightLeg, outlinePaint(BodyPart.legs));

    // Left foot
    final leftFoot = Path()
      ..moveTo(cx - 20, size.height * 0.845)
      ..quadraticBezierTo(
        cx - 22,
        size.height * 0.88,
        cx - 8,
        size.height * 0.88,
      )
      ..lineTo(cx - 6, size.height * 0.855)
      ..close();
    drawGlowShadow(canvas, leftFoot, BodyPart.legs);
    canvas.drawPath(leftFoot, glowPaint(BodyPart.legs));
    canvas.drawPath(leftFoot, outlinePaint(BodyPart.legs));

    // Right foot
    final rightFoot = Path()
      ..moveTo(cx + 20, size.height * 0.845)
      ..quadraticBezierTo(
        cx + 22,
        size.height * 0.88,
        cx + 8,
        size.height * 0.88,
      )
      ..lineTo(cx + 6, size.height * 0.855)
      ..close();
    drawGlowShadow(canvas, rightFoot, BodyPart.legs);
    canvas.drawPath(rightFoot, glowPaint(BodyPart.legs));
    canvas.drawPath(rightFoot, outlinePaint(BodyPart.legs));

    // ── FACE DETAILS (eyes + mouth, shown when face is active) ──
    if (activePart == BodyPart.face || activePart == BodyPart.all) {
      final eyePaint = Paint()
        ..color = glowColor.withOpacity(0.9)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(Offset(cx - 10, size.height * 0.08), 3, eyePaint);
      canvas.drawCircle(Offset(cx + 10, size.height * 0.08), 3, eyePaint);

      final mouthPaint = Paint()
        ..color = glowColor.withOpacity(0.7)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..strokeCap = StrokeCap.round;
      canvas.drawArc(
        Rect.fromCenter(
          center: Offset(cx, size.height * 0.105),
          width: 18,
          height: 10,
        ),
        0,
        math.pi,
        false,
        mouthPaint,
      );
    }
  }

  @override
  bool shouldRepaint(BodyPainter oldDelegate) {
    return oldDelegate.activePart != activePart ||
        oldDelegate.glowIntensity != glowIntensity;
  }
}
