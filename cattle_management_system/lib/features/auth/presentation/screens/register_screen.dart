import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../l10n/app_localizations.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';
import '../../../../presentation/screens/home_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _mobileController = TextEditingController();
  final _gaushalaNameController = TextEditingController();
  final _totalCowController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  String? _selectedCity;

  final List<String> _cities = [
    'Ahmedabad',
    'Surat',
    'Vadodara',
    'Rajkot',
    'Gandhinagar',
    'Mumbai',
    'Delhi',
    'Jaipur',
    'Udaipur',
    'Other',
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _mobileController.dispose();
    _gaushalaNameController.dispose();
    _totalCowController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
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
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.center, // Center alignment for header
              children: [
                const SizedBox(height: 16),
                // Logo & App Name
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
                    color: AppTheme.primaryColor, // Green color as per design
                  ),
                ),
                const SizedBox(height: 32),

                // Join Title
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    AppLocalizations.of(context)!.joinTitle,
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
                    AppLocalizations.of(context)!.joinSubtitle,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: const Color(0xFF757575),
                      height: 1.5,
                    ),
                  ),
                ),
                const SizedBox(height: 32),

                // Name Field
                _buildLabel(AppLocalizations.of(context)!.labelName),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _nameController,
                  validator: (value) =>
                      value == null || value.isEmpty ? 'Required' : null,
                  decoration: _buildInputDecoration(
                    AppLocalizations.of(context)!.hintName,
                  ),
                ),
                const SizedBox(height: 16),

                // Mobile Number
                _buildLabel(
                  AppLocalizations.of(context)!.labelMobileTrilingual,
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _mobileController,
                  validator: (value) => value == null || value.length < 10
                      ? 'Invalid mobile'
                      : null,
                  keyboardType: TextInputType.phone,
                  decoration: _buildInputDecoration(
                    AppLocalizations.of(context)!.hintMobileTrilingual,
                  ),
                ),
                const SizedBox(height: 16),

                // City Dropdown
                _buildLabel(AppLocalizations.of(context)!.labelCity),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  value: _selectedCity,
                  items: _cities.map((city) {
                    return DropdownMenuItem(value: city, child: Text(city));
                  }).toList(),
                  onChanged: (val) {
                    setState(() {
                      _selectedCity = val;
                    });
                  },
                  validator: (value) => value == null ? 'Required' : null,
                  decoration: _buildInputDecoration(
                    AppLocalizations.of(context)!.hintCity,
                  ).copyWith(suffixIcon: const Icon(Icons.keyboard_arrow_down)),
                  icon:
                      const SizedBox.shrink(), // Remove default icon to use custom suffix
                ),
                const SizedBox(height: 16),

                // Gaushala Name
                _buildLabel(
                  AppLocalizations.of(context)!.labelGaushalaTrilingual,
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _gaushalaNameController,
                  validator: (value) =>
                      value == null || value.isEmpty ? 'Required' : null,
                  decoration: _buildInputDecoration(
                    AppLocalizations.of(context)!.hintGaushalaTrilingual,
                  ),
                ),
                const SizedBox(height: 16),

                // Total Cow
                _buildLabel(AppLocalizations.of(context)!.labelCow),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _totalCowController,
                  keyboardType: TextInputType.number,
                  validator: (value) =>
                      value == null || value.isEmpty ? 'Required' : null,
                  decoration: _buildInputDecoration(
                    AppLocalizations.of(context)!.hintCow,
                  ),
                ),
                const SizedBox(height: 16),

                // Password
                _buildLabel(AppLocalizations.of(context)!.password),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  validator: (value) =>
                      value == null || value.length < 6 ? 'Min 6 chars' : null,
                  decoration:
                      _buildInputDecoration(
                        AppLocalizations.of(context)!.passwordHint,
                      ).copyWith(
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility_off
                                : Icons.visibility,
                          ),
                          onPressed: () => setState(
                            () => _obscurePassword = !_obscurePassword,
                          ),
                        ),
                      ),
                ),
                const SizedBox(height: 16),

                // Confirm Password
                _buildLabel(AppLocalizations.of(context)!.confirmPassword),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _confirmPasswordController,
                  obscureText: _obscureConfirmPassword,
                  validator: (value) {
                    if (value == null || value.isEmpty) return 'Required';
                    if (value != _passwordController.text)
                      return AppLocalizations.of(context)!.passwordMismatch;
                    return null;
                  },
                  decoration:
                      _buildInputDecoration(
                        AppLocalizations.of(context)!.confirmPasswordHint,
                      ).copyWith(
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscureConfirmPassword
                                ? Icons.visibility_off
                                : Icons.visibility,
                          ),
                          onPressed: () => setState(
                            () => _obscureConfirmPassword =
                                !_obscureConfirmPassword,
                          ),
                        ),
                      ),
                ),
                const SizedBox(height: 48),

                // Submit Button
                // Submit Button
                BlocConsumer<AuthBloc, AuthState>(
                  listener: (context, state) {
                    if (state is AuthRegistered) {
                      // Automatically login after successful registration
                      context.read<AuthBloc>().add(
                        LoginEvent(
                          mobile: _mobileController.text,
                          password: _passwordController.text,
                        ),
                      );
                    } else if (state is AuthAuthenticated) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Registration Successful!'),
                          backgroundColor: Colors.green,
                          duration: Duration(seconds: 2),
                        ),
                      );

                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const HomeScreen(),
                        ),
                        (route) => false,
                      );
                    } else if (state is AuthError) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(state.message),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  },
                  builder: (context, state) {
                    final isLoading = state is AuthLoading;
                    return SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: isLoading
                            ? null
                            : () {
                                if (_formKey.currentState!.validate()) {
                                  context.read<AuthBloc>().add(
                                    RegisterEvent(
                                      name: _nameController.text,
                                      mobile: _mobileController.text,
                                      password: _passwordController.text,
                                      confirmPassword:
                                          _confirmPasswordController.text,
                                      city: _selectedCity ?? '',
                                      gaushalaName: _gaushalaNameController.text,
                                      totalCattle: int.tryParse(_totalCowController.text) ?? 0,
                                    ),
                                  );
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
                        child: isLoading
                            ? const CircularProgressIndicator(
                                color: Colors.white,
                              )
                            : Text(AppLocalizations.of(context)!.submit),
                      ),
                    );
                  },
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

  InputDecoration _buildInputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: GoogleFonts.inter(
        color: const Color(0xFF9E9E9E),
        fontSize: 14,
      ),
      filled: true,
      fillColor: const Color(0xFFF9F9F9), // Very light gray from design
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    );
  }
}
