import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../services/auth_service.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  bool _isLoading = false;
  String? _errorMessage;
  bool _signUpSuccess = false;

  late final AnimationController _fadeController;
  late final Animation<double> _fadeAnim;

  static const Color _bg = Color(0xFF1C2E4A);
  static const Color _surface = Color(0xFF243656);
  static const Color _primary = Color(0xFF4A90D9);
  static const Color _textLight = Color(0xFFE8F0FE);
  static const Color _textSoft = Color(0xFF90AAC8);
  static const Color _error = Color(0xFFFF6B6B);
  static const Color _success = Color(0xFF4CAF82);

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
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _signUp() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final response = await AuthService.signUp(
        email: _emailController.text.trim(),
        password: _passwordController.text,
        fullName: _nameController.text.trim(),
      );

      if (mounted) {
        // Supabase sends a confirmation email by default.
        // If email confirmation is disabled in your Supabase project,
        // the session will be set and we can go straight to home.
        if (response.session != null) {
          Navigator.of(context).pushReplacementNamed('/');
        } else {
          // Show "check your email" message
          setState(() => _signUpSuccess = true);
        }
      }
    } on AuthException catch (e) {
      setState(() => _errorMessage = _mapError(e.message));
    } catch (_) {
      setState(() => _errorMessage = 'Something went wrong. Please try again.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  String _mapError(String message) {
    if (message.contains('already registered'))
      return 'An account with this email already exists.';
    if (message.contains('Password should'))
      return 'Password must be at least 6 characters.';
    if (message.contains('invalid')) return 'Invalid email address.';
    return message;
  }

  int _passwordStrength(String password) {
    int score = 0;
    if (password.length >= 8) score++;
    if (RegExp(r'[A-Z]').hasMatch(password)) score++;
    if (RegExp(r'[0-9]').hasMatch(password)) score++;
    if (RegExp(r'[!@#\$&*~]').hasMatch(password)) score++;
    return score;
  }

  @override
  Widget build(BuildContext context) {
    // Show success/confirm email screen
    if (_signUpSuccess) {
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
            child: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: _success.withOpacity(0.15),
                        shape: BoxShape.circle,
                        border: Border.all(
                            color: _success.withOpacity(0.4), width: 1.5),
                      ),
                      child: const Icon(Icons.mark_email_read_outlined,
                          color: _success, size: 36),
                    ),
                    const SizedBox(height: 24),
                    const Text('Check your email!',
                        style: TextStyle(
                            color: _textLight,
                            fontSize: 24,
                            fontWeight: FontWeight.w700)),
                    const SizedBox(height: 12),
                    Text(
                      'We sent a confirmation link to\n${_emailController.text.trim()}\n\nClick it to activate your account.',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                          color: _textSoft, fontSize: 14, height: 1.6),
                    ),
                    const SizedBox(height: 36),
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        onPressed: () => Navigator.of(context)
                            .pushReplacementNamed('/sign-in'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _primary,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14)),
                          elevation: 0,
                        ),
                        child: const Text('Go to Sign In',
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.w700)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    }

    final password = _passwordController.text;
    final strength = _passwordStrength(password);

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
                    const SizedBox(height: 16),

                    // Header row
                    Row(
                      children: [
                        GestureDetector(
                          onTap: () => Navigator.of(context).pop(),
                          child: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: _surface,
                              borderRadius: BorderRadius.circular(12),
                              border:
                                  Border.all(color: _textSoft.withOpacity(0.2)),
                            ),
                            child: const Icon(Icons.arrow_back_ios_new,
                                color: _textLight, size: 16),
                          ),
                        ),
                        const Expanded(
                          child: Text('Create Account',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  color: _textLight,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700)),
                        ),
                        const SizedBox(width: 40),
                      ],
                    ),

                    const SizedBox(height: 32),

                    Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        color: _surface,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                            color: _primary.withOpacity(0.3), width: 1.5),
                        boxShadow: [
                          BoxShadow(
                              color: _primary.withOpacity(0.15),
                              blurRadius: 20,
                              offset: const Offset(0, 6))
                        ],
                      ),
                      child: const Center(
                          child: Text('🌍', style: TextStyle(fontSize: 32))),
                    ),

                    const SizedBox(height: 12),
                    const Text('Join WorldClassroom',
                        style: TextStyle(color: _textSoft, fontSize: 14)),
                    const SizedBox(height: 32),

                    _buildTextField(
                      controller: _nameController,
                      label: 'Full Name',
                      hint: 'Jane Doe',
                      icon: Icons.person_outline,
                      validator: (v) => (v == null || v.trim().isEmpty)
                          ? 'Name is required'
                          : null,
                    ),

                    const SizedBox(height: 16),

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
                      hint: 'Min. 6 characters',
                      icon: Icons.lock_outline,
                      obscureText: _obscurePassword,
                      onChanged: (_) => setState(() {}),
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
                      validator: (v) {
                        if (v == null || v.isEmpty)
                          return 'Password is required';
                        if (v.length < 6)
                          return 'Password must be at least 6 characters';
                        return null;
                      },
                    ),

                    if (password.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      _buildStrengthBar(strength),
                    ],

                    const SizedBox(height: 16),

                    _buildTextField(
                      controller: _confirmPasswordController,
                      label: 'Confirm Password',
                      hint: '••••••••',
                      icon: Icons.lock_outline,
                      obscureText: _obscureConfirm,
                      suffixIcon: IconButton(
                        icon: Icon(
                            _obscureConfirm
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                            color: _textSoft,
                            size: 20),
                        onPressed: () =>
                            setState(() => _obscureConfirm = !_obscureConfirm),
                      ),
                      validator: (v) {
                        if (v == null || v.isEmpty)
                          return 'Please confirm your password';
                        if (v != _passwordController.text)
                          return 'Passwords do not match';
                        return null;
                      },
                    ),

                    if (_errorMessage != null) ...[
                      const SizedBox(height: 14),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 10),
                        decoration: BoxDecoration(
                          color: _error.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: _error.withOpacity(0.4)),
                        ),
                        child: Row(children: [
                          const Icon(Icons.error_outline,
                              color: _error, size: 16),
                          const SizedBox(width: 8),
                          Expanded(
                              child: Text(_errorMessage!,
                                  style: const TextStyle(
                                      color: _error, fontSize: 13))),
                        ]),
                      ),
                    ],

                    const SizedBox(height: 28),

                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _signUp,
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
                            : const Text('Create Account',
                                style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 0.3)),
                      ),
                    ),

                    const SizedBox(height: 24),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('Already have an account? ',
                            style: TextStyle(color: _textSoft, fontSize: 14)),
                        GestureDetector(
                          onTap: () => Navigator.of(context).pop(),
                          child: const Text('Sign In',
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

  Widget _buildStrengthBar(int strength) {
    final labels = ['Weak', 'Fair', 'Good', 'Strong'];
    final colors = [
      const Color(0xFFFF6B6B),
      const Color(0xFFFFB347),
      const Color(0xFF4A90D9),
      const Color(0xFF4CAF82),
    ];
    final index = (strength - 1).clamp(0, 3);
    final label = strength == 0 ? '' : labels[index];
    final color = strength == 0 ? _textSoft : colors[index];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: List.generate(
              4,
              (i) => Expanded(
                    child: Container(
                      margin: const EdgeInsets.only(right: 4),
                      height: 4,
                      decoration: BoxDecoration(
                        color:
                            i < strength ? color : _textSoft.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  )),
        ),
        if (label.isNotEmpty) ...[
          const SizedBox(height: 4),
          Text(label, style: TextStyle(color: color, fontSize: 12)),
        ],
      ],
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
    void Function(String)? onChanged,
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
          onChanged: onChanged,
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
