import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import './service/api_service.dart';
import './screens/main_navigation_screen.dart';
import './screens/onboarding_screen.dart';
import './screens/login_screen.dart';
import './screens/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('id_ID', null);
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  Future<Widget> _getInitialScreen() async {
    final results = await Future.wait([
      ApiService.isLoggedIn(),
      ApiService.hasSeenOnboarding(),
      Future.delayed(const Duration(seconds: 3)),
    ]);

    final bool isLoggedIn = results[0] as bool;
    final bool hasSeenOnboarding = results[1] as bool;

    if (isLoggedIn) {
      return const MainNavigationScreen();
    }

    if (hasSeenOnboarding) {
      return const LoginScreen();
    }

    return const OnboardingScreen();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'NutriTrack',
      theme: ThemeData(primarySwatch: Colors.green, fontFamily: 'Signika'),
      home: FutureBuilder<Widget>(
        future: _getInitialScreen(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const SplashScreen();
          }
          return snapshot.data ?? const OnboardingScreen();
        },
      ),
      routes: {
        '/onboarding': (context) => const OnboardingScreen(),
        '/login': (context) => const LoginScreen(),
        '/main': (context) => const MainNavigationScreen(),
      },
    );
  }
}
