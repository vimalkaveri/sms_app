import 'dart:async';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:telephony/telephony.dart';

class SMSController {
  final Telephony telephony = Telephony.instance;
  Timer? _responseTimeoutTimer;
  final ValueNotifier<bool> _responseReceived = ValueNotifier<bool>(false);
  String? _lastSentNumber;
  List<SmsMessage> receivedMessages = [];

  /// Request required permissions (SMS and Phone)
  Future<void> requestPermissions(BuildContext context) async {
    final statuses = await [
      Permission.sms,
      Permission.phone,
    ].request();

    if (!statuses[Permission.sms]!.isGranted || !statuses[Permission.phone]!.isGranted) {
      _showPopupStatusDialog(
        context,
        "Permission Error",
        "SMS & Phone permissions are required.",
      );
    }
  }

  /// Start listening for incoming SMS messages
  void startListeningForSMS(BuildContext context) {
    telephony.listenIncomingSms(
      onNewMessage: (SmsMessage message) {
        final sender = message.address?.replaceAll(RegExp(r'\D'), '');
        final expected = _lastSentNumber?.replaceAll(RegExp(r'\D'), '');

        if (!_responseReceived.value && sender != null && expected != null && sender.endsWith(expected)) {
          _responseReceived.value = true;
          _responseTimeoutTimer?.cancel();

          if (Navigator.canPop(context)) {
            Navigator.of(context).pop(); // Close loading dialog
          }

          receivedMessages.insert(0, message);
          _showPopupDialog(context, message);
        } else {
          receivedMessages.insert(0, message);
        }
      },
      listenInBackground: false,
    );
  }

  /// Send an SMS and wait for a response
  void sendSMS(BuildContext context, String phoneNumber, String message) async {
    if (phoneNumber.isEmpty || message.isEmpty) {
      _showPopupStatusDialog(
        context,
        'Validation Error',
        'Enter both phone number and message',
      );
      return;
    }

    final permission = await Permission.sms.status;
    if (!permission.isGranted) {
      final result = await Permission.sms.request();
      if (!result.isGranted) {
        _showPopupStatusDialog(context, 'Permission Denied', 'SMS permission not granted');
        return;
      }
    }

    _lastSentNumber = phoneNumber;
    _responseReceived.value = false;

    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const AlertDialog(
        content: Row(
          children: [
            CircularProgressIndicator(),
            SizedBox(width: 20),
            Text('Waiting for reply...'),
          ],
        ),
      ),
    );

    // Set timeout for response
    _responseTimeoutTimer = Timer(const Duration(seconds: 60), () {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!_responseReceived.value && Navigator.canPop(context)) {
          Navigator.of(context).pop(); // Close loading dialog
          _showPopupStatusDialog(context, 'No Response', 'Please try again later.');
        }
      });
    });

    try {
      await telephony.sendSms(to: phoneNumber, message: message);
    } catch (e) {
      if (Navigator.canPop(context)) {
        Navigator.of(context).pop(); // Close loading
      }
      _responseTimeoutTimer?.cancel();
      _showPopupStatusDialog(
        context,
        "Unsupported Android Version",
        "This feature is only available on Android 12 or above.",
      );
    }
  }

  /// Show a modern, styled popup for received SMS
  void _showPopupDialog(BuildContext context, SmsMessage message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          titlePadding: const EdgeInsets.all(20),
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),

          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (message.address != null) ...[
                const SizedBox(height: 12),
              ],
              const SizedBox(height: 5),
              Text(
                message.body ?? 'No Content',
                style: const TextStyle(fontSize: 16),
              ),
            ],
          ),
          actions: [
            TextButton(
              child: const Text('Close', style: TextStyle(color: Colors.blue)),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        );
      },
    );
  }

  /// Show a status dialog for errors or info
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

  /// Show snackbar for simple feedback
  void _showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}
