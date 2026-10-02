import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'home_screen.dart';
const String _googleWebClientId =
    '106036859936-2seqm33h1h9um8pl5dusdatjuc4lhljt.apps.googleusercontent.com';

class _GoogleAuth {
  static final GoogleSignIn _signIn = GoogleSignIn.instance;
  static Future<void>? _initializeFuture;

  static Future<void> initialize() {
    return _initializeFuture ??= _signIn.initialize(
      serverClientId: _googleWebClientId,
    );
  }

  static Future<AuthResponse> signIn() async {
    await initialize();

    final googleAccount = await _signIn.authenticate();

    final googleAuthentication = googleAccount.authentication;
    final idToken = googleAuthentication.idToken;

    if (idToken == null) {
      throw const AuthException('لم يتم الحصول على Google ID Token.');
    }

    return Supabase.instance.client.auth.signInWithIdToken(
      provider: OAuthProvider.google,
      idToken: idToken,
    );
  }
}

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
                  icon: SvgPicture.string(
                    '''
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 48 48">
  <path fill="#EA4335" d="M24 9.5c3.54 0 6.72 1.22 9.22 3.6l6.85-6.85C35.9 2.64 30.47 0 24 0 14.61 0 6.55 5.38 2.64 13.22l7.98 6.2C12.5 13.28 17.76 9.5 24 9.5z"/>
  <path fill="#4285F4" d="M46.5 24.5c0-1.6-.15-3.14-.42-4.63H24v9.05h12.65c-.55 2.91-2.19 5.38-4.67 7.03l7.53 5.84C43.9 37.64 46.5 31.56 46.5 24.5z"/>
  <path fill="#FBBC05" d="M10.62 28.58A14.48 14.48 0 0 1 9.5 24c0-1.59.4-3.12 1.12-4.58l-7.98-6.2A24 24 0 0 0 0 24c0 3.88.93 7.56 2.64 10.78l7.98-6.2z"/>
  <path fill="#34A853" d="M24 48c6.47 0 11.9-2.14 15.84-5.82l-7.53-5.84c-2.08 1.4-4.74 2.23-8.31 2.23-6.24 0-11.5-3.78-13.38-9.42l-7.98 6.2C6.55 42.62 14.61 48 24 48z"/>
</svg>
                    ''',
                    width: 30,
                    height: 30,
                  ),
                  text: 'متابعة باستخدام Google',
                  onTap: () async {
                    try {
                      await _GoogleAuth.signIn();

                      if (!context.mounted) return;

                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'تم تسجيل الدخول باستخدام Google بنجاح ✅',
                            textAlign: TextAlign.right,
                          ),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );

                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const HomeScreen(),
                        ),
                      );
                    } on GoogleSignInException catch (error) {
                      if (!context.mounted) return;

                      final String description =
                          error.description?.trim().isNotEmpty == true
                              ? error.description!.trim()
                              : 'لا توجد تفاصيل إضافية من Google.';

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          duration: const Duration(seconds: 8),
                          content: Text(
                            'تعذر تسجيل الدخول باستخدام Google\n'
                            'رمز الخطأ: ${error.code}\n'
                            'التفاصيل: $description',
                            textAlign: TextAlign.right,
                          ),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    } on AuthException catch (error) {
                      if (!context.mounted) return;

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            error.message,
                            textAlign: TextAlign.right,
                          ),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    } catch (error) {
                      if (!context.mounted) return;

                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'حدث خطأ أثناء تسجيل الدخول باستخدام Google. حاول مرة أخرى.',
                            textAlign: TextAlign.right,
                          ),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    }
                  },
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

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const HomeScreen(),
          ),
        );
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

          if (!mounted) return;

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => const HomeScreen(),
            ),
          );
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
