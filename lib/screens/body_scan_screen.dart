import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../l10n/app_strings.dart';

class BodyScanScreen extends StatefulWidget {
  final String lang;
  final bool isDark;
  const BodyScanScreen({super.key, this.lang = 'en', this.isDark = true});

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

  List<Map<String, dynamic>> get _steps => [
        {
          'label': AppStrings.get('bs_close_eyes', widget.lang),
          'instruction': AppStrings.get('bs_close_eyes_inst', widget.lang),
          'part': BodyPart.none,
          'duration': 5,
        },
        {
          'label': AppStrings.get('bs_head', widget.lang),
          'instruction': AppStrings.get('bs_head_inst', widget.lang),
          'part': BodyPart.head,
          'duration': 8,
        },
        {
          'label': AppStrings.get('bs_face', widget.lang),
          'instruction': AppStrings.get('bs_face_inst', widget.lang),
          'part': BodyPart.face,
          'duration': 8,
        },
        {
          'label': AppStrings.get('bs_shoulders', widget.lang),
          'instruction': AppStrings.get('bs_shoulders_inst', widget.lang),
          'part': BodyPart.shoulders,
          'duration': 10,
        },
        {
          'label': AppStrings.get('bs_chest', widget.lang),
          'instruction': AppStrings.get('bs_chest_inst', widget.lang),
          'part': BodyPart.chest,
          'duration': 10,
        },
        {
          'label': AppStrings.get('bs_hips', widget.lang),
          'instruction': AppStrings.get('bs_hips_inst', widget.lang),
          'part': BodyPart.hips,
          'duration': 10,
        },
        {
          'label': AppStrings.get('bs_legs', widget.lang),
          'instruction': AppStrings.get('bs_legs_inst', widget.lang),
          'part': BodyPart.legs,
          'duration': 12,
        },
        {
          'label': AppStrings.get('bs_whole', widget.lang),
          'instruction': AppStrings.get('bs_whole_inst', widget.lang),
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
    final steps = _steps;
    if (stepIndex >= steps.length) {
      setState(() {
        _isRunning = false;
        _currentStep = steps.length - 1;
      });
      return;
    }

    final step = steps[stepIndex];
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
    final isDark = widget.isDark;
    final steps = _steps;
    final step = steps[_isRunning ? _currentStep : 0];
    final activePart = _isRunning ? step['part'] as BodyPart : BodyPart.none;

    // Theme-aware colors
    final scaffoldBg =
        isDark ? const Color(0xFF0D1B2A) : const Color(0xFFF0F6FF);
    final cardBg = isDark ? Colors.white.withOpacity(0.07) : Colors.white;
    final cardBorder =
        isDark ? Colors.white.withOpacity(0.1) : Colors.blue.withOpacity(0.15);
    final titleColor = isDark ? Colors.white : const Color(0xFF0D1B2A);
    final subtitleColor =
        isDark ? Colors.white.withOpacity(0.7) : Colors.black54;
    final accentColor = const Color(0xFF6FBBFF);
    final dotInactive =
        isDark ? Colors.white.withOpacity(0.2) : Colors.black.withOpacity(0.12);
    final stopBtnBg =
        isDark ? Colors.white.withOpacity(0.1) : Colors.black.withOpacity(0.08);

    return Scaffold(
      backgroundColor: scaffoldBg,
      appBar: AppBar(
        title: Text(
          AppStrings.get('body_scan', widget.lang),
          style: TextStyle(color: titleColor),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: titleColor),
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
              child: Column(
                children: [
                  Text(
                    _isRunning
                        ? step['label'] as String
                        : AppStrings.get('body_scan', widget.lang),
                    style: TextStyle(
                      color: titleColor,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    _isRunning
                        ? step['instruction'] as String
                        : AppStrings.get('bs_intro', widget.lang),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: subtitleColor,
                      fontSize: 13,
                    ),
                  ),
                  if (_isRunning) ...[
                    const SizedBox(height: 10),
                    Text(
                      '$_countdown s',
                      style: TextStyle(
                        color: accentColor,
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
                      isDark: isDark,
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
                children: List.generate(steps.length, (i) {
                  final isDone = i < _currentStep;
                  final isCurrent = i == _currentStep;
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    width: isCurrent ? 20 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: isDone
                          ? accentColor.withOpacity(0.5)
                          : isCurrent
                              ? accentColor
                              : dotInactive,
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
                  backgroundColor: _isRunning ? stopBtnBg : accentColor,
                  foregroundColor: _isRunning
                      ? (isDark ? Colors.white : Colors.black87)
                      : Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 0,
                ),
                onPressed: _isRunning ? _stop : _start,
                child: Text(
                  _isRunning
                      ? AppStrings.get('stop', widget.lang)
                      : AppStrings.get('start_body_scan', widget.lang),
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
  final bool isDark;

  BodyPainter({
    required this.activePart,
    required this.glowIntensity,
    this.isDark = true,
  });

  Color get baseColor =>
      isDark ? const Color(0xFF2A3F5F) : const Color(0xFFD0E4F7);
  Color get glowColor => const Color(0xFF6FBBFF);
  Color get outlineColor =>
      isDark ? const Color(0xFF4A6FA5) : const Color(0xFF7AABDC);

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;

    Paint glowPaint(BodyPart part) {
      final isActive = activePart == part || activePart == BodyPart.all;
      return Paint()
        ..color = isActive
            ? glowColor.withOpacity(0.3 + (0.4 * glowIntensity))
            : baseColor.withOpacity(isDark ? 0.8 : 1.0)
        ..style = PaintingStyle.fill;
    }

    Paint outlinePaint(BodyPart part) {
      final isActive = activePart == part || activePart == BodyPart.all;
      return Paint()
        ..color = isActive
            ? glowColor.withOpacity(0.8 + (0.2 * glowIntensity))
            : outlineColor.withOpacity(isDark ? 0.6 : 0.8)
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
    final leftArm = Path()
      ..moveTo(cx - 26, size.height * 0.20)
      ..quadraticBezierTo(
          cx - 58, size.height * 0.28, cx - 54, size.height * 0.46)
      ..quadraticBezierTo(
          cx - 52, size.height * 0.50, cx - 44, size.height * 0.46)
      ..quadraticBezierTo(
          cx - 44, size.height * 0.30, cx - 18, size.height * 0.22)
      ..close();
    drawGlowShadow(canvas, leftArm, BodyPart.shoulders);
    canvas.drawPath(leftArm, glowPaint(BodyPart.shoulders));
    canvas.drawPath(leftArm, outlinePaint(BodyPart.shoulders));

    final rightArm = Path()
      ..moveTo(cx + 26, size.height * 0.20)
      ..quadraticBezierTo(
          cx + 58, size.height * 0.28, cx + 54, size.height * 0.46)
      ..quadraticBezierTo(
          cx + 52, size.height * 0.50, cx + 44, size.height * 0.46)
      ..quadraticBezierTo(
          cx + 44, size.height * 0.30, cx + 18, size.height * 0.22)
      ..close();
    drawGlowShadow(canvas, rightArm, BodyPart.shoulders);
    canvas.drawPath(rightArm, glowPaint(BodyPart.shoulders));
    canvas.drawPath(rightArm, outlinePaint(BodyPart.shoulders));

    final leftHand = Path()
      ..addOval(Rect.fromCenter(
        center: Offset(cx - 49, size.height * 0.505),
        width: 16,
        height: 20,
      ));
    drawGlowShadow(canvas, leftHand, BodyPart.shoulders);
    canvas.drawPath(leftHand, glowPaint(BodyPart.shoulders));
    canvas.drawPath(leftHand, outlinePaint(BodyPart.shoulders));

    final rightHand = Path()
      ..addOval(Rect.fromCenter(
        center: Offset(cx + 49, size.height * 0.505),
        width: 16,
        height: 20,
      ));
    drawGlowShadow(canvas, rightHand, BodyPart.shoulders);
    canvas.drawPath(rightHand, glowPaint(BodyPart.shoulders));
    canvas.drawPath(rightHand, outlinePaint(BodyPart.shoulders));

    // ── TORSO ──
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

    final leftFoot = Path()
      ..moveTo(cx - 20, size.height * 0.845)
      ..quadraticBezierTo(
          cx - 22, size.height * 0.88, cx - 8, size.height * 0.88)
      ..lineTo(cx - 6, size.height * 0.855)
      ..close();
    drawGlowShadow(canvas, leftFoot, BodyPart.legs);
    canvas.drawPath(leftFoot, glowPaint(BodyPart.legs));
    canvas.drawPath(leftFoot, outlinePaint(BodyPart.legs));

    final rightFoot = Path()
      ..moveTo(cx + 20, size.height * 0.845)
      ..quadraticBezierTo(
          cx + 22, size.height * 0.88, cx + 8, size.height * 0.88)
      ..lineTo(cx + 6, size.height * 0.855)
      ..close();
    drawGlowShadow(canvas, rightFoot, BodyPart.legs);
    canvas.drawPath(rightFoot, glowPaint(BodyPart.legs));
    canvas.drawPath(rightFoot, outlinePaint(BodyPart.legs));

    // ── FACE DETAILS ──
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
        oldDelegate.glowIntensity != glowIntensity ||
        oldDelegate.isDark != isDark;
  }
}
