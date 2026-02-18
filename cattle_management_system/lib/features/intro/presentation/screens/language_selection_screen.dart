import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/bloc/language/language_cubit.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../auth/presentation/screens/login_screen.dart';

class LanguageSelectionScreen extends StatefulWidget {
  const LanguageSelectionScreen({super.key});

  @override
  State<LanguageSelectionScreen> createState() => _LanguageSelectionScreenState();
}

class _LanguageSelectionScreenState extends State<LanguageSelectionScreen> {
  String? _selectedLanguageCode;

  final List<Map<String, String>> _languages = [
    {'code': 'en', 'name': 'English', 'nativeName': 'English'},
    {'code': 'gu', 'name': 'Gujarati', 'nativeName': 'ગુજરાતી'},
    {'code': 'hi', 'name': 'Hindi', 'nativeName': 'हिन्दी'},
  ];
  
  // Helper to get localized name if needed, but for language picker native name is best.
  // We keep 'name' for subtitle.

  @override
  Widget build(BuildContext context) {
    // Determine current language from state or cubit? 
    // Usually initial selection is empty or system default.
    // If not selected, user must select.
    
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 48),
              // Icon
              const Icon(
                Icons.translate,
                size: 64,
                color: Color(0xFF212121),
              ),
              const SizedBox(height: 24),
              // Title
              Text(
                AppLocalizations.of(context)!.selectLanguage,
                style: GoogleFonts.poppins(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF212121),
                ),
              ),
              const SizedBox(height: 48),
              // Language Grid
              Expanded(
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 1.1,
                  ),
                  itemCount: _languages.length,
                  itemBuilder: (context, index) {
                    final lang = _languages[index];
                    final isSelected = _selectedLanguageCode == lang['code'];
                    
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedLanguageCode = lang['code'];
                        });
                        // Optional: Live preview of language change? 
                        // User requested selectable options, then continue.
                        // So we don't change app language immediately on tap, only on Continue?
                        // Or change immediately to preview?
                        // Let's change immediately to preview effect!
                        context.read<LanguageCubit>().changeLanguage(Locale(lang['code']!));
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: isSelected ? AppTheme.primaryColor : const Color(0xFFF5F5F5),
                          borderRadius: BorderRadius.circular(16),
                          border: isSelected ? null : Border.all(color: Colors.transparent),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              lang['nativeName']!,
                              style: GoogleFonts.poppins(
                                fontSize: 24,
                                fontWeight: FontWeight.w600,
                                color: isSelected ? Colors.white : const Color(0xFF212121),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              lang['name']!,
                              style: GoogleFonts.inter(
                                fontSize: 14,
                                color: isSelected ? Colors.white70 : const Color(0xFF757575),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              // Continue Button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _selectedLanguageCode != null
                      ? () {
                          // Already changed for preview, just navigate
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const LoginScreen(),
                            ),
                          );
                        }
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                    disabledBackgroundColor: const Color(0xFFEEEEEE),
                    foregroundColor: Colors.white,
                    disabledForegroundColor: const Color(0xFFBDBDBD),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    textStyle: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  child: Text(AppLocalizations.of(context)!.continueButton),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
