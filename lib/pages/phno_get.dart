import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:telephony/telephony.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PhoneNumberGet extends StatefulWidget {
  final String phoneNumber;

  const PhoneNumberGet({required this.phoneNumber, Key? key}) : super(key: key);

  @override
  State<PhoneNumberGet> createState() => _PhoneNumberGetState();
}

class _PhoneNumberGetState extends State<PhoneNumberGet> {
  final Telephony _telephony = Telephony.instance;
  final TextEditingController _phoneController = TextEditingController();
  final ValueNotifier<Map<String, dynamic>> _latestMessage = ValueNotifier({
    'message': {},
    'timestamp': 0,
  });
  final ValueNotifier<bool> _responseReceived = ValueNotifier(false);

  Timer? _timeoutTimer;
  String? _lastSentNumber;

  @override
  void initState() {
    super.initState();
    _phoneController.text = widget.phoneNumber;
    _requestPermissions();
    _listenToIncomingSMS();
    _loadLatestMessage();
  }

  Future<void> _requestPermissions() async {
    final statuses = await [
      Permission.sms,
      Permission.phone,
    ].request();

    if (!statuses[Permission.sms]!.isGranted || !statuses[Permission.phone]!.isGranted) {
      _showDialog("Permission Error", "SMS & Phone permissions are required.");
    }
  }

  void _listenToIncomingSMS() {
    _telephony.listenIncomingSms(
      onNewMessage: (SmsMessage message) {
        final sender = message.address?.replaceAll(RegExp(r'\D'), '');
        final expected = _lastSentNumber?.replaceAll(RegExp(r'\D'), '');

        if (!_responseReceived.value &&
            sender != null &&
            expected != null &&
            sender.endsWith(expected)) {
          _responseReceived.value = true;
          _timeoutTimer?.cancel();
          if (Navigator.canPop(context)) Navigator.of(context).pop();
        }

        final body = message.body?.trim() ?? '';

        // Handle PR-M1 message
        if (body.startsWith("PR-M1:")) {
          final content = body.replaceFirst("PR-M1:", "").trim();
          final lines = content.split('\n').map((e) => e.trim()).toList();

          Map<String, String> m1Params = {};
          for (var line in lines) {
            if (line.startsWith("P1-")) {
              m1Params['P1'] = line.replaceFirst("P1-", "").trim();
            } else if (line.startsWith("P2-")) {
              m1Params['P2'] = line.replaceFirst("P2-", "").trim();
            } else if (line.startsWith("P3-")) {
              m1Params['P3'] = line.replaceFirst("P3-", "").trim();
            } else if (line.startsWith("P4-")) {
              m1Params['P4'] = line.replaceFirst("P4-", "").trim();
            } else if (line.startsWith("P5-")) {
              m1Params['P5'] = line.replaceFirst("P5-", "").trim();
            } else if (line.startsWith("P6-")) {
              m1Params['P6'] = line.replaceFirst("P6-", "").trim();
            } else if (line.startsWith("P7-")) {
              m1Params['P7'] = line.replaceFirst("P7-", "").trim();
            } else if (line.startsWith("P8-")) {
              m1Params['P8'] = line.replaceFirst("P8-", "").trim();
            } else if (line.startsWith("P9-")) {
              m1Params['P9'] = line.replaceFirst("P9-", "").trim();
            } else if (line.startsWith("P10-")) {
              m1Params['P10'] = line.replaceFirst("P10-", "").trim();
            }
          }

          final structuredMessageM1 = {
            'PR-M1': m1Params,
          };

          final timestamp = message.date ?? DateTime.now().millisecondsSinceEpoch;

          // Update ValueNotifier with new message data for PR-M1
          _latestMessage.value = {
            'message': structuredMessageM1,
            'timestamp': timestamp,
          };

          _saveLatestMessage(jsonEncode(structuredMessageM1), timestamp);
        }

        // Handle PR-M2 message
        if (body.startsWith("PR-M2:")) {
          final content = body.replaceFirst("PR-M2:", "").trim();
          final lines = content.split('\n').map((e) => e.trim()).toList();

          Map<String, String> m2Params = {};
          for (var line in lines) {
            if (line.startsWith("P11-")) {
              m2Params['P11'] = line.replaceFirst("P11-", "").trim();
            } else if (line.startsWith("P12-")) {
              m2Params['P12'] = line.replaceFirst("P12-", "").trim();
            } else if (line.startsWith("P13-")) {
              m2Params['P13'] = line.replaceFirst("P13-", "").trim();
            } else if (line.startsWith("P14-")) {
              m2Params['P14'] = line.replaceFirst("P14-", "").trim();
            } else if (line.startsWith("P15-")) {
              m2Params['P15'] = line.replaceFirst("P15-", "").trim();
            } else if (line.startsWith("P16-")) {
              m2Params['P16'] = line.replaceFirst("P16-", "").trim();
            } else if (line.startsWith("P17-")) {
              m2Params['P17'] = line.replaceFirst("P17-", "").trim();
            } else if (line.startsWith("P18-")) {
              m2Params['P18'] = line.replaceFirst("P18-", "").trim();
            } else if (line.startsWith("P19-")) {
              m2Params['P19'] = line.replaceFirst("P19-", "").trim();
            } else if (line.startsWith("P20-")) {
              m2Params['P20'] = line.replaceFirst("P20-", "").trim();
            }
          }

          final structuredMessageM2 = {
            'PR-M2': m2Params,
          };

          final timestamp = message.date ?? DateTime.now().millisecondsSinceEpoch;

          // Update ValueNotifier with new message data for PR-M2
          _latestMessage.value = {
            'message': structuredMessageM2,
            'timestamp': timestamp,
          };

          _saveLatestMessage(jsonEncode(structuredMessageM2), timestamp);
        }
      },
      listenInBackground: false,
    );
  }

