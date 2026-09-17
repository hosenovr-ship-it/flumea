import 'package:flutter/material.dart';
import 'daily_times_screen.dart';
class FoodScreen extends StatelessWidget {
  const FoodScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              children: [
                // سهم الرجوع - الجهة اليسرى
                Padding(
                  padding: const EdgeInsets.fromLTRB(28, 24, 28, 0),
                  child: Directionality(
                    textDirection: TextDirection.ltr,
                    child: Row(
                      children: [
                        SizedBox(
                          width: 40,
                          height: 40,
                          child: IconButton(
                            padding: EdgeInsets.zero,
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            icon: const Icon(
                              Icons.arrow_back_ios_new,
                              color: Color(0xFF102A4C),
                              size: 24,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // المسافة بين السهم والعنوان
                const SizedBox(height: 38),

                // العنوان
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

                // المسافة بين العنوان والوصف
                const SizedBox(height: 14),

                // الوصف
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

                // المسافة بين الوصف والصورة
                const SizedBox(height: 45),

                // صورة الطعام الأصلية
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 30),
                  child: Image.asset(
                    'lib/food_tracking.png',
                    width: double.infinity,
                    height: 560,
                    fit: BoxFit.contain,
                  ),
                ),

                // المسافة بين الصورة والأزرار
                const SizedBox(height: 55),

                // الأزرار
                Padding(
                  padding: const EdgeInsets.fromLTRB(25, 0, 25, 24),
                  child: Column(
                    children: [
                      SizedBox(
                        width: double.infinity,
                        height: 60,
                        child: ElevatedButton(
                        onPressed: () {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => const DailyTimesScreen(),
    ),
  );
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
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => const DailyTimesScreen(),
    ),
  );
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
      ),
    );
  }
}
