import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final TextEditingController _oldPasswordController = TextEditingController();

  final TextEditingController _newPasswordController = TextEditingController();

  final TextEditingController _confirmPasswordController =
  TextEditingController();

  bool _showOldPassword = false;
  bool _showNewPassword = false;
  bool _showConfirmPassword = false;

  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    // FIX: without this listener, the "password requirements" checklist
    // only reflects live typing when *something else* happens to call
    // setState (e.g. tapping the visibility-toggle icon). Attaching the
    // listener here makes it rebuild on every keystroke, as intended.
    _newPasswordController.addListener(_onNewPasswordChanged);
  }

  void _onNewPasswordChanged() {
    setState(() {});
  }

  // ================================================================
  // CHANGE PASSWORD
  // ================================================================

  Future<void> _changePassword() async {
    FocusScope.of(context).unfocus();

    final oldPassword = _oldPasswordController.text.trim();
    final newPassword = _newPasswordController.text.trim();
    final confirmPassword = _confirmPasswordController.text.trim();

    // --------------------------------------------------------------
    // Validation
    // --------------------------------------------------------------

    if (oldPassword.isEmpty) {
      _showMessage('Please enter your current password', isError: true);
      return;
    }

    if (newPassword.isEmpty) {
      _showMessage('Please enter a new password', isError: true);
      return;
    }

    if (newPassword.length < 4) {
      _showMessage(
        'New password must contain at least 4 characters',
        isError: true,
      );
      return;
    }

    if (confirmPassword.isEmpty) {
      _showMessage('Please confirm your new password', isError: true);
      return;
    }

    if (newPassword != confirmPassword) {
      _showMessage('New passwords do not match', isError: true);
      return;
    }

    if (oldPassword == newPassword) {
      _showMessage(
        'New password must be different from old password',
        isError: true,
      );
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      final prefs = await SharedPreferences.getInstance();

      final storedPassword = prefs.getString('app_password') ?? '1234';

      // ------------------------------------------------------------
      // Verify old password
      // ------------------------------------------------------------

      if (oldPassword != storedPassword) {
        if (!mounted) return;

        setState(() {
          _isSaving = false;
        });

        _showMessage('Current password is incorrect', isError: true);

        return;
      }

      // ------------------------------------------------------------
      // Save new password
      // ------------------------------------------------------------

      await prefs.setString('app_password', newPassword);

      if (!mounted) return;

      setState(() {
        _isSaving = false;
      });

      _showMessage('Password changed successfully');

      _oldPasswordController.clear();
      _newPasswordController.clear();
      _confirmPasswordController.clear();

      // Give the success message a moment to display.
      await Future.delayed(const Duration(milliseconds: 700));

      if (!mounted) return;

      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isSaving = false;
      });

      _showMessage('Unable to change password', isError: true);
    }
  }

  // ================================================================
  // MESSAGE
  // ================================================================

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
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
  }

  // ================================================================
  // PASSWORD FIELD
  // ================================================================

  Widget _passwordField({
    required String label,
    required String hint,
    required TextEditingController controller,
    required bool obscureText,
    required VoidCallback onToggle,
    required bool isDark,
    required Color primaryColor,
    required Color secondaryText,
    required Color textColor,
    required IconData icon,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      textInputAction: TextInputAction.next,
      style: TextStyle(
        color: textColor,
        fontSize: 14.5,
        fontWeight: FontWeight.w500,
      ),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        labelStyle: TextStyle(color: secondaryText, fontSize: 13),
        hintStyle: TextStyle(
          color: secondaryText.withOpacity(0.55),
          fontSize: 13,
        ),
        prefixIcon: Icon(icon, color: primaryColor, size: 21),
        suffixIcon: IconButton(
          tooltip: obscureText ? 'Show password' : 'Hide password',
          onPressed: onToggle,
          icon: Icon(
            obscureText
                ? Icons.visibility_outlined
                : Icons.visibility_off_outlined,
            color: secondaryText,
            size: 20,
          ),
        ),
        filled: true,
        fillColor: isDark ? const Color(0xFF142536) : const Color(0xFFF7F9FC),
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
                ? Colors.white.withOpacity(0.07)
                : const Color(0xFFE2E8F0),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: primaryColor, width: 1.5),
        ),
      ),
    );
  }

  // ================================================================
  // PASSWORD REQUIREMENTS
  // ================================================================

  Widget _passwordRequirements({
    required bool isDark,
    required Color secondaryText,
  }) {
    final password = _newPasswordController.text.trim();

    final hasLength = password.length >= 4;
    final hasNumber = password.contains(RegExp(r'[0-9]'));

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color:
        isDark ? Colors.white.withOpacity(0.035) : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color:
          isDark ? Colors.white.withOpacity(0.06) : const Color(0xFFE2E8F0),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'PASSWORD REQUIREMENTS',
            style: TextStyle(
              color: secondaryText,
              fontSize: 9.5,
              fontWeight: FontWeight.w700,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 9),
          _requirementRow('At least 4 characters', hasLength, isDark),
          const SizedBox(height: 5),
          _requirementRow('Use at least one number', hasNumber, isDark),
        ],
      ),
    );
  }

  Widget _requirementRow(String text, bool valid, bool isDark) {
    return Row(
      children: [
        Icon(
          valid ? Icons.check_circle_rounded : Icons.circle_outlined,
          size: 15,
          color:
          valid
              ? const Color(0xFF22C55E)
              : (isDark ? Colors.white38 : Colors.blueGrey.shade300),
        ),
        const SizedBox(width: 7),
        Text(
          text,
          style: TextStyle(
            color: isDark ? Colors.white54 : const Color(0xFF64748B),
            fontSize: 11,
          ),
        ),
      ],
    );
  }

  // ================================================================
  // DISPOSE
  // ================================================================

  @override
  void dispose() {
    _newPasswordController.removeListener(_onNewPasswordChanged);
    _oldPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();

    super.dispose();
  }

  // ================================================================
  // BUILD
  // ================================================================

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final backgroundColor =
    isDark ? const Color(0xFF07111C) : const Color(0xFFF3F7FC);

    final cardColor = isDark ? const Color(0xFF0E1B29) : Colors.white;

    final primaryColor =
    isDark ? const Color(0xFF42A5F5) : const Color(0xFF1565C0);

    final textColor = isDark ? Colors.white : const Color(0xFF172033);

    final secondaryText = isDark ? Colors.white60 : const Color(0xFF64748B);

    return Scaffold(
      backgroundColor: backgroundColor,

      // ------------------------------------------------------------
      // APP BAR
      // ------------------------------------------------------------
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          tooltip: 'Back',
          onPressed: () => Navigator.pop(context),
          icon: Icon(Icons.arrow_back_rounded, color: textColor),
        ),
        title: Text(
          'Change Password',
          style: TextStyle(
            color: textColor,
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),

      // ------------------------------------------------------------
      // BODY
      // ------------------------------------------------------------
      body: Stack(
        children: [
          // Background decoration
          Positioned(
            top: -100,
            right: -100,
            child: Container(
              width: 260,
              height: 260,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: primaryColor.withOpacity(0.035),
              ),
            ),
          ),

          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 20, 24, 30),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 440),
                  child: Column(
                    children: [
                      // ------------------------------------------------
                      // SECURITY ICON
                      // ------------------------------------------------

                      Container(
                        width: 76,
                        height: 76,
                        decoration: BoxDecoration(
                          color: primaryColor.withOpacity(0.09),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.lock_reset_rounded,
                          size: 38,
                          color: primaryColor,
                        ),
                      ),

                      const SizedBox(height: 18),

                      Text(
                        'Update Password',
                        style: TextStyle(
                          color: textColor,
                          fontSize: 25,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.5,
                        ),
                      ),

                      const SizedBox(height: 6),

                      Text(
                        'Keep your G-Alert account secure',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: secondaryText, fontSize: 13),
                      ),

                      const SizedBox(height: 30),

                      // ------------------------------------------------
                      // CARD
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
                                isDark ? 0.28 : 0.07,
                              ),
                              blurRadius: 30,
                              offset: const Offset(0, 15),
                            ),
                          ],
                        ),
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // ------------------------------------------------
                            // CURRENT PASSWORD
                            // ------------------------------------------------

                            Text(
                              'CURRENT PASSWORD',
                              style: TextStyle(
                                color: secondaryText,
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 1,
                              ),
                            ),

                            const SizedBox(height: 9),

                            _passwordField(
                              label: 'Current Password',
                              hint: 'Enter current password',
                              controller: _oldPasswordController,
                              obscureText: !_showOldPassword,
                              onToggle: () {
                                setState(() {
                                  _showOldPassword = !_showOldPassword;
                                });
                              },
                              isDark: isDark,
                              primaryColor: primaryColor,
                              secondaryText: secondaryText,
                              textColor: textColor,
                              icon: Icons.lock_outline_rounded,
                            ),

                            const SizedBox(height: 24),

                            // ------------------------------------------------
                            // NEW PASSWORD
                            // ------------------------------------------------
                            Text(
                              'NEW PASSWORD',
                              style: TextStyle(
                                color: secondaryText,
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 1,
                              ),
                            ),

                            const SizedBox(height: 9),

                            _passwordField(
                              label: 'New Password',
                              hint: 'Enter new password',
                              controller: _newPasswordController,
                              obscureText: !_showNewPassword,
                              onToggle: () {
                                setState(() {
                                  _showNewPassword = !_showNewPassword;
                                });
                              },
                              isDark: isDark,
                              primaryColor: primaryColor,
                              secondaryText: secondaryText,
                              textColor: textColor,
                              icon: Icons.lock_reset_outlined,
                            ),

                            const SizedBox(height: 12),

                            // Password requirements
                            _passwordRequirements(
                              isDark: isDark,
                              secondaryText: secondaryText,
                            ),

                            const SizedBox(height: 20),

                            // ------------------------------------------------
                            // CONFIRM PASSWORD
                            // ------------------------------------------------
                            Text(
                              'CONFIRM PASSWORD',
                              style: TextStyle(
                                color: secondaryText,
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 1,
                              ),
                            ),

                            const SizedBox(height: 9),

                            _passwordField(
                              label: 'Confirm Password',
                              hint: 'Re-enter new password',
                              controller: _confirmPasswordController,
                              obscureText: !_showConfirmPassword,
                              onToggle: () {
                                setState(() {
                                  _showConfirmPassword = !_showConfirmPassword;
                                });
                              },
                              isDark: isDark,
                              primaryColor: primaryColor,
                              secondaryText: secondaryText,
                              textColor: textColor,
                              icon: Icons.verified_user_outlined,
                            ),

                            const SizedBox(height: 26),

                            // ------------------------------------------------
                            // SAVE BUTTON
                            // ------------------------------------------------
                            SizedBox(
                              width: double.infinity,
                              height: 54,
                              child: ElevatedButton(
                                onPressed: _isSaving ? null : _changePassword,
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
                                  _isSaving
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
                                    key: ValueKey('save'),
                                    mainAxisAlignment:
                                    MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.save_rounded,
                                        size: 20,
                                      ),
                                      SizedBox(width: 9),
                                      Text(
                                        'Update Password',
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

                            const SizedBox(height: 10),

                            // ------------------------------------------------
                            // CANCEL
                            // ------------------------------------------------
                            SizedBox(
                              width: double.infinity,
                              height: 45,
                              child: TextButton(
                                onPressed:
                                _isSaving
                                    ? null
                                    : () => Navigator.pop(context),
                                child: Text(
                                  'Cancel',
                                  style: TextStyle(
                                    color: secondaryText,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 22),

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
                              : Colors.white,
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
                            const Icon(
                              Icons.verified_user_rounded,
                              size: 16,
                              color: Color(0xFF22C55E),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'PASSWORD SECURITY',
                              style: TextStyle(
                                color: secondaryText,
                                fontSize: 9.5,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 1,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 14),

                      Text(
                        'G-Alert™',
                        style: TextStyle(
                          color: secondaryText.withOpacity(0.55),
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.8,
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
}