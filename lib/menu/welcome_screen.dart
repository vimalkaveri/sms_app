import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'device_manager_screen.dart';
import 'change_password_screen.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  final TextEditingController _passwordController = TextEditingController();

  bool _isPasswordVisible = false;
  bool _isLoggingIn = false;

  @override
  void initState() {
    super.initState();
    _initializePassword();
  }

  Future<void> _initializePassword() async {
    final prefs = await SharedPreferences.getInstance();
    final savedPassword = prefs.getString('app_password');

    if (savedPassword == null) {
      await prefs.setString('app_password', '1234');
    }
  }

  Future<void> _login() async {
    FocusScope.of(context).unfocus();

    final enteredPassword = _passwordController.text.trim();

    if (enteredPassword.isEmpty) {
      _showMessage('Please enter your password');
      return;
    }

    setState(() {
      _isLoggingIn = true;
    });

    final prefs = await SharedPreferences.getInstance();
    final savedPassword = prefs.getString('app_password') ?? '1234';

    await Future.delayed(const Duration(milliseconds: 400));

    if (!mounted) return;

    if (enteredPassword == savedPassword) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const DeviceManagerScreen()),
      );
    } else {
      setState(() {
        _isLoggingIn = false;
      });

      _showMessage('Incorrect password', isError: true);
    }
  }

  void _showMessage(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.fromLTRB(20, 0, 20, 20),
          backgroundColor:
              isError ? const Color(0xFFD32F2F) : const Color(0xFF1565C0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          content: Row(
            children: [
              Icon(
                isError
                    ? Icons.error_outline_rounded
                    : Icons.check_circle_outline_rounded,
                color: Colors.white,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  message,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
  }

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final backgroundColor =
        isDark ? const Color(0xFF07111C) : const Color(0xFFF3F7FC);

    final cardColor = isDark ? const Color(0xFF0E1B29) : Colors.white;

    final primaryColor =
        isDark ? const Color(0xFF42A5F5) : const Color(0xFF1565C0);

    final primaryLight =
        isDark ? const Color(0xFF90CAF9) : const Color(0xFF1976D2);

    final textColor = isDark ? Colors.white : const Color(0xFF172033);

    final secondaryText = isDark ? Colors.white60 : const Color(0xFF64748B);

    return Scaffold(
      backgroundColor: backgroundColor,
      body: Stack(
        children: [
          // ----------------------------------------------------------
          // BACKGROUND
          // ----------------------------------------------------------

          Positioned.fill(
            child: CustomPaint(painter: _GridPainter(isDark: isDark)),
          ),

          // Top blue background
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              height: 300,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors:
                      isDark
                          ? const [
                            Color(0xFF082C52),
                            Color(0xFF0D477A),
                            Color(0xFF07111C),
                          ]
                          : const [
                            Color(0xFF0D47A1),
                            Color(0xFF1976D2),
                            Color(0xFF42A5F5),
                          ],
                ),
              ),
            ),
          ),

          // Decorative circle
          Positioned(
            top: -120,
            right: -100,
            child: Container(
              width: 280,
              height: 280,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.05),
              ),
            ),
          ),

          Positioned(
            top: 120,
            left: -150,
            child: Container(
              width: 280,
              height: 280,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.035),
              ),
            ),
          ),

          // ----------------------------------------------------------
          // CONTENT
          // ----------------------------------------------------------
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 28,
                ),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 440),
                  child: Column(
                    children: [
                      // ------------------------------------------------
                      // BRAND
                      // ------------------------------------------------

                      _buildBrand(isDark: isDark, primaryColor: primaryColor),

                      const SizedBox(height: 44),

                      // ------------------------------------------------
                      // LOGIN CARD
                      // ------------------------------------------------
                      Container(
                        decoration: BoxDecoration(
                          color: cardColor,
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(
                            color:
                                isDark
                                    ? Colors.white.withOpacity(0.07)
                                    : const Color(0xFFE2E8F0),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(
                                isDark ? 0.30 : 0.08,
                              ),
                              blurRadius: 35,
                              offset: const Offset(0, 18),
                            ),
                          ],
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(26),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Header
                              Row(
                                children: [
                                  Container(
                                    width: 48,
                                    height: 48,
                                    decoration: BoxDecoration(
                                      color: primaryColor.withOpacity(0.10),
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                    child: Icon(
                                      Icons.lock_person_outlined,
                                      color: primaryColor,
                                      size: 25,
                                    ),
                                  ),
                                  const SizedBox(width: 14),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Secure Access',
                                          style: TextStyle(
                                            color: textColor,
                                            fontSize: 21,
                                            fontWeight: FontWeight.w700,
                                            letterSpacing: -0.3,
                                          ),
                                        ),
                                        const SizedBox(height: 3),
                                        Text(
                                          'Enter your password to continue',
                                          style: TextStyle(
                                            color: secondaryText,
                                            fontSize: 12.5,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 28),

                              // ------------------------------------------------
                              // PASSWORD LABEL
                              // ------------------------------------------------
                              Text(
                                'PASSWORD',
                                style: TextStyle(
                                  color: secondaryText,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 1.1,
                                ),
                              ),

                              const SizedBox(height: 9),

                              // ------------------------------------------------
                              // PASSWORD FIELD
                              // ------------------------------------------------
                              Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(14),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(
                                        isDark ? 0.08 : 0.025,
                                      ),
                                      blurRadius: 8,
                                      offset: const Offset(0, 3),
                                    ),
                                  ],
                                ),
                                child: TextField(
                                  controller: _passwordController,
                                  obscureText: !_isPasswordVisible,
                                  textInputAction: TextInputAction.done,
                                  onSubmitted: (_) => _login(),
                                  style: TextStyle(
                                    color: textColor,
                                    fontSize: 15,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  decoration: InputDecoration(
                                    hintText: 'Enter your password',
                                    hintStyle: TextStyle(
                                      color: secondaryText.withOpacity(0.65),
                                      fontSize: 14,
                                    ),
                                    prefixIcon: Icon(
                                      Icons.lock_outline_rounded,
                                      color: primaryColor,
                                      size: 21,
                                    ),
                                    suffixIcon: IconButton(
                                      tooltip:
                                          _isPasswordVisible
                                              ? 'Hide password'
                                              : 'Show password',
                                      onPressed: () {
                                        setState(() {
                                          _isPasswordVisible =
                                              !_isPasswordVisible;
                                        });
                                      },
                                      icon: Icon(
                                        _isPasswordVisible
                                            ? Icons.visibility_off_outlined
                                            : Icons.visibility_outlined,
                                        color: secondaryText,
                                        size: 21,
                                      ),
                                    ),
                                    filled: true,
                                    fillColor:
                                        isDark
                                            ? const Color(0xFF142536)
                                            : const Color(0xFFF7F9FC),
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 17,
                                    ),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(14),
                                      borderSide: BorderSide.none,
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(14),
                                      borderSide: BorderSide(
                                        color:
                                            isDark
                                                ? Colors.white.withOpacity(0.08)
                                                : const Color(0xFFE2E8F0),
                                      ),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(14),
                                      borderSide: BorderSide(
                                        color: primaryColor,
                                        width: 1.5,
                                      ),
                                    ),
                                  ),
                                ),
                              ),

                              const SizedBox(height: 20),

                              // ------------------------------------------------
                              // LOGIN BUTTON
                              // ------------------------------------------------
                              SizedBox(
                                width: double.infinity,
                                height: 54,
                                child: ElevatedButton(
                                  onPressed: _isLoggingIn ? null : _login,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: primaryColor,
                                    foregroundColor: Colors.white,
                                    disabledBackgroundColor: primaryColor
                                        .withOpacity(0.55),
                                    elevation: 0,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                  ),
                                  child: AnimatedSwitcher(
                                    duration: const Duration(milliseconds: 180),
                                    child:
                                        _isLoggingIn
                                            ? const SizedBox(
                                              key: ValueKey('loading'),
                                              width: 22,
                                              height: 22,
                                              child: CircularProgressIndicator(
                                                strokeWidth: 2.5,
                                                color: Colors.white,
                                              ),
                                            )
                                            : const Row(
                                              key: ValueKey('login'),
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Icon(
                                                  Icons.login_rounded,
                                                  size: 20,
                                                ),
                                                SizedBox(width: 9),
                                                Text(
                                                  'Sign In',
                                                  style: TextStyle(
                                                    fontSize: 15,
                                                    fontWeight: FontWeight.w700,
                                                  ),
                                                ),
                                              ],
                                            ),
                                  ),
                                ),
                              ),

                              const SizedBox(height: 14),

                              // ------------------------------------------------
                              // CHANGE PASSWORD
                              // ------------------------------------------------
                              Center(
                                child: TextButton.icon(
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder:
                                            (context) =>
                                                const ChangePasswordScreen(),
                                      ),
                                    );
                                  },
                                  icon: Icon(
                                    Icons.key_outlined,
                                    size: 17,
                                    color: primaryLight,
                                  ),
                                  label: Text(
                                    'Change Password',
                                    style: TextStyle(
                                      color: primaryLight,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      // ------------------------------------------------
                      // SECURITY STATUS
                      // ------------------------------------------------
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color:
                              isDark
                                  ? Colors.white.withOpacity(0.035)
                                  : Colors.white.withOpacity(0.75),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color:
                                isDark
                                    ? Colors.white.withOpacity(0.05)
                                    : const Color(0xFFE2E8F0),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                color: const Color(0xFF22C55E),
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(
                                      0xFF22C55E,
                                    ).withOpacity(0.4),
                                    blurRadius: 6,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 9),
                            Text(
                              'SYSTEM SECURE',
                              style: TextStyle(
                                color: secondaryText,
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 1,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 18),

                      // ------------------------------------------------
                      // FOOTER
                      // ------------------------------------------------
                      Text(
                        'G-Alert™',
                        style: TextStyle(
                          color: secondaryText.withOpacity(0.65),
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.8,
                        ),
                      ),

                      const SizedBox(height: 5),

                      Text(
                        'Secure • Simple • Reliable',
                        style: TextStyle(
                          color: secondaryText.withOpacity(0.5),
                          fontSize: 10,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ================================================================
  // BRAND
  // ================================================================

  Widget _buildBrand({required bool isDark, required Color primaryColor}) {
    return Column(
      children: [
        // Logo
        Container(
          width: 82,
          height: 82,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.18),
                blurRadius: 25,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: 58,
                height: 58,
                decoration: BoxDecoration(
                  color: primaryColor.withOpacity(0.09),
                  shape: BoxShape.circle,
                ),
              ),
              Icon(Icons.shield_rounded, size: 43, color: primaryColor),

            ],
          ),
        ),

        const SizedBox(height: 18),

        // Application name
        const Text(
          'G-Alert™',
          style: TextStyle(
            color: Colors.white,
            fontSize: 29,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.1,
          ),
        ),

        const SizedBox(height: 5),

        Text(
          'SECURE DEVICE MANAGEMENT',
          style: TextStyle(
            color: Colors.white.withOpacity(0.78),
            fontSize: 10.5,
            fontWeight: FontWeight.w600,
            letterSpacing: 1.5,
          ),
        ),

        const SizedBox(height: 14),

        // Small status
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.10),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withOpacity(0.10)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(width: 7),
              Text(
                '',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.85),
                  fontSize: 9,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ================================================================
// BACKGROUND GRID
// ================================================================

class _GridPainter extends CustomPainter {
  final bool isDark;

  _GridPainter({required this.isDark});

  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color =
              isDark
                  ? Colors.white.withOpacity(0.018)
                  : Colors.blue.withOpacity(0.025)
          ..strokeWidth = 1;

    const spacing = 32.0;

    for (double x = 0; x < size.width; x += spacing) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }

    for (double y = 0; y < size.height; y += spacing) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant _GridPainter oldDelegate) {
    return oldDelegate.isDark != isDark;
  }
}
