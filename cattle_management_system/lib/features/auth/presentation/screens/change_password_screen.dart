import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../core/di/injection_container.dart';
import '../../data/datasources/auth_local_data_source.dart';
import 'forgot_password_screen.dart'; // Will create next

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _oldPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscureOld = true;
  bool _obscureNew = true;
  bool _obscureConfirm = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Container(
          margin: const EdgeInsets.only(left: 16, top: 8, bottom: 8),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: const Color(0xFF8BC34A)), // Light green border
          ),
          child: IconButton(
            icon: const Icon(Icons.arrow_back, color: Color(0xFF8BC34A)),
            onPressed: () => Navigator.pop(context),
            padding: EdgeInsets.zero,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 16),
                // Logo
                Image.asset(
                  'assets/icons/cowlogo_splash.png',
                  width: 60,
                  height: 60,
                ),
                const SizedBox(height: 8),
                Text(
                  AppLocalizations.of(context)!.appName,
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryColor,
                  ),
                ),
                const SizedBox(height: 32),

                // Title
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    AppLocalizations.of(context)!.changePasswordTitle,
                    style: GoogleFonts.poppins(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF212121),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    AppLocalizations.of(context)!.changePasswordSubtitle,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: const Color(0xFF757575),
                      height: 1.5,
                    ),
                  ),
                ),
                const SizedBox(height: 32),

                // Old Password
                _buildLabel(AppLocalizations.of(context)!.labelOldPass),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _oldPasswordController,
                  obscureText: _obscureOld,
                  validator: (value) => value == null || value.isEmpty ? 'Required' : null,
                  decoration: _buildInputDecoration(
                    AppLocalizations.of(context)!.hintOldPass,
                    _obscureOld,
                    () => setState(() => _obscureOld = !_obscureOld),
                  ),
                ),
                const SizedBox(height: 16),

                // New Password
                _buildLabel(AppLocalizations.of(context)!.labelNewPass),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _newPasswordController,
                  obscureText: _obscureNew,
                  validator: (value) => value == null || value.length < 6 ? 'Min 6 chars' : null,
                  decoration: _buildInputDecoration(
                    AppLocalizations.of(context)!.hintNewPass,
                    _obscureNew,
                    () => setState(() => _obscureNew = !_obscureNew),
                  ),
                ),
                const SizedBox(height: 16),

                // Confirm Password
                _buildLabel(AppLocalizations.of(context)!.labelConfirmPass),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _confirmPasswordController,
                  obscureText: _obscureConfirm,
                  validator: (value) => value == null || value.isEmpty ? 'Required' : null,
                  decoration: _buildInputDecoration(
                    AppLocalizations.of(context)!.hintConfirmPass,
                    _obscureConfirm,
                    () => setState(() => _obscureConfirm = !_obscureConfirm),
                  ),
                ),
                const SizedBox(height: 24),

                // Forgot Password Link
                Center(
                  child: TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const ForgotPasswordScreen()),
                      );
                    },
                    child: Text(
                      AppLocalizations.of(context)!.forgotPassword, // Or custom text
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.primaryColor,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Change Password Button
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: () async {
                      if (_formKey.currentState!.validate()) {
                        if (_newPasswordController.text != _confirmPasswordController.text) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(AppLocalizations.of(context)!.passwordMismatch)),
                          );
                          return;
                        }

                        // Verify Old Password
                        final currentUserMobile = await sl<AuthLocalDataSource>().getCurrentUserMobile();
                        if (currentUserMobile == null) {
                          // Error, not logged in?
                          return;
                        }

                        // Use loginUser to verify old pass
                        final user = await sl<AuthLocalDataSource>().loginUser(currentUserMobile, _oldPasswordController.text);
                        if (user == null) {
                          if (!mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Invalid Old Password'), backgroundColor: Colors.red),
                          );
                          return;
                        }

                        // Change Password
                        final success = await sl<AuthLocalDataSource>().changePassword(currentUserMobile, _newPasswordController.text);
                        
                        if (!mounted) return;
                        if (success) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Password Changed Successfully'), backgroundColor: Colors.green),
                          );
                          Navigator.pop(context);
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Failed to change password'), backgroundColor: Colors.red),
                          );
                        }
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryColor,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      textStyle: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    child: Text(AppLocalizations.of(context)!.btnChangePassword),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        text,
        style: GoogleFonts.poppins(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: const Color(0xFF212121),
        ),
      ),
    );
  }

  InputDecoration _buildInputDecoration(String hint, bool obscure, VoidCallback toggle) {
    return InputDecoration(
      hintText: hint,
      hintStyle: GoogleFonts.inter(color: const Color(0xFF9E9E9E), fontSize: 14),
      prefixIcon: const Icon(Icons.lock_outline, color: Color(0xFF9E9E9E)),
      // Unlike design showing lock inside field text area? It has lock icon.
      // Usually prefixIcon is standard.
      // Design has lock icon.
      
      filled: true,
      fillColor: const Color(0xFFF9F9F9),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      suffixIcon: IconButton(
        icon: Icon(
          obscure ? Icons.visibility_off : Icons.visibility,
          color: const Color(0xFF9E9E9E),
        ),
        onPressed: toggle,
      ),
    );
  }
}
