import 'package:flutter/material.dart';

void main() {
  runApp(const FlumeaApp());
}

class FlumeaApp extends StatelessWidget {
  const FlumeaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'FLUMEA',
      home: const WelcomeScreen(),
    );
  }
}

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFFF1FBFA),
                Color(0xFFE2F5F0),
                Color(0xFFCDEDE5),
              ],
            ),
          ),
          child: SafeArea(
            child: Column(
              children: [
                const Spacer(),

                const Text(
                  '≋',
                  style: TextStyle(
                    fontSize: 90,
                    color: Color(0xFF08B878),
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const Text(
                  'FLUMEA',
                  textDirection: TextDirection.ltr,
                  style: TextStyle(
                    fontSize: 40,
                    letterSpacing: 8,
                    color: Color(0xFF14204A),
                  ),
                ),

                const SizedBox(height: 45),

                const Text(
                  'مساعدك اليومي الذكي',
                  style: TextStyle(
                    fontSize: 27,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF14204A),
                  ),
                ),

                const SizedBox(height: 12),

                const Text(
                  'للتخطيط، التنفيذ والمراجعة',
                  style: TextStyle(
                    fontSize: 19,
                    color: Color(0xFF34405D),
                  ),
                ),

                const SizedBox(height: 8),

                const Text(
                  'مع تسجيل الطعام كجزء من يومك.',
                  style: TextStyle(
                    fontSize: 17,
                    color: Color(0xFF34405D),
                  ),
                ),

                const Spacer(),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 34),
                  child: SizedBox(
                    width: double.infinity,
                    height: 62,
                    child: ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF08B878),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: const Text(
                        'ابدأ رحلتك',
                        style: TextStyle(
                          fontSize: 21,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 25),

                const Text(
                  'لديك حساب؟  تسجيل الدخول',
                  style: TextStyle(
                    fontSize: 17,
                    color: Color(0xFF34405D),
                  ),
                ),

                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