  Future<void> _saveLatestMessage(String message, int timestamp) async {
    final prefs = await SharedPreferences.getInstance();
    final keyPrefix = widget.phoneNumber;
    await prefs.setString('message_${keyPrefix}_message', message);
    await prefs.setInt('message_${keyPrefix}_timestamp', timestamp);
  }

  Future<void> _loadLatestMessage() async {
    final prefs = await SharedPreferences.getInstance();
    final keyPrefix = widget.phoneNumber;
    final messageJson = prefs.getString('message_${keyPrefix}_message');
    final timestamp = prefs.getInt('message_${keyPrefix}_timestamp') ?? 0;

    if (messageJson != null) {
      final structuredMessage = jsonDecode(messageJson);
      _latestMessage.value = {
        'message': structuredMessage,
        'timestamp': timestamp,
      };
    }
  }

  Future<void> _sendSMS() async {
    final phoneNumber = _phoneController.text.trim();
    const fixedMessage = "SPHO"; // Changed message to "SMSG"

    if (phoneNumber.isEmpty) {
      _showDialog("Validation Error", "Phone number is required.");
      return;
    }

    if (!await Permission.sms.isGranted) {
      if (!await Permission.sms.request().isGranted) {
        _showDialog("Permission Denied", "SMS permission not granted.");
        return;
      }
    }

    _lastSentNumber = phoneNumber;
    _responseReceived.value = false;

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

    _timeoutTimer = Timer(const Duration(seconds: 60), () {
      if (!_responseReceived.value && Navigator.canPop(context)) {
        Navigator.of(context).pop();
        _showDialog("No Response", "Please try again later.");
      }
    });

    try {
      await _telephony.sendSms(to: phoneNumber, message: fixedMessage);
    } catch (e) {
      if (Navigator.canPop(context)) Navigator.of(context).pop();
      _timeoutTimer?.cancel();
      _showDialog("Error", "SMS failed to send: ${e.toString()}");
    }
  }

  void _showDialog(String title, String content) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text("OK")),
        ],
      ),
    );
  }

  Widget _buildMessageCard(Map<String, dynamic> messageData, String formattedDate) {
    final message = messageData['message'];
    if (message is! Map<String, dynamic>) {
      return const Center(child: Text("Invalid message format"));
    }

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Structured Status Message\n$formattedDate", style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            _buildStatusRow("PR-M1 Parameters", message['PR-M1'].toString()),
            _buildStatusRow("PR-M2 Parameters", message['PR-M2'].toString()),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusRow(String label, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text("$label:", style: const TextStyle(fontWeight: FontWeight.w600)),
          Text(value ?? 'N/A', style: const TextStyle(color: Colors.blueGrey)),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _timeoutTimer?.cancel();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Phone Number Status"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextFormField(
              controller: _phoneController,
              decoration: const InputDecoration(labelText: "Phone Number"),
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _sendSMS,
              child: const Text("Send SMS"),
            ),
            const SizedBox(height: 20),
            ValueListenableBuilder<Map<String, dynamic>>(
              valueListenable: _latestMessage,
              builder: (_, messageData, __) {
                final timestamp = messageData['timestamp'] as int;
                final formattedDate = DateFormat('yyyy-MM-dd HH:mm').format(DateTime.fromMillisecondsSinceEpoch(timestamp));
                return _buildMessageCard(messageData, formattedDate);
              },
            ),
          ],
        ),
      ),
    );
  }
}
