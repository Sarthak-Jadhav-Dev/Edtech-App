import 'package:flutter/material.dart';
import 'package:kte/services/auth_services.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _isLoading = false;
  final String _email = FirebaseAuth.instance.currentUser?.email ?? '';

  Future<void> _handlePasswordReset() async {
    if (_email.isEmpty) {
       ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Email not found for this account.")));
       return;
    }

    setState(() => _isLoading = true);
    try {
      await AuthService().sendPasswordResetEmail(_email);
      if (mounted) {
        showDialog(
          context: context,
          builder: (c) => AlertDialog(
            title: const Text("Reset Email Sent"),
            content: Text("A password reset link has been sent to $_email. Please check your inbox."),
            actions: [TextButton(onPressed: () => Navigator.pop(c), child: const Text("OK"))],
          ),
        );
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: ${e.toString()}")));
    }
    setState(() => _isLoading = false);
  }

  Future<void> _handleDeleteAccount() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text("Delete Account"),
        content: const Text("Are you sure? This will permanently delete your account and all associated data. This action is irreversible."),
        actions: [
          TextButton(onPressed: () => Navigator.pop(c, false), child: const Text("Cancel")),
          TextButton(
            onPressed: () => Navigator.pop(c, true), 
            child: const Text("Delete Permanently", style: TextStyle(color: Colors.red))
          ),
        ],
      )
    ) ?? false;

    if (confirm) {
        setState(() => _isLoading = true);
        try {
          await AuthService().deleteAccount();
          // The auth state listener in main will handle navigation
        } catch (e) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Please re-login to perform this sensitive action."))
            );
          }
        }
        setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.purple.shade50,
      appBar: AppBar(
        title: const Text("Settings & Security", style: TextStyle(fontFamily: "Poppins", fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Stack(
        children: [
          ListView(
            padding: const EdgeInsets.all(20),
            children: [
              _buildSectionHeader("Account Security"),
              _buildSettingTile(
                icon: Icons.lock_reset,
                title: "Reset Password",
                subtitle: "Get a reset link on your registered email",
                onTap: _handlePasswordReset,
              ),
              _buildSettingTile(
                icon: Icons.security,
                title: "App Security",
                subtitle: "Learn about how we protect your data",
                onTap: () {
                  showModalBottomSheet(
                    context: context,
                    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(25))),
                    builder: (c) => Padding(
                      padding: const EdgeInsets.all(25),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text("Application Security", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, fontFamily: "Poppins")),
                          const SizedBox(height: 15),
                          const Text(
                            "We use industry-standard encryption to protect your personal information and learning progress. Your data is securely stored in Firebase and only accessible to you and your linked parents/teachers.",
                            textAlign: TextAlign.center,
                            style: TextStyle(fontFamily: "Sans", color: Colors.black87),
                          ),
                          const SizedBox(height: 25),
                          ElevatedButton(
                            onPressed: () => Navigator.pop(c),
                            style: ElevatedButton.styleFrom(backgroundColor: Colors.purple, shape: const StadiumBorder()),
                            child: const Text("Understood", style: TextStyle(color: Colors.white)),
                          )
                        ],
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 20),
              _buildSectionHeader("Preferences"),
              _buildSettingTile(
                icon: Icons.palette_outlined,
                title: "App Theme",
                subtitle: "Currently set to Purple Harmony",
                onTap: () {},
                trailing: const Icon(Icons.check_circle, color: Colors.green, size: 20),
              ),
              _buildSettingTile(
                icon: Icons.notifications_active_outlined,
                title: "Push Notifications",
                subtitle: "Manage alert preferences",
                onTap: () {},
                trailing: Switch(value: true, onChanged: (v){}, activeThumbColor: Colors.purple),
              ),
              const SizedBox(height: 40),
              _buildSectionHeader("Advanced"),
              _buildSettingTile(
                icon: Icons.delete_forever,
                title: "Delete Account",
                subtitle: "Danger Zone: Permanently remove data",
                color: Colors.red,
                onTap: _handleDeleteAccount,
              ),
              const SizedBox(height: 50),
              const Center(
                child: Text("Kids EduTech App v1.0.0", style: TextStyle(color: Colors.grey, fontSize: 12)),
              )
            ],
          ),
          if (_isLoading)
            const Center(child: CircularProgressIndicator()),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 10, bottom: 10),
      child: Text(title, style: TextStyle(color: Colors.purple.shade900, fontWeight: FontWeight.bold, fontSize: 13, letterSpacing: 1.2)),
    );
  }

  Widget _buildSettingTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    Color? color,
    Widget? trailing,
  }) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        leading: CircleAvatar(
          backgroundColor: (color ?? Colors.purple).withValues(alpha: 0.1),
          child: Icon(icon, color: color ?? Colors.purple, size: 20),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontFamily: "Sans")),
        subtitle: Text(subtitle, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        trailing: trailing ?? const Icon(Icons.chevron_right, size: 18),
      ),
    );
  }
}
