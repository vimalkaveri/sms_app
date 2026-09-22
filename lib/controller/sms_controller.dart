import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

/// Opens the phone's native SMS app with the number and message
/// pre-filled; the user reviews and taps Send themselves.
///
/// This intentionally does NOT send SMS directly/silently. Google Play's
/// restricted-permissions policy only allows SEND_SMS/RECEIVE_SMS for
/// apps registered as the device's default SMS handler — not viable for
/// a device-config utility. Using the OS's own compose screen needs no
/// SMS permission at all and is fully Play Store compliant.
///
/// Public method names/signatures are kept the same as the old
/// telephony-based controller so existing call sites don't need to
/// change: requestPermissions() and startListeningForSMS() are now
/// no-ops kept only so old call sites keep compiling; feel free to
/// delete those calls from each page when convenient.
class SMSController {
  /// No longer needed (no SMS permission required for compose-screen
  /// sending). Kept as a no-op so existing initState() calls don't
  /// break; safe to delete the call sites over time.
  Future<void> requestPermissions(BuildContext context) async {}

  /// No longer possible without RECEIVE_SMS/READ_SMS, which Play Store
  /// restricts the same way. Kept as a no-op so existing initState()
  /// calls don't break; safe to delete the call sites over time.
  void startListeningForSMS(BuildContext context) {}

  /// Opens the SMS compose screen pre-filled with [message] addressed
  /// to [phoneNumber]. The user must tap Send in their SMS app.
  Future<void> sendSMS(
    BuildContext context,
    String phoneNumber,
    String message,
  ) async {
    if (phoneNumber.isEmpty || message.isEmpty) {
      _showPopupStatusDialog(
        context,
        'Validation Error',
        'Enter both phone number and message',
      );
      return;
    }

    final uri = Uri(
      scheme: 'sms',
      path: phoneNumber,
      queryParameters: {'body': message},
    );

    try {
      final opened = await canLaunchUrl(uri) && await launchUrl(uri);
      if (!opened) {
        _showPopupStatusDialog(
          context,
          'Could Not Open Messages',
          'No SMS app was found to send this command.',
        );
      }
    } catch (e) {
      _showPopupStatusDialog(context, 'Error', 'Failed to open SMS app.');
    }
  }

  void _showPopupStatusDialog(BuildContext context, String title, String content) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          title: Text(title),
          content: Text(content),
          actions: [
            TextButton(
              child: const Text('OK'),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        );
      },
    );
  }
}
