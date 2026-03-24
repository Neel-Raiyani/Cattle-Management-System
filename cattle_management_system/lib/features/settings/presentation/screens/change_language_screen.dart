import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/bloc/language/language_cubit.dart';
import '../../../../l10n/app_localizations.dart';

class ChangeLanguageScreen extends StatefulWidget {
  const ChangeLanguageScreen({super.key});

  @override
  State<ChangeLanguageScreen> createState() => _ChangeLanguageScreenState();
}

class _ChangeLanguageScreenState extends State<ChangeLanguageScreen> {
  late String _selectedLanguageCode;

  final List<Map<String, String>> _languages = [
    {'code': 'en', 'name': 'English', 'nativeName': 'English'},
    {'code': 'gu', 'name': 'Gujarati', 'nativeName': 'ગુજરાતી'},
    {'code': 'hi', 'name': 'Hindi', 'nativeName': 'हिन्दी'},
  ];

  @override
  void initState() {
    super.initState();
    _selectedLanguageCode = context.read<LanguageCubit>().state.languageCode;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          AppLocalizations.of(context)!.selectLanguage,
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: Container(
          margin: const EdgeInsets.only(left: 16, top: 8, bottom: 8),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: AppTheme.primaryColor),
          ),
          child: IconButton(
            icon: const Icon(
              Icons.arrow_back,
              color: AppTheme.primaryColor,
              size: 20,
            ),
            onPressed: () => Navigator.pop(context),
            padding: EdgeInsets.zero,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
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
                        _selectedLanguageCode = lang['code']!;
                      });
                      context.read<LanguageCubit>().changeLanguage(
                        Locale(lang['code']!),
                      );
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppTheme.primaryColor
                            : const Color(0xFFF5F5F5),
                        borderRadius: BorderRadius.circular(16),
                        border: isSelected
                            ? null
                            : Border.all(color: Colors.transparent),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            lang['nativeName']!,
                            style: GoogleFonts.poppins(
                              fontSize: 24,
                              fontWeight: FontWeight.w600,
                              color: isSelected
                                  ? Colors.white
                                  : const Color(0xFF212121),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            lang['name']!,
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              color: isSelected
                                  ? Colors.white70
                                  : const Color(0xFF757575),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  elevation: 2,
                ),
                child: Text(
                  AppLocalizations.of(
                    context,
                  )!.submit, // Using 'Submit' as 'Done' isn't available
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
