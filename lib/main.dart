import 'dart:async';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'login_screen.dart';
import 'theme_controller.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://mmmypwmdzkjmsdhmjdfd.supabase.co',
    publishableKey: 'sb_publishable_RIA_bgKUcEqSRi1cZjTHA_-6g3m0xs',
  );

  await FlumeaThemeController.load();

  runApp(const FlumeaApp());
}

class FlumeaApp extends StatelessWidget {
  const FlumeaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: FlumeaThemeController.mode,
      builder: (context, themeMode, _) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'FLUMEA',
          themeMode: themeMode,
          theme: ThemeData(
            brightness: Brightness.light,
            colorScheme: ColorScheme.fromSeed(
              seedColor: const Color(0xFF1976D2),
              brightness: Brightness.light,
            ),
            scaffoldBackgroundColor: const Color(0xFFF7FAFC),
            useMaterial3: true,
          ),
          darkTheme: ThemeData(
            brightness: Brightness.dark,
            colorScheme: ColorScheme.fromSeed(
              seedColor: const Color(0xFF1976D2),
              brightness: Brightness.dark,
            ),
            scaffoldBackgroundColor: const Color(0xFF0F1720),
            useMaterial3: true,
          ),
          home: const WelcomeScreen(),
        );
      },
    );
  }
}

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  @override
  void initState() {
    super.initState();

    Timer(const Duration(seconds: 2), () {
      if (!mounted) return;

      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) {
            return const LoginScreen();
          },
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(
              opacity: animation,
              child: child,
            );
          },
          transitionDuration: const Duration(milliseconds: 600),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SizedBox.expand(
        child: Image.asset(
          'welcome_background.png',
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}
