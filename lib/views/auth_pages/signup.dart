import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kte/services/auth_services.dart';
import 'package:kte/views/pages/login.dart';
import 'package:kte/views/widget_tree.dart';
import 'package:kte/services/firestore_service.dart' as kte_firestore;
import 'package:kte/services/app_state.dart';

class RegisterForm extends StatefulWidget {
  const RegisterForm({super.key});

  @override
  State<RegisterForm> createState() => _RegisterFormState();
}

class _RegisterFormState extends State<RegisterForm> {
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _parentEmailController = TextEditingController();

  final List<String> userTypes = ['Student', 'Parent', 'Teacher'];
  String selectedUserType = 'Student';
  bool _isLoading = false;
  bool _isGoogleLoading = false;

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _parentEmailController.dispose();
    super.dispose();
  }

  // ─── Google Sign-Up Handler ────────────────────────────────────────────────

  Future<void> _handleGoogleSignUp() async {
    setState(() => _isGoogleLoading = true);
    try {
      final result = await AuthService().signInWithGoogle();
      if (result == null) return; 

      final user = result['user'];
      final isNewUser = result['isNewUser'] as bool;

      if (!mounted) return;

      if (isNewUser) {
        final selectedRole = await _showRoleDialog(context);
        if (selectedRole == null) {
          await AuthService().logout();
          return;
        }
        await AuthService().setUserRole(user.uid, selectedRole);
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

  // ─── Email Sign-Up Handler ──────────────────────────────────────────────

  Future<void> _handleEmailSignUp() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final firstName = _firstNameController.text.trim();
    final lastName = _lastNameController.text.trim();
    final parentEmail = _parentEmailController.text.trim();

    if (email.isEmpty || password.isEmpty || firstName.isEmpty || lastName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all required fields')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final user = await AuthService().signUpWithEmail(
        email: email,
        password: password,
        firstName: firstName,
        lastName: lastName,
        userType: selectedUserType,
      );

      if (user != null) {
        // Handle Parent Linking for Students
        if (selectedUserType == 'Student' && parentEmail.isNotEmpty) {
          try {
            final parentDoc = await kte_firestore.FirestoreService().searchUserByEmail(parentEmail);
            if (parentDoc != null && (parentDoc.data() as Map<String, dynamic>)['userType'] == 'Parent') {
              await kte_firestore.FirestoreService().linkParentToStudent(user.uid, parentDoc.id);
            }
          } catch (e) {
            debugPrint("Parent linking search failed: $e");
          }
        }

        await AppState.setNotFirstTime();
        if (!mounted) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const WidgetTree()),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceAll('Exception: ', '')),
          backgroundColor: Colors.red.shade700,
        ),
      );
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
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          title: const Text('Choose your role', style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.bold)),
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
        title: const Text('Create Account', style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.bold)),
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
          child: Column(
            children: [
              const SizedBox(height: 10),
              Hero(
                tag: 'Hello',
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(24),
                    child: Image.asset('assets/images/HappyFaces.png', height: 160, fit: BoxFit.cover),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.6),
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  child: Column(
                    children: [
                      const Text(
                        'Join Our Community',
                        style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, fontFamily: 'Poppins'),
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        'Start your journey with hands-on learning',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontFamily: 'Sans', color: Colors.black54),
                      ),
                      const SizedBox(height: 25),

                      // ── Google Sign-Up Button ──────────────────────────
                      OutlinedButton.icon(
                        onPressed: _isGoogleLoading ? null : _handleGoogleSignUp,
                        icon: _isGoogleLoading
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : Image.asset(
                                'assets/images/google_logo.png',
                                height: 20,
                                errorBuilder: (_, __, ___) => const Icon(Icons.g_mobiledata, size: 22),
                              ),
                        label: const Text('Continue with Google', style: TextStyle(fontFamily: 'Sans', fontWeight: FontWeight.w600)),
                        style: OutlinedButton.styleFrom(
                          minimumSize: const Size(double.infinity, 55),
                          side: const BorderSide(color: Colors.black12, width: 1.5),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          backgroundColor: Colors.white,
                        ),
                      ),

                      const SizedBox(height: 20),
                      Row(
                        children: [
                          Expanded(child: Divider(color: Colors.grey.shade300)),
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 12),
                            child: Text('or create with email', style: TextStyle(fontFamily: 'Sans', color: Colors.black38, fontSize: 12)),
                          ),
                          Expanded(child: Divider(color: Colors.grey.shade300)),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // ── Name Fields ────────────────────────────────────
                      Row(
                        children: [
                          Expanded(
                            child: _buildTextField(
                              controller: _firstNameController,
                              hintText: 'First Name',
                              icon: Icons.person_outline,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _buildTextField(
                              controller: _lastNameController,
                              hintText: 'Last Name',
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // ── Email ──────────────────────────────────────────
                      _buildTextField(
                        controller: _emailController,
                        hintText: 'Email Address',
                        icon: Icons.email_outlined,
                        keyboardType: TextInputType.emailAddress,
                      ),
                      const SizedBox(height: 12),

                      // ── Password ───────────────────────────────────────
                      _buildTextField(
                        controller: _passwordController,
                        hintText: 'Password',
                        icon: Icons.lock_outline_rounded,
                        obscureText: true,
                      ),
                      const SizedBox(height: 12),

                      // ── Role Dropdown ──────────────────────────────────
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.8),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButtonFormField<String>(
                            initialValue: selectedUserType,
                            items: userTypes.map((type) {
                              return DropdownMenuItem(value: type, child: Text(type, style: const TextStyle(fontFamily: 'Sans')));
                            }).toList(),
                            onChanged: (val) => setState(() => selectedUserType = val!),
                            decoration: const InputDecoration(border: InputBorder.none),
                          ),
                        ),
                      ),

                      // ── Parent Email (students only) ───────────────────
                      if (selectedUserType == 'Student') ...[
                        const SizedBox(height: 12),
                        _buildTextField(
                          controller: _parentEmailController,
                          hintText: "Parent's Email (Optional)",
                          icon: Icons.family_restroom_outlined,
                          keyboardType: TextInputType.emailAddress,
                        ),
                      ],

                      const SizedBox(height: 30),

                      // ── Register Button ────────────────────────────────
                      _isLoading
                          ? const CircularProgressIndicator()
                          : SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: _handleEmailSignUp,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.purple.shade900,
                                  padding: const EdgeInsets.symmetric(vertical: 18),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                  elevation: 4,
                                ),
                                child: const Text(
                                  'Create Account',
                                  style: TextStyle(color: Colors.white, fontFamily: 'Sans', fontSize: 18, fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),

                      const SizedBox(height: 20),
                      const Text(
                        'By joining, you agree to our Terms and Privacy Policy',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontFamily: 'Sans', color: Colors.black38, fontSize: 11),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    IconData? icon,
    bool obscureText = false,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.white.withValues(alpha: 0.8),
        hintText: hintText,
        prefixIcon: icon != null ? Icon(icon, size: 22) : null,
        hintStyle: const TextStyle(fontFamily: 'Sans', color: Colors.black38),
        contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: Colors.purple.shade300, width: 2)),
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
            padding:
                const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14)),
          ),
        ),
      ),
    );
  }
}


