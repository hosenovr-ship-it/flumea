import 'package:flutter/material.dart';

class FoodScreen extends StatelessWidget {
  const FoodScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Column(
            children: [
              // سهم الرجوع فقط
              Padding(
                padding: const EdgeInsets.fromLTRB(28, 24, 28, 0),
                child: Row(
                  children: [
                    IconButton(
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(
                        minWidth: 40,
                        minHeight: 40,
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      icon: const Icon(
                        Icons.arrow_back_ios_new,
                        color: Color(0xFF102A4C),
                        size: 24,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 38),

              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 25),
                child: Text(
                  'هل تريد تسجيل طعامك\nومتابعة السعرات؟',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 29,
                    height: 1.35,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF102A4C),
                  ),
                ),
              ),

              const SizedBox(height: 14),

              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 25),
                child: Text(
                  'سيساعدك ذلك على فهم غذائك بشكل أفضل',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFFA0A8B3),
                  ),
                ),
              ),

              const SizedBox(height: 28),

              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 30),
                  child: Center(
                    child: Image.asset(
                      'food_tracking.png',
                      width: double.infinity,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ),

              Padding(
                padding: const EdgeInsets.fromLTRB(25, 8, 25, 24),
                child: Column(
                  children: [
                    SizedBox(
                      width: double.infinity,
                      height: 60,
                      child: ElevatedButton(
                        onPressed: () {
                          // سنربطه بالصفحة التالية لاحقًا
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF08B477),
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(17),
                          ),
                        ),
                        child: const Text(
                          'نعم، أريد تسجيل الطعام',
                          style: TextStyle(
                            fontSize: 19,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),

                    SizedBox(
                      width: double.infinity,
                      height: 60,
                      child: OutlinedButton(
                        onPressed: () {
                          // سنربطه بالصفحة التالية لاحقًا
                        },
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFF102A4C),
                          side: const BorderSide(
                            color: Color(0xFFE1E5EA),
                            width: 1.3,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(17),
                          ),
                        ),
                        child: const Text(
                          'لا، ليس الآن',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
