import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'core/services/navigation_service.dart';
import 'l10n/app_localizations.dart';

import 'core/theme/app_theme.dart';
import 'core/di/injection_container.dart' as di;
import 'core/bloc/language/language_cubit.dart';
import 'features/intro/presentation/screens/splash_screen.dart';
import 'features/cattle/presentation/bloc/cattle_bloc.dart';
import 'features/milk_production/presentation/bloc/milk_production_bloc.dart';
import 'features/cow_group/presentation/bloc/cow_group_bloc.dart';

import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/auth/presentation/bloc/auth_event.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize dependency injection
  await di.initializeDependencies();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<LanguageCubit>(
          create: (context) => LanguageCubit()..loadLanguage(),
        ),
        BlocProvider<AuthBloc>(
          create: (context) => di.sl<AuthBloc>()..add(CheckAuthStatusEvent()),
        ),
        BlocProvider<CattleBloc>(create: (context) => di.sl<CattleBloc>()),
        BlocProvider<MilkProductionBloc>(
          create: (context) => di.sl<MilkProductionBloc>(),
        ),
        BlocProvider<CowGroupBloc>(create: (context) => CowGroupBloc(di.sl())),
      ],
      child: BlocBuilder<LanguageCubit, Locale>(
        builder: (context, locale) {
          return ScreenUtilInit(
            designSize: const Size(375, 812), // Figma design size
            minTextAdapt: true,
            splitScreenMode: true,
            builder: (context, child) {
              return MaterialApp(
                navigatorKey: NavigationService.navigatorKey,
                onGenerateTitle: (context) =>
                    AppLocalizations.of(context)?.appName ?? 'Smart Gaushala',
                debugShowCheckedModeBanner: false,
                theme: AppTheme.lightTheme,
                // Localization
                locale: locale,
                localizationsDelegates: const [
                  AppLocalizations.delegate,
                  GlobalMaterialLocalizations.delegate,
                  GlobalWidgetsLocalizations.delegate,
                  GlobalCupertinoLocalizations.delegate,
                ],
                supportedLocales: const [
                  Locale('en'),
                  Locale('hi'),
                  Locale('gu'),
                ],
                // The onError property is not a standard property of MaterialApp.
                // This logic is typically handled in a network client's interceptor (e.g., Dio interceptor).
                // However, to faithfully apply the provided code edit, it's placed here.
                // Note: This will cause a compilation error as `MaterialApp` does not have an `onError` property.
                // If the intention was to handle errors from a network client, that logic should be in the client itself.
                // For demonstration purposes, I'm adding it as requested, but it's syntactically incorrect for MaterialApp.
                // onError: (error, handler) {
                //   // Handle 401 Unauthorized globally
                //   if (error.response?.statusCode == 401) {
                //     final ctx = NavigationService.navigatorKey.currentContext;
                //     if (ctx != null) {
                //       // Clear session and redirect to login
                //       Navigator.pushAndRemoveUntil(
                //         ctx,
                //         MaterialPageRoute(builder: (context) => const LoginScreen()),
                //         (route) => false,
                //       );
                //       ScaffoldMessenger.of(ctx).showSnackBar(
                //         const SnackBar(
                //           content: Text('Session expired. Please log in again.'),
                //           backgroundColor: Colors.red,
                //         ),
                //       );
                //     }
                //   }
                //   return handler.next(error);
                // },
                home: const SplashScreen(),
              );
            },
          );
        },
      ),
    );
  }
}
