import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
              horizontal: 24,
              vertical: 35,
            ),
            child: Column(
              children: [
                const SizedBox(height: 55),

                const Text(
                  'مرحباً بك في FLUMEA',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF102A4C),
                  ),
                ),

                const SizedBox(height: 18),

                const Text(
                  'اختر طريقة التسجيل أو تسجيل الدخول',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 20,
                    color: Color(0xFF8A97AD),
                  ),
                ),

                const SizedBox(height: 55),

                // Google
                _loginButton(
                  icon: const Text(
                    'G',
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF4285F4),
                    ),
                  ),
                  text: 'متابعة باستخدام Google',
                  onTap: () {},
                ),

                const SizedBox(height: 16),

                // Apple
                _loginButton(
                  icon: const FaIcon(
                    FontAwesomeIcons.apple,
                    color: Colors.black,
                    size: 27,
                  ),
                  text: 'متابعة باستخدام Apple',
                  onTap: () {},
                ),

                const SizedBox(height: 28),

                Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: 1,
                        color: const Color(0xFFE1E6ED),
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        'أو',
                        style: TextStyle(
                          fontSize: 16,
                          color: Color(0xFF8A97AD),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Container(
                        height: 1,
                        color: const Color(0xFFE1E6ED),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 28),

                // Email
                _loginButton(
                  icon: const Icon(
                    Icons.email_outlined,
                    color: Color(0xFF102A4C),
                    size: 28,
                  ),
                  text: 'متابعة باستخدام البريد الإلكتروني',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const EmailAuthScreen(),
                      ),
                    );
                  },
                ),

                const SizedBox(height: 32),

                const Text(
                  'بالتسجيل، أنت توافق على الشروط والأحكام و سياسة الخصوصية',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13,
                    color: Color(0xFF8A97AD),
                    height: 1.6,
                  ),
                ),

                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  static Widget _loginButton({
    required Widget icon,
    required String text,
    required VoidCallback onTap,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 62,
      child: OutlinedButton(
        onPressed: onTap,
        style: OutlinedButton.styleFrom(
          backgroundColor: Colors.white,
          side: const BorderSide(
            color: Color(0xFFE1E6ED),
            width: 1.3,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: Row(
          children: [
            SizedBox(
              width: 52,
              child: Center(child: icon),
            ),
            Expanded(
              child: Text(
                text,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF102A4C),
                ),
              ),
            ),
            const SizedBox(width: 52),
          ],
        ),
      ),
    );
  }
}

// ==========================================
// شاشة تسجيل الدخول بالبريد الإلكتروني
// ==========================================

class EmailAuthScreen extends StatefulWidget {
  const EmailAuthScreen({super.key});

  @override
  State<EmailAuthScreen> createState() => _EmailAuthScreenState();
}

class _EmailAuthScreenState extends State<EmailAuthScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  bool isLogin = true;
  bool isLoading = false;
  bool obscurePassword = true;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final email = emailController.text.trim();
    final password = passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      _showMessage('يرجى إدخال البريد الإلكتروني وكلمة المرور');
      return;
    }

    if (password.length < 8) {
      _showMessage('كلمة المرور يجب أن تكون 8 أحرف على الأقل');
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      if (isLogin) {
        await Supabase.instance.client.auth.signInWithPassword(
          email: email,
          password: password,
        );

        if (!mounted) return;

        _showMessage('تم تسجيل الدخول بنجاح ✅');

        Navigator.pop(context);
      } else {
        final response =
            await Supabase.instance.client.auth.signUp(
          email: email,
          password: password,
        );

        if (!mounted) return;

        if (response.session == null) {
          _showMessage(
            'تم إنشاء الحساب ✅\nتحقق من بريدك الإلكتروني لتأكيد الحساب.',
          );
        } else {
          _showMessage('تم إنشاء الحساب بنجاح ✅');
        }
      }
    } on AuthException catch (error) {
      if (!mounted) return;

      _showMessage(error.message);
    } catch (error) {
      if (!mounted) return;

      _showMessage('حدث خطأ غير متوقع، حاول مرة أخرى.');
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          textAlign: TextAlign.right,
        ),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          foregroundColor: const Color(0xFF102A4C),
          title: Text(
            isLogin ? 'تسجيل الدخول' : 'إنشاء حساب',
            style: const TextStyle(
              color: Color(0xFF102A4C),
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 35),

                const Icon(
                  Icons.lock_outline,
                  size: 60,
                  color: Color(0xFF102A4C),
                ),

                const SizedBox(height: 25),

                Text(
                  isLogin
                      ? 'مرحباً بعودتك 👋'
                      : 'أنشئ حسابك في FLUMEA',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 27,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF102A4C),
                  ),
                ),

                const SizedBox(height: 12),

                Text(
                  isLogin
                      ? 'سجّل الدخول للمتابعة'
                      : 'أدخل بياناتك لإنشاء حساب جديد',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Color(0xFF8A97AD),
                  ),
                ),

                const SizedBox(height: 40),

                TextField(
                  controller: emailController,
                  keyboardType: TextInputType.emailAddress,
                  textDirection: TextDirection.ltr,
                  decoration: InputDecoration(
                    labelText: 'البريد الإلكتروني',
                    hintText: 'example@email.com',
                    prefixIcon: const Icon(Icons.email_outlined),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),

                const SizedBox(height: 18),

                TextField(
                  controller: passwordController,
                  obscureText: obscurePassword,
                  decoration: InputDecoration(
                    labelText: 'كلمة المرور',
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      onPressed: () {
                        setState(() {
                          obscurePassword = !obscurePassword;
                        });
                      },
                      icon: Icon(
                        obscurePassword
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                      ),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),

                const SizedBox(height: 28),

                SizedBox(
                  height: 58,
                  child: ElevatedButton(
                    onPressed: isLoading ? null : _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF102A4C),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: isLoading
                        ? const SizedBox(
                            width: 25,
                            height: 25,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              color: Colors.white,
                            ),
                          )
                        : Text(
                            isLogin
                                ? 'تسجيل الدخول'
                                : 'إنشاء الحساب',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),

                const SizedBox(height: 20),

                TextButton(
                  onPressed: isLoading
                      ? null
                      : () {
                          setState(() {
                            isLogin = !isLogin;
                          });
                        },
                  child: Text(
                    isLogin
                        ? 'ليس لديك حساب؟ إنشاء حساب'
                        : 'لديك حساب بالفعل؟ تسجيل الدخول',
                    style: const TextStyle(
                      fontSize: 16,
                      color: Color(0xFF102A4C),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                const Text(
                  'كلمة المرور يجب أن تكون 8 أحرف على الأقل.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13,
                    color: Color(0xFF8A97AD),
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
