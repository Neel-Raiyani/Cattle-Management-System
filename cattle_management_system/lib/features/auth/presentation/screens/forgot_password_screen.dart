import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cattle_management_system/core/theme/app_theme.dart';
import 'package:cattle_management_system/l10n/app_localizations.dart';
import 'package:cattle_management_system/core/di/injection_container.dart';
import 'package:cattle_management_system/core/error/exceptions.dart';
import 'package:cattle_management_system/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:cattle_management_system/features/auth/presentation/screens/verify_otp_screen.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _mobileController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  @override
  void dispose() {
    _mobileController.dispose();
    super.dispose();
  }

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
            border: Border.all(color: AppTheme.primaryColor),
          ),
          child: IconButton(
            icon: const Icon(Icons.arrow_back, color: AppTheme.primaryColor),
            onPressed: () => Navigator.pop(context),
            padding: EdgeInsets.zero,
          ),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16),
                Text(
                  AppLocalizations.of(context)!.forgotPassword,
                  style: GoogleFonts.poppins(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF212121),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  AppLocalizations.of(context)!.forgotPasswordSubtitle,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: const Color(0xFF757575), // Grey text
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 32),
                
                // Mobile Field Logic
                Text(
                  AppLocalizations.of(context)!.mobileNumber,
                   style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF212121),
                  ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _mobileController,
                  validator: (value) => value == null || value.length < 10 ? 'Invalid mobile' : null,
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(
                    hintText: AppLocalizations.of(context)!.mobileHint,
                    prefixIcon: const Icon(Icons.phone_outlined, color: Color(0xFF757575)),
                    filled: true,
                    fillColor: const Color(0xFFF5F5F5),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
                
                const Spacer(),
                
                // Continue Button
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _handleContinue,
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
                    child: _isLoading 
                      ? const SizedBox(
                          width: 24, 
                          height: 24, 
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
                        )
                      : Text(AppLocalizations.of(context)!.continueButton),
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

  Future<void> _handleContinue() async {
    if (_formKey.currentState!.validate()) {
      setState(() { _isLoading = true; });
      
      final scaffoldMessenger = ScaffoldMessenger.of(context);
      final navigator = Navigator.of(context);
      final mobile = _mobileController.text;

      try {
        await sl<AuthRemoteDataSource>().sendForgotPasswordOtp(
          mobileNumber: mobile.trim(),
        );

        if (!mounted) return;
        setState(() { _isLoading = false; });

        navigator.push(
          MaterialPageRoute(
            builder: (context) => VerifyOtpScreen(mobileNumber: mobile.trim()),
          ),
        );
      } on ServerException catch (e) {
        if (!mounted) return;
        setState(() { _isLoading = false; });
        scaffoldMessenger.showSnackBar(
           SnackBar(content: Text(e.message), backgroundColor: Colors.red),
        );
      } catch (e) {
        if (!mounted) return;
        setState(() { _isLoading = false; });
        scaffoldMessenger.showSnackBar(
           const SnackBar(content: Text('Failed to send OTP'), backgroundColor: Colors.red),
        );
      }
    }
  }
}
