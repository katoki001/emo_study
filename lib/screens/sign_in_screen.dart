import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../services/auth_service.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _obscurePassword = true;
  bool _isLoading = false;
  String? _errorMessage;

  late final AnimationController _fadeController;
  late final Animation<double> _fadeAnim;

  static const Color _bg = Color(0xFF1C2E4A);
  static const Color _surface = Color(0xFF243656);
  static const Color _primary = Color(0xFF4A90D9);
  static const Color _textLight = Color(0xFFE8F0FE);
  static const Color _textSoft = Color(0xFF90AAC8);
  static const Color _error = Color(0xFFFF6B6B);

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnim = CurvedAnimation(parent: _fadeController, curve: Curves.easeOut);
    _fadeController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _signIn() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await AuthService.signIn(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );
      if (mounted) Navigator.of(context).pushReplacementNamed('/');
    } on AuthException catch (e) {
      setState(() => _errorMessage = _mapError(e.message));
    } catch (_) {
      setState(() => _errorMessage = 'Something went wrong. Please try again.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _forgotPassword() async {
    final email = _emailController.text.trim();
    if (email.isEmpty) {
      setState(
          () => _errorMessage = 'Enter your email first to reset password.');
      return;
    }
    try {
      await AuthService.resetPassword(email);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Password reset email sent! Check your inbox.')),
        );
      }
    } on AuthException catch (e) {
      setState(() => _errorMessage = _mapError(e.message));
    }
  }

  String _mapError(String message) {
    if (message.contains('Invalid login'))
      return 'Incorrect email or password.';
    if (message.contains('Email not confirmed'))
      return 'Please confirm your email first.';
    if (message.contains('too many requests'))
      return 'Too many attempts. Try again later.';
    return message;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF243656), Color(0xFF1C2E4A), Color(0xFF162238)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: FadeTransition(
            opacity: _fadeAnim,
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 32),

                    // Logo
                    Container(
                      width: 72,
                      height: 72,
                      decoration: BoxDecoration(
                        color: _surface,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                            color: _primary.withOpacity(0.3), width: 1.5),
                        boxShadow: [
                          BoxShadow(
                              color: _primary.withOpacity(0.18),
                              blurRadius: 24,
                              offset: const Offset(0, 6))
                        ],
                      ),
                      child: const Center(
                          child: Text('🌍', style: TextStyle(fontSize: 36))),
                    ),

                    const SizedBox(height: 20),

                    RichText(
                      text: const TextSpan(children: [
                        TextSpan(
                            text: 'World',
                            style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.w800,
                                color: _textLight,
                                letterSpacing: -0.5)),
                        TextSpan(
                            text: 'Classroom',
                            style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.w300,
                                color: _primary,
                                letterSpacing: -0.5)),
                      ]),
                    ),

                    const SizedBox(height: 8),
                    const Text('Welcome back',
                        style: TextStyle(fontSize: 14, color: _textSoft)),

                    const SizedBox(height: 40),

                    _buildTextField(
                      controller: _emailController,
                      label: 'Email',
                      hint: 'you@example.com',
                      icon: Icons.email_outlined,
                      keyboardType: TextInputType.emailAddress,
                      validator: (v) {
                        if (v == null || v.trim().isEmpty)
                          return 'Email is required';
                        if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(v))
                          return 'Enter a valid email';
                        return null;
                      },
                    ),

                    const SizedBox(height: 16),

                    _buildTextField(
                      controller: _passwordController,
                      label: 'Password',
                      hint: '••••••••',
                      icon: Icons.lock_outline,
                      obscureText: _obscurePassword,
                      suffixIcon: IconButton(
                        icon: Icon(
                            _obscurePassword
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                            color: _textSoft,
                            size: 20),
                        onPressed: () => setState(
                            () => _obscurePassword = !_obscurePassword),
                      ),
                      validator: (v) => (v == null || v.isEmpty)
                          ? 'Password is required'
                          : null,
                    ),

                    const SizedBox(height: 8),

                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: _forgotPassword,
                        style: TextButton.styleFrom(
                          foregroundColor: _primary,
                          padding: EdgeInsets.zero,
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: const Text('Forgot password?',
                            style: TextStyle(fontSize: 13)),
                      ),
                    ),

                    if (_errorMessage != null) ...[
                      const SizedBox(height: 12),
                      _buildErrorBox(_errorMessage!),
                    ],

                    const SizedBox(height: 28),

                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _signIn,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _primary,
                          foregroundColor: Colors.white,
                          disabledBackgroundColor: _primary.withOpacity(0.5),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14)),
                          elevation: 0,
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                    color: Colors.white, strokeWidth: 2.5))
                            : const Text('Sign In',
                                style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 0.3)),
                      ),
                    ),

                    const SizedBox(height: 24),

                    Row(children: [
                      Expanded(
                          child: Divider(color: _textSoft.withOpacity(0.3))),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: Text('or',
                            style: TextStyle(
                                color: _textSoft.withOpacity(0.7),
                                fontSize: 13)),
                      ),
                      Expanded(
                          child: Divider(color: _textSoft.withOpacity(0.3))),
                    ]),

                    const SizedBox(height: 20),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text("Don't have an account? ",
                            style: TextStyle(color: _textSoft, fontSize: 14)),
                        GestureDetector(
                          onTap: () =>
                              Navigator.of(context).pushNamed('/sign-up'),
                          child: const Text('Sign Up',
                              style: TextStyle(
                                  color: _primary,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700)),
                        ),
                      ],
                    ),

                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildErrorBox(String message) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: _error.withOpacity(0.12),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: _error.withOpacity(0.4)),
      ),
      child: Row(children: [
        const Icon(Icons.error_outline, color: _error, size: 16),
        const SizedBox(width: 8),
        Expanded(
            child: Text(message,
                style: const TextStyle(color: _error, fontSize: 13))),
      ]),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    bool obscureText = false,
    Widget? suffixIcon,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(
                color: _textSoft, fontSize: 13, fontWeight: FontWeight.w500)),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          obscureText: obscureText,
          style: const TextStyle(color: _textLight, fontSize: 15),
          validator: validator,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle:
                TextStyle(color: _textSoft.withOpacity(0.5), fontSize: 14),
            prefixIcon: Icon(icon, color: _textSoft, size: 20),
            suffixIcon: suffixIcon,
            filled: true,
            fillColor: _surface,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: _textSoft.withOpacity(0.2))),
            enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: _textSoft.withOpacity(0.2))),
            focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: _primary, width: 1.5)),
            errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: _error)),
            focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: _error, width: 1.5)),
            errorStyle: const TextStyle(color: _error, fontSize: 12),
          ),
        ),
      ],
    );
  }
}
