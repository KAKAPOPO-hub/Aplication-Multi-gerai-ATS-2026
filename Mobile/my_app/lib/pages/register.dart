import 'package:flutter/material.dart';
import 'package:my_app/pages/home.dart';
import 'package:my_app/services/api.dart';
import 'package:my_app/widget/social_login_button.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final formKey = GlobalKey<FormState>();
  final usernameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  bool obscurePassword = true;
  bool obscureConfirmation = true;
  bool isLoading = false;

  final Color primaryColor = const Color(0xFF064E3B);
  final Color accentColor = const Color(0xFFE98B20);
  final Color backgroundColor = const Color(0xFFF2F0E5);

  @override
  void dispose() {
    usernameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> submitRegister() async {
    if (!(formKey.currentState?.validate() ?? false)) return;

    setState(() => isLoading = true);
    var registrationSucceeded = false;
    try {
      final response = await ApiService.post('/auth/register', {
        'username': usernameController.text.trim(),
        'email': emailController.text.trim(),
        'password': passwordController.text,
      });

      if (response is! Map<String, dynamic> || response['success'] != true) {
        final message = response is Map<String, dynamic>
            ? response['message']
            : null;
        throw Exception(message is String ? message : 'Pendaftaran gagal');
      }

      registrationSucceeded = true;
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
      final detail = error.toString().replaceFirst('Exception: ', '');
      final message = registrationSucceeded ? 'Pendaftaran berhasil' : detail;
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
            final headerHeight = isShortScreen ? 150.0 : 220.0;

            return Column(
              children: [
                SizedBox(
                  height: headerHeight,
                  width: double.infinity,
                  child: Stack(
                    children: [
                      Positioned(
                        top: 10,
                        left: 8,
                        child: IconButton(
                          onPressed: () => Navigator.of(context).pop(),
                          icon: const Icon(Icons.arrow_back),
                          color: primaryColor,
                          tooltip: 'Kembali',
                        ),
                      ),
                      Positioned(
                        top: isShortScreen ? 18 : 38,
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
                        bottom: isShortScreen ? 8 : 25,
                        child: Icon(
                          Icons.person_add_alt_1,
                          size: isShortScreen ? 76 : 96,
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
                        key: formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            const Text(
                              'Create Your Account',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 21,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF444444),
                              ),
                            ),
                            const SizedBox(height: 22),
                            TextFormField(
                              controller: usernameController,
                              textInputAction: TextInputAction.next,
                              decoration: inputDecoration(
                                'Enter Your Username',
                                Icons.person_outline,
                              ),
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Username tidak boleh kosong';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 14),
                            TextFormField(
                              controller: emailController,
                              keyboardType: TextInputType.emailAddress,
                              textInputAction: TextInputAction.next,
                              decoration: inputDecoration(
                                'Enter Your Email',
                                Icons.email_outlined,
                              ),
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Email tidak boleh kosong';
                                }
                                if (!value.contains('@')) {
                                  return 'Masukkan email yang valid';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 14),
                            TextFormField(
                              controller: passwordController,
                              obscureText: obscurePassword,
                              textInputAction: TextInputAction.next,
                              decoration:
                                  inputDecoration(
                                    'Enter Your Password',
                                    Icons.lock_outline,
                                  ).copyWith(
                                    suffixIcon: IconButton(
                                      onPressed: () {
                                        setState(() {
                                          obscurePassword = !obscurePassword;
                                        });
                                      },
                                      icon: Icon(
                                        obscurePassword
                                            ? Icons.visibility_off
                                            : Icons.visibility,
                                      ),
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
                            const SizedBox(height: 14),
                            TextFormField(
                              controller: confirmPasswordController,
                              obscureText: obscureConfirmation,
                              textInputAction: TextInputAction.done,
                              onFieldSubmitted: (_) => submitRegister(),
                              decoration:
                                  inputDecoration(
                                    'Confirm Your Password',
                                    Icons.lock_reset_outlined,
                                  ).copyWith(
                                    suffixIcon: IconButton(
                                      onPressed: () {
                                        setState(() {
                                          obscureConfirmation =
                                              !obscureConfirmation;
                                        });
                                      },
                                      icon: Icon(
                                        obscureConfirmation
                                            ? Icons.visibility_off
                                            : Icons.visibility,
                                      ),
                                    ),
                                  ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Konfirmasi password tidak boleh kosong';
                                }
                                if (value != passwordController.text) {
                                  return 'Password tidak sama';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 22),
                            SizedBox(
                              height: 46,
                              child: ElevatedButton(
                                onPressed: isLoading ? null : submitRegister,
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
                                        'Daftar',
                                        style: TextStyle(
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                              ),
                            ),
                            const SizedBox(height: 14),
                            const Text(
                              'Atau daftar dengan',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 13,
                              ),
                            ),
                            const SizedBox(height: 12),
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
                            const Divider(),
                            const SizedBox(height: 8),
                            Wrap(
                              alignment: WrapAlignment.center,
                              crossAxisAlignment: WrapCrossAlignment.center,
                              children: [
                                const Text(
                                  'Sudah punya akun? ',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.grey,
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () => Navigator.of(context).pop(),
                                  child: Text(
                                    'Sign In',
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

  InputDecoration inputDecoration(String hint, IconData icon) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Colors.grey, fontSize: 13),
      prefixIcon: Icon(icon, color: primaryColor, size: 19),
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
        borderSide: BorderSide(color: primaryColor),
      ),
    );
  }
}
