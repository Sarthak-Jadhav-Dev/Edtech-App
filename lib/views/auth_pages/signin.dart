import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kte/views/pages/login.dart';
import 'package:kte/services/auth_services.dart';

import '../../services/app_state.dart';
import '../widget_tree.dart';

class LoginForm extends StatefulWidget {
  const LoginForm({super.key});

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final AuthService _authService = AuthService();
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _phone = TextEditingController();
  final TextEditingController _password = TextEditingController();

  bool _isLoading = false;
  bool _isGoogleLoading = false;

  @override
  void dispose() {
    _phone.dispose();
    _password.dispose();
    super.dispose();
  }

  // ─── Google Sign-In Handler ────────────────────────────────────────────────

  Future<void> _handleGoogleSignIn() async {
    setState(() => _isGoogleLoading = true);
    try {
      final result = await _authService.signInWithGoogle();
      if (result == null) {
        // User cancelled
        return;
      }

      final user = result['user'];
      final isNewUser = result['isNewUser'] as bool;

      if (!mounted) return;

      if (isNewUser) {
        // New Google user — ask them to choose a role
        final selectedRole = await _showRoleDialog(context);
        if (selectedRole == null) {
          // They dismissed without picking — sign them out to avoid a broken state
          await _authService.logout();
          return;
        }
        await _authService.setUserRole(user.uid, selectedRole);
      }

      await AppState.setNotFirstTime();

      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const WidgetTree()),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceAll('Exception: ', '')),
          backgroundColor: Colors.red.shade700,
        ),
      );
    } finally {
      if (mounted) setState(() => _isGoogleLoading = false);
    }
  }

  // ─── Phone Login Handler ───────────────────────────────────────────────────

  Future<void> _handlePhoneLogin() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    try {
      final user = await _authService.loginWithPhone(
        _phone.text.trim(),
        _password.text.trim(),
      );

      if (user != null) {
        await AppState.setNotFirstTime();
        if (!mounted) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const WidgetTree()),
        );
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please check your credentials')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // ─── Role Selection Dialog ─────────────────────────────────────────────────

  Future<String?> _showRoleDialog(BuildContext context) {
    return showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          title: const Text(
            'Choose your role',
            style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.bold),
          ),
          content: const Text(
            'Please select the role that best describes you so we can personalise your experience.',
            style: TextStyle(fontFamily: 'Sans'),
          ),
          actionsAlignment: MainAxisAlignment.center,
          actions: [
            _RoleChip(
              label: 'Student',
              icon: Icons.school,
              color: Colors.blue.shade700,
              onTap: () => Navigator.pop(ctx, 'Student'),
            ),
            _RoleChip(
              label: 'Teacher',
              icon: Icons.cast_for_education,
              color: Colors.green.shade700,
              onTap: () => Navigator.pop(ctx, 'Teacher'),
            ),
            _RoleChip(
              label: 'Parent',
              icon: Icons.family_restroom,
              color: Colors.orange.shade700,
              onTap: () => Navigator.pop(ctx, 'Parent'),
            ),
          ],
        );
      },
    );
  }

  // ─── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: Colors.purple.shade50,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: const Text(
          'Get Started..',
          style: TextStyle(fontFamily: 'Poppins'),
        ),
        centerTitle: true,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const Login()),
            );
          },
        ),
      ),
      extendBodyBehindAppBar: true,
      body: SafeArea(
        child: SingleChildScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          child: Column(
            children: [
              const SizedBox(height: 20),
              Hero(
                tag: 'Hello',
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Image.asset('assets/images/HappyFaces.png'),
                  ),
                ),
              ),
              Container(
                width: double.infinity,
                margin: const EdgeInsets.symmetric(horizontal: 16),
                padding: const EdgeInsets.symmetric(
                    horizontal: 20, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.purple.shade50,
                  borderRadius: BorderRadius.circular(40),
                ),
                child: Column(
                  children: [
                    const Text(
                      'Login',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),

                    // ── Google Sign-In Button ──────────────────────────────
                    OutlinedButton.icon(
                      onPressed:
                          _isGoogleLoading ? null : _handleGoogleSignIn,
                      icon: _isGoogleLoading
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : Image.asset(
                              'assets/images/google_logo.png',
                              height: 20,
                              errorBuilder: (_, __, ___) =>
                                  const Icon(Icons.g_mobiledata, size: 22),
                            ),
                      label: const Text(
                        'Log in with Google',
                        style: TextStyle(fontFamily: 'Sans'),
                      ),
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size(300, 50),
                        side: const BorderSide(color: Colors.black, width: 1),
                        shape: const StadiumBorder(),
                        backgroundColor: Colors.purple.shade50,
                      ),
                    ),

                    const SizedBox(height: 10),
                    const Text('or', style: TextStyle(fontFamily: 'Sans')),
                    const SizedBox(height: 10),

                    // ── Phone / Password Form ──────────────────────────────
                    Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          SizedBox(
                            width: 300,
                            child: TextFormField(
                              controller: _phone,
                              keyboardType: TextInputType.phone,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                                LengthLimitingTextInputFormatter(10),
                              ],
                              decoration: InputDecoration(
                                filled: true,
                                fillColor: Colors.white60,
                                hintText: 'Phone Number (10 digits)',
                                prefixText: '+91 ',
                                prefixStyle: const TextStyle(
                                  fontFamily: 'Sans',
                                  color: Colors.black87,
                                  fontSize: 16,
                                ),
                                hintStyle: const TextStyle(
                                  fontFamily: 'Sans',
                                  color: Colors.black54,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(40),
                                  borderSide: BorderSide.none,
                                ),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter your phone number';
                                }
                                if (value.length != 10) {
                                  return 'Must be 10 digits';
                                }
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(height: 10),
                          SizedBox(
                            width: 300,
                            child: TextFormField(
                              controller: _password,
                              obscureText: true,
                              decoration: InputDecoration(
                                filled: true,
                                fillColor: Colors.white60,
                                hintText: 'Password',
                                hintStyle: const TextStyle(
                                  fontFamily: 'Sans',
                                  color: Colors.black54,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(40),
                                  borderSide: BorderSide.none,
                                ),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter your password';
                                }
                                return null;
                              },
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 15),

                    // ── Phone Login Submit ─────────────────────────────────
                    _isLoading
                        ? const CircularProgressIndicator()
                        : OutlinedButton(
                            onPressed: _handlePhoneLogin,
                            style: OutlinedButton.styleFrom(
                              minimumSize: const Size(300, 50),
                              side: const BorderSide(
                                  color: Colors.black54, width: 1),
                              shape: const StadiumBorder(),
                              backgroundColor: Colors.purple.shade900,
                            ),
                            child: const Text(
                              'Log in',
                              style: TextStyle(
                                fontFamily: 'Sans',
                                color: Colors.white70,
                              ),
                            ),
                          ),

                    const SizedBox(height: 10),
                    const SizedBox(
                      width: 300,
                      child: Text(
                        'Logging in for our Services means you agree to our Terms of Service and Privacy Policy',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: 'Sans',
                          color: Colors.black54,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Role Chip Widget ──────────────────────────────────────────────────────────

class _RoleChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _RoleChip({
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          onPressed: onTap,
          icon: Icon(icon, color: Colors.white),
          label: Text(
            label,
            style: const TextStyle(
              fontFamily: 'Sans',
              color: Colors.white,
              fontSize: 16,
            ),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: color,
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          ),
        ),
      ),
    );
  }
}