import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late final AnimationController _logoController;
  late final AnimationController _textController;
  late final AnimationController _taglineController;

  late final Animation<double> _logoScale;
  late final Animation<double> _logoOpacity;
  late final Animation<double> _textOpacity;
  late final Animation<Offset> _textSlide;
  late final Animation<double> _taglineOpacity;
  late final Animation<Offset> _taglineSlide;

  static const Color _bg = Color(0xFF1C2E4A);
  static const Color _surface = Color(0xFF243656);
  static const Color _primary = Color(0xFF4A90D9);
  static const Color _textLight = Color(0xFFE8F0FE);
  static const Color _textSoft = Color(0xFF90AAC8);

  @override
  void initState() {
    super.initState();

    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: _bg,
        systemNavigationBarColor: _bg,
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarIconBrightness: Brightness.light,
      ),
    );

    _logoController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _logoScale = Tween<double>(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.easeOutBack),
    );
    _logoOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.easeIn),
    );

    _textController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _textOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _textController, curve: Curves.easeOut),
    );
    _textSlide =
        Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
      CurvedAnimation(parent: _textController, curve: Curves.easeOut),
    );

    _taglineController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _taglineOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _taglineController, curve: Curves.easeOut),
    );
    _taglineSlide =
        Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
      CurvedAnimation(parent: _taglineController, curve: Curves.easeOut),
    );

    _logoController.forward();
    Future.delayed(const Duration(milliseconds: 400), () {
      if (mounted) _textController.forward();
    });
    Future.delayed(const Duration(milliseconds: 700), () {
      if (mounted) _taglineController.forward();
    });

    // Check auth after animations settle
    Future.delayed(const Duration(milliseconds: 2200), _checkAuthAndNavigate);
  }

  void _checkAuthAndNavigate() {
    if (!mounted) return;
    // ← Only change: Firebase instead of Supabase
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      Navigator.of(context).pushReplacementNamed('/');
    } else {
      Navigator.of(context).pushReplacementNamed('/sign-in');
    }
  }

  @override
  void dispose() {
    _logoController.dispose();
    _textController.dispose();
    _taglineController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: AnimatedBuilder(
        animation: Listenable.merge([
          _logoController,
          _textController,
          _taglineController,
        ]),
        builder: (context, _) {
          return Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFF243656),
                  Color(0xFF1C2E4A),
                  Color(0xFF162238)
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: SafeArea(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Spacer(flex: 3),
                  FadeTransition(
                    opacity: _logoOpacity,
                    child:
                        ScaleTransition(scale: _logoScale, child: _buildLogo()),
                  ),
                  const SizedBox(height: 28),
                  FadeTransition(
                    opacity: _textOpacity,
                    child: SlideTransition(
                        position: _textSlide, child: _buildWordmark()),
                  ),
                  const SizedBox(height: 10),
                  FadeTransition(
                    opacity: _taglineOpacity,
                    child: SlideTransition(
                        position: _taglineSlide, child: _buildTagline()),
                  ),
                  const Spacer(flex: 3),
                  FadeTransition(opacity: _taglineOpacity, child: _buildDots()),
                  const SizedBox(height: 48),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildLogo() {
    return Container(
      width: 96,
      height: 96,
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: _primary.withOpacity(0.3), width: 1.5),
        boxShadow: [
          BoxShadow(
              color: _primary.withOpacity(0.18),
              blurRadius: 28,
              offset: const Offset(0, 8)),
        ],
      ),
      child: const Center(child: Text('🌍', style: TextStyle(fontSize: 48))),
    );
  }

  Widget _buildWordmark() {
    return RichText(
      text: const TextSpan(
        children: [
          TextSpan(
              text: 'World',
              style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.w800,
                  color: _textLight,
                  letterSpacing: -0.5)),
          TextSpan(
              text: 'Classroom',
              style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.w300,
                  color: _primary,
                  letterSpacing: -0.5)),
        ],
      ),
    );
  }

  Widget _buildTagline() {
    return const Text(
      'Learn at your own pace',
      style: TextStyle(
          fontSize: 15,
          color: _textSoft,
          fontWeight: FontWeight.w400,
          letterSpacing: 0.3),
    );
  }

  Widget _buildDots() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
          3,
          (i) => _AnimatedDot(
              delay: Duration(milliseconds: i * 200), color: _primary)),
    );
  }
}

class _AnimatedDot extends StatefulWidget {
  final Duration delay;
  final Color color;
  const _AnimatedDot({required this.delay, required this.color});

  @override
  State<_AnimatedDot> createState() => _AnimatedDotState();
}

class _AnimatedDotState extends State<_AnimatedDot>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 600));
    _anim = Tween<double>(begin: 0, end: -8).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    Future.delayed(widget.delay, () {
      if (mounted) _controller.repeat(reverse: true);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _anim,
      builder: (_, __) => Transform.translate(
        offset: Offset(0, _anim.value),
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: 7,
          height: 7,
          decoration:
              BoxDecoration(color: widget.color, shape: BoxShape.circle),
        ),
      ),
    );
  }
}
