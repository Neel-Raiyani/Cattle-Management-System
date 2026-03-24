import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../features/auth/domain/repositories/auth_repository.dart';
import '../../../../features/auth/presentation/screens/login_screen.dart';
import '../../../../presentation/screens/home_screen.dart';
import 'language_selection_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateToNext();
  }

  _navigateToNext() async {
    final prefs = sl<SharedPreferences>();
    final hadStoredToken =
        (prefs.getString('auth_token') ?? '').trim().isNotEmpty;

    final isLoggedIn = await sl<AuthRepository>().isLoggedIn();

    if (mounted) {
      if (isLoggedIn) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomeScreen()),
        );
      } else if (hadStoredToken) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LoginScreen()),
        );
      } else {
        // For non-logged in users, give them 2 seconds total splash time
        await Future.delayed(const Duration(seconds: 1));
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => const LanguageSelectionScreen(),
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/icons/cowlogo_splash.png',
              width: 150,
              height: 150,
            ),
            const SizedBox(height: 24),
            // Use Localization or hardcoded if localization not ready?
            // AppLocalizations might be null if context not ready? No, it's inside MaterialApp.
            // But verify import.
            Text(
              AppLocalizations.of(context)?.appName ?? 'Smart Gaushala',
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                fontFamily: 'Poppins',
                color: Color(0xFF212121),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
