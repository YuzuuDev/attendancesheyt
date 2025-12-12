import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../services/auth_service.dart';
import 'sign_up_page.dart';
import 'home_page.dart';
import '../theme.dart';
import '../animated_background.dart';
import '../services/sound_effect_service.dart';

class SignInPage extends StatefulWidget {
  const SignInPage({super.key});
  @override
  State<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> with TickerProviderStateMixin {
  final AuthService auth = AuthService();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  bool loading = false;
  String? error;

  bool showWelcome = false;
  double welcomeOpacity = 0.0;

  @override
  Widget build(BuildContext context) {
    return AnimatedGradientBackground(
      child: GlobalTapRipple(
        child: Scaffold(
          backgroundColor: Colors.transparent,
          body: Stack(
            children: [
              Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 520),
                    child: AnimatedOpacity(
                      duration: const Duration(milliseconds: 500),
                      opacity: showWelcome ? 0.0 : 1.0,
                      child: Card(
                        color: const Color(0xFF0A1F2E),
                        elevation: 12,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'QuizBIT',
                                style: TextStyle(
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.primary,
                                  shadows: [
                                    Shadow(
                                      blurRadius: 12,
                                      color: AppTheme.primary.withOpacity(0.7),
                                      offset: const Offset(0, 0),
                                    )
                                  ],
                                ),
                              ),
                              const SizedBox(height: 24),
                              if (error != null)
                                Text(error!,
                                    style: const TextStyle(color: Colors.redAccent, fontSize: 14)),
                              _buildTextField(emailController, 'Email', keyboardType: TextInputType.emailAddress),
                              const SizedBox(height: 12),
                              _buildTextField(passwordController, 'Password', obscureText: true),
                              const SizedBox(height: 24),
                              loading
                                  ? const CircularProgressIndicator(color: AppTheme.primary)
                                  : _buildButton('Sign In & Play Quiz', _signIn),
                              const SizedBox(height: 12),
                              _buildButton('Create Account', _goToSignUp, isSecondary: true),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              if (showWelcome)
                AnimatedOpacity(
                  duration: const Duration(milliseconds: 1000),
                  opacity: welcomeOpacity,
                  child: Center(
                    child: Text(
                      'Welcome!',
                      style: TextStyle(
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        shadows: [
                          for (int i = 1; i <= 5; i++)
                            Shadow(
                              blurRadius: 8.0 * i,
                              color: Colors.white.withOpacity(0.15 * i),
                              offset: const Offset(0, 0),
                            )
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label,
      {bool obscureText = false, TextInputType keyboardType = TextInputType.text}) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white70),
        filled: true,
        fillColor: const Color(0xFF102A3A),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: AppTheme.primary.withOpacity(0.5)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: AppTheme.primary, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
    );
  }

  Widget _buildButton(String text, VoidCallback onTap, {bool isSecondary = false}) {
    return ScaleOnTap(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: isSecondary
              ? LinearGradient(
                  colors: [Colors.white.withOpacity(0.15), Colors.white.withOpacity(0.25)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : LinearGradient(
                  colors: [AppTheme.primary.withOpacity(0.8), AppTheme.primary],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: isSecondary
                  ? Colors.white.withOpacity(0.25)
                  : AppTheme.primary.withOpacity(0.6),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Center(
          child: Text(
            text,
            style: TextStyle(
              color: isSecondary ? Colors.white : Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 16,
              shadows: [
                Shadow(
                  blurRadius: 12,
                  color: Colors.white38,
                  offset: const Offset(0, 0),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _signIn() async {
    setState(() {
      loading = true;
      error = null;
    });
    try {
      await auth.signIn(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );
      Fluttertoast.showToast(msg: 'Signed in!');
      setState(() {
        showWelcome = true;
      });

      SoundEffectService().play('assets/audio/sfx/success.mp3');
      
      await Future.delayed(const Duration(milliseconds: 200));
      setState(() {
        welcomeOpacity = 1.0;
      });
      await Future.delayed(const Duration(seconds: 2));
      if (!mounted) return;
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (_) => const HomePage()));
    } catch (e) {
      setState(() {
        error = e.toString();
      });
    } finally {
      setState(() {
        loading = false;
      });
    }
  }

  void _goToSignUp() {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => const SignUpPage(),
        transitionsBuilder: (_, animation, __, child) {
          return FadeTransition(
            opacity: animation,
            child: ScaleTransition(scale: animation, child: child),
          );
        },
        transitionDuration: const Duration(milliseconds: 500),
      ),
    );
  }
}
