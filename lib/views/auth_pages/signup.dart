import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kte/services/auth_services.dart';
import 'package:kte/views/pages/login.dart';
import 'package:kte/views/widget_tree.dart';
import 'package:kte/services/firestore_service.dart' as kte_firestore;
import 'package:kte/services/app_state.dart';
import 'package:pinput/pinput.dart';

class RegisterForm extends StatefulWidget {
  const RegisterForm({super.key});

  @override
  State<RegisterForm> createState() => _RegisterFormState();
}

class _RegisterFormState extends State<RegisterForm> {
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
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
    _phoneController.dispose();
    _passwordController.dispose();
    _parentEmailController.dispose();
    super.dispose();
  }

  // ─── Google Sign-Up Handler ────────────────────────────────────────────────

  Future<void> _handleGoogleSignUp() async {
    setState(() => _isGoogleLoading = true);
    try {
      final result = await AuthService().signInWithGoogle();
      if (result == null) return; // cancelled

      final user = result['user'];
      final isNewUser = result['isNewUser'] as bool;

      if (!mounted) return;

      if (isNewUser) {
        // New user — ask for a role
        final selectedRole = await _showRoleDialog(context);
        if (selectedRole == null) {
          await AuthService().logout();
          return;
        }
        await AuthService().setUserRole(user.uid, selectedRole);
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Account created with Google ✅')),
        );
      } else {
        // Existing user signed in via Google — just continue
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Welcome back! Signing you in…')),
        );
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
            style: TextStyle(
                fontFamily: 'Poppins', fontWeight: FontWeight.bold),
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

  // ─── Phone Registration Verification Flow ──────────────────────────────────

  Future<void> _handlePhoneRegistrationStart() async {
    final phone = _phoneController.text.trim();
    final password = _passwordController.text.trim();
    final firstName = _firstNameController.text.trim();
    final lastName = _lastNameController.text.trim();

    if (phone.isEmpty ||
        password.isEmpty ||
        firstName.isEmpty ||
        lastName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all required fields')),
      );
      return;
    }
    if (phone.length != 10) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid 10-digit phone number')),
      );
      return;
    }

    setState(() => _isLoading = true);

    await AuthService().sendOTP(
      phone: phone,
      onCodeSent: (verificationId) {
        if (mounted) setState(() => _isLoading = false);
        _showOTPBottomSheet(verificationId);
      },
      onError: (error) {
        if (mounted) {
          setState(() => _isLoading = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(error),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
    );
  }

  void _showOTPBottomSheet(String verificationId) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _OTPBottomSheetContent(
        verificationId: verificationId,
        phone: _phoneController.text.trim(),
        password: _passwordController.text.trim(),
        firstName: _firstNameController.text.trim(),
        lastName: _lastNameController.text.trim(),
        userType: selectedUserType,
        parentEmail: _parentEmailController.text.trim(),
      ),
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
          child: Column(
            children: [
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
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.purple.shade50,
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Column(
                    children: [
                      const Text(
                        'Create Account',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Sans',
                        ),
                      ),
                      const SizedBox(height: 20),

                      // ── Google Sign-Up Button ──────────────────────────
                      OutlinedButton.icon(
                        onPressed: _isGoogleLoading ? null : _handleGoogleSignUp,
                        icon: _isGoogleLoading
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                    strokeWidth: 2),
                              )
                            : Image.asset(
                                'assets/images/google_logo.png',
                                height: 20,
                                errorBuilder: (_, __, ___) =>
                                    const Icon(Icons.g_mobiledata, size: 22),
                              ),
                        label: const Text(
                          'Continue with Google',
                          style: TextStyle(fontFamily: 'Sans'),
                        ),
                        style: OutlinedButton.styleFrom(
                          minimumSize: const Size(double.infinity, 50),
                          side: const BorderSide(color: Colors.black, width: 1),
                          shape: const StadiumBorder(),
                          backgroundColor: Colors.white,
                        ),
                      ),

                      const SizedBox(height: 16),

                      // ── Divider ────────────────────────────────────────
                      Row(
                        children: [
                          Expanded(
                              child: Divider(color: Colors.grey.shade400)),
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 12),
                            child: Text(
                              'or create with email',
                              style: TextStyle(
                                  fontFamily: 'Sans',
                                  color: Colors.grey.shade600,
                                  fontSize: 12),
                            ),
                          ),
                          Expanded(
                              child: Divider(color: Colors.grey.shade400)),
                        ],
                      ),

                      const SizedBox(height: 16),

                      // ── Name Fields ────────────────────────────────────
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _firstNameController,
                              decoration: InputDecoration(
                                hintText: 'First Name',
                                filled: true,
                                fillColor: Colors.white,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(30),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: TextField(
                              controller: _lastNameController,
                              decoration: InputDecoration(
                                hintText: 'Last Name',
                                filled: true,
                                fillColor: Colors.white,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(30),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),

                      // ── Phone Number ───────────────────────────────────
                      TextField(
                        controller: _phoneController,
                        keyboardType: TextInputType.phone,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(10),
                        ],
                        decoration: InputDecoration(
                          hintText: 'Phone Number (10 digits)',
                          prefixText: '+91 ',
                          prefixStyle: const TextStyle(
                            fontFamily: 'Sans',
                            color: Colors.black87,
                            fontSize: 16,
                          ),
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),

                      // ── Password ───────────────────────────────────────
                      TextField(
                        controller: _passwordController,
                        obscureText: true,
                        decoration: InputDecoration(
                          hintText: 'Password',
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),

                      // ── Role Dropdown ──────────────────────────────────
                      DropdownButtonFormField<String>(
                        initialValue: selectedUserType,
                        items: userTypes.map((type) {
                          return DropdownMenuItem(
                              value: type, child: Text(type));
                        }).toList(),
                        onChanged: (val) {
                          setState(() {
                            selectedUserType = val!;
                          });
                        },
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                      ),

                      // ── Parent Email (students only) ───────────────────
                      if (selectedUserType == 'Student') ...[
                        const SizedBox(height: 10),
                        TextField(
                          controller: _parentEmailController,
                          decoration: InputDecoration(
                            hintText: "Parent's Email (Optional)",
                            filled: true,
                            fillColor: Colors.white,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                        ),
                      ],

                      const SizedBox(height: 20),

                      // ── Register Button ────────────────────────────────
                      _isLoading
                          ? const CircularProgressIndicator()
                          : OutlinedButton(
                              onPressed: _handlePhoneRegistrationStart,
                              style: OutlinedButton.styleFrom(
                                minimumSize:
                                    const Size(double.infinity, 50),
                                backgroundColor: Colors.purple.shade900,
                              ),
                              child: const Text(
                                'Register',
                                style: TextStyle(color: Colors.white),
                              ),
                            ),

                      const SizedBox(height: 10),
                      const SizedBox(
                        width: 300,
                        child: Text(
                          'Registering for our Services means you agree to our Terms of Service and Privacy Policy',
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

// ─── OTP Bottom Sheet Widget ───────────────────────────────────────────────────

class _OTPBottomSheetContent extends StatefulWidget {
  final String verificationId;
  final String phone;
  final String password;
  final String firstName;
  final String lastName;
  final String userType;
  final String parentEmail;

  const _OTPBottomSheetContent({
    super.key,
    required this.verificationId,
    required this.phone,
    required this.password,
    required this.firstName,
    required this.lastName,
    required this.userType,
    required this.parentEmail,
  });

  @override
  State<_OTPBottomSheetContent> createState() => _OTPBottomSheetContentState();
}

class _OTPBottomSheetContentState extends State<_OTPBottomSheetContent> {
  final TextEditingController _otpController = TextEditingController();
  bool _isVerifying = false;
  String? _errorMessage;

  Future<void> _verifyAndSubmit(String smsCode) async {
    setState(() {
      _isVerifying = true;
      _errorMessage = null;
    });

    try {
      final user = await AuthService().verifyOTPAndSignUp(
        verificationId: widget.verificationId,
        smsCode: smsCode,
        phone: widget.phone,
        password: widget.password,
        firstName: widget.firstName,
        lastName: widget.lastName,
        userType: widget.userType,
      );

      // Handle Parent Linking for Students
      if (user != null &&
          widget.userType == 'Student' &&
          widget.parentEmail.isNotEmpty) {
        final parentDoc = await kte_firestore.FirestoreService()
            .searchUserByEmail(widget.parentEmail);
        if (parentDoc != null &&
            (parentDoc.data() as Map<String, dynamic>)['userType'] ==
                'Parent') {
          await kte_firestore.FirestoreService()
              .linkParentToStudent(user.uid, parentDoc.id);
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Linked to Parent successfully!')),
            );
          }
        }
      }

      if (mounted) {
        Navigator.pop(context); // close sheet
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const WidgetTree()),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isVerifying = false;
          _errorMessage = e.toString().replaceAll('Exception: ', '');
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final defaultPinTheme = PinTheme(
      width: 56,
      height: 56,
      textStyle: const TextStyle(
        fontSize: 22,
        color: Colors.black87,
        fontWeight: FontWeight.bold,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.purple.shade200, width: 2),
      ),
    );

    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
        top: 30,
        left: 20,
        right: 20,
      ),
      decoration: BoxDecoration(
        color: Colors.purple.shade50,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Enter Verification Code',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              fontFamily: 'Poppins',
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'We have sent a 6-digit code to +91 ${widget.phone}',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 14,
              fontFamily: 'Sans',
              color: Colors.black54,
            ),
          ),
          const SizedBox(height: 30),
          Pinput(
            length: 6,
            controller: _otpController,
            defaultPinTheme: defaultPinTheme,
            focusedPinTheme: defaultPinTheme.copyWith(
              decoration: defaultPinTheme.decoration!.copyWith(
                border: Border.all(color: Colors.purple.shade900, width: 2),
              ),
            ),
            errorPinTheme: defaultPinTheme.copyWith(
              decoration: defaultPinTheme.decoration!.copyWith(
                border: Border.all(color: Colors.red.shade400, width: 2),
              ),
            ),
            onCompleted: _verifyAndSubmit,
          ),
          const SizedBox(height: 20),
          if (_errorMessage != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: Text(
                _errorMessage!,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.red.shade700,
                  fontFamily: 'Sans',
                  fontSize: 14,
                ),
              ),
            ),
          if (_isVerifying)
            const Padding(
              padding: EdgeInsets.only(bottom: 20),
              child: CircularProgressIndicator(),
            ),
        ],
      ),
    );
  }
}
