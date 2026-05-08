import 'package:flutter/material.dart';
import 'features/auth/auth_screen.dart';
import 'features/splash/splash_screen.dart';
import 'features/onboarding/onboarding_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  Future<bool> hasSeenOnboarding() async {
    final prefs = await SharedPreferences.getInstance();

    return prefs.getBool('hasSeenOnboarding') ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: hasSeenOnboarding(),

      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const MaterialApp(
            home: Scaffold(body: Center(child: CircularProgressIndicator())),
          );
        }

        return MaterialApp(
          debugShowCheckedModeBanner: false,

          routes: {
            '/onboarding': (context) => const OnboardingScreen(),
            '/auth': (context) => const AuthScreen(),
          },
          

          home: snapshot.data!
              ? const SplashScreen()
              : const OnboardingScreen(),
        );
      },
    );
  }
}
