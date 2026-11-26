import 'package:flutter/material.dart';
import 'package:my_app/pages/home.dart';
import 'package:my_app/pages/register.dart';
import 'package:my_app/services/api.dart';
import 'package:my_app/widget/social_login_button.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  bool rememberMe = true;
  bool obscurePassword = true;
  bool isLoading = false;

  final Color primaryColor = const Color(0xFF064E3B);
  final Color accentColor = const Color(0xFFE98B20);
  final Color backgroundColor = const Color(0xFFF2F0E5);

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<void> submitLogin() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() => isLoading = true);
    try {
      await ApiService.login(
        email: emailController.text.trim(),
        password: passwordController.text,
      );
      if (!mounted) return;

      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute<void>(builder: (_) => const HomePage()),
        (_) => false,
      );
    } on Exception catch (error) {
      if (!mounted) return;
      final message = error.toString().replaceFirst('Exception: ', '');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
      );
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        bottom: false,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isShortScreen = constraints.maxHeight < 700;
            final headerHeight = isShortScreen ? 170.0 : 260.0;

            return Column(
              children: [
                SizedBox(
                  height: headerHeight,
                  width: double.infinity,
                  child: Stack(
                    children: [
                      Positioned(
                        top: isShortScreen ? 18 : 45,
                        left: 0,
                        right: 0,
                        child: RichText(
                          textAlign: TextAlign.center,
                          text: TextSpan(
                            style: const TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                            ),
                            children: [
                              TextSpan(
                                text: 'gr',
                                style: TextStyle(color: accentColor),
                              ),
                              TextSpan(
                                text: 'ocery',
                                style: TextStyle(color: primaryColor),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Positioned(
                        right: 25,
                        bottom: isShortScreen ? 12 : 35,
                        child: Icon(
                          Icons.shopping_basket,
                          size: isShortScreen ? 82 : 110,
                          color: accentColor,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Container(
                    width: double.infinity,
                    decoration: const BoxDecoration(
                      color: Color(0xFFFAFAFA),
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(28),
                      ),
                    ),
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(22, 25, 22, 24),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            const Text(
                              'Sign in Your Account',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 21,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF444444),
                              ),
                            ),
                            const SizedBox(height: 25),
                            TextFormField(
                              controller: emailController,
                              keyboardType: TextInputType.emailAddress,
                              textInputAction: TextInputAction.next,
                              decoration: inputDecoration(
                                'Enter Your Email',
                                Icons.email,
                              ),
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Email tidak boleh kosong';
                                }
                                if (!value.contains('@')) {
                                  return 'Format email tidak valid';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 14),
                            TextFormField(
                              controller: passwordController,
                              obscureText: obscurePassword,
                              textInputAction: TextInputAction.done,
                              onFieldSubmitted: (_) => submitLogin(),
                              decoration:
                                  inputDecoration(
                                    'Enter Your Password',
                                    Icons.lock,
                                  ).copyWith(
                                    suffixIcon: IconButton(
                                      icon: Icon(
                                        obscurePassword
                                            ? Icons.visibility_off
                                            : Icons.visibility,
                                      ),
                                      onPressed: () {
                                        setState(() {
                                          obscurePassword = !obscurePassword;
                                        });
                                      },
                                    ),
                                  ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Password tidak boleh kosong';
                                }
                                if (value.length < 6) {
                                  return 'Password minimal 6 karakter';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 12),
                            LayoutBuilder(
                              builder: (context, optionConstraints) {
                                if (optionConstraints.maxWidth < 330) {
                                  return Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Checkbox(
                                            value: rememberMe,
                                            activeColor: primaryColor,
                                            onChanged: (value) {
                                              setState(() {
                                                rememberMe = value ?? false;
                                              });
                                            },
                                          ),
                                          const Text(
                                            'Remember me',
                                            style: TextStyle(fontSize: 13),
                                          ),
                                        ],
                                      ),
                                      forgotPasswordButton(),
                                    ],
                                  );
                                }

                                return Row(
                                  children: [
                                    Checkbox(
                                      value: rememberMe,
                                      activeColor: primaryColor,
                                      onChanged: (value) {
                                        setState(() {
                                          rememberMe = value ?? false;
                                        });
                                      },
                                    ),
                                    const Text(
                                      'Remember me',
                                      style: TextStyle(fontSize: 13),
                                    ),
                                    const Spacer(),
                                    forgotPasswordButton(),
                                  ],
                                );
                              },
                            ),
                            const SizedBox(height: 8),
                            SizedBox(
                              height: 46,
                              child: ElevatedButton(
                                onPressed: isLoading ? null : submitLogin,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: primaryColor,
                                  foregroundColor: Colors.white,
                                  disabledBackgroundColor: primaryColor
                                      .withValues(alpha: 0.65),
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: isLoading
                                    ? const SizedBox(
                                        width: 22,
                                        height: 22,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: Colors.white,
                                        ),
                                      )
                                    : const Text(
                                        'Sign In',
                                        style: TextStyle(
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                              ),
                            ),
                            const SizedBox(height: 18),
                            const Text(
                              'Atau login dengan',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 13,
                              ),
                            ),
                            const SizedBox(height: 15),
                            LayoutBuilder(
                              builder: (context, socialConstraints) {
                                final googleButton = SocialLoginButton(
                                  label: 'Google',
                                  assetPath: 'assets/google assets.jpg',
                                  onPressed: isLoading
                                      ? null
                                      : () => _showSocialLoginMessage('Google'),
                                );
                                final facebookButton = SocialLoginButton(
                                  label: 'Facebook',
                                  assetPath: 'assets/facebook assets.png',
                                  onPressed: isLoading
                                      ? null
                                      : () =>
                                            _showSocialLoginMessage('Facebook'),
                                );

                                if (socialConstraints.maxWidth < 340) {
                                  return Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.stretch,
                                    children: [
                                      googleButton,
                                      const SizedBox(height: 10),
                                      facebookButton,
                                    ],
                                  );
                                }

                                return Row(
                                  children: [
                                    Expanded(child: googleButton),
                                    const SizedBox(width: 12),
                                    Expanded(child: facebookButton),
                                  ],
                                );
                              },
                            ),
                            const SizedBox(height: 20),
                            const Divider(),
                            const SizedBox(height: 12),
                            Wrap(
                              alignment: WrapAlignment.center,
                              crossAxisAlignment: WrapCrossAlignment.center,
                              children: [
                                const Text(
                                  "Don't have an account? ",
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.grey,
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () {
                                    Navigator.of(context).push(
                                      MaterialPageRoute<void>(
                                        builder: (_) => const RegisterPage(),
                                      ),
                                    );
                                  },
                                  child: Text(
                                    'Sign Up',
                                    style: TextStyle(
                                      color: accentColor,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 13,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  void _showSocialLoginMessage(String provider) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Login $provider belum tersedia'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Widget forgotPasswordButton() {
    return TextButton(
      onPressed: () {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Fitur lupa password belum tersedia'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      },
      child: Text(
        'Forgot Password?',
        style: TextStyle(color: accentColor, fontSize: 13),
      ),
    );
  }

  InputDecoration inputDecoration(String hint, IconData icon) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Colors.grey, fontSize: 13),
      prefixIcon: Icon(icon, color: const Color(0xFF064E3B), size: 19),
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(vertical: 15),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFEEEEEE)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF064E3B)),
      ),
    );
  }
}
