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

  String? _m1Message;
  String? _m2Message;

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

        if (body.startsWith("PR-M1:")) {
          _m1Message = body;
        } else if (body.startsWith("PR-M2:")) {
          _m2Message = body;
        }

        if (_m1Message != null && _m2Message != null) {
          final allParams = <String, String>{};

          final m1Lines = _m1Message!.split('\n');
          final m2Lines = _m2Message!.split('\n');
          final allLines = [...m1Lines.skip(1), ...m2Lines.skip(1)]; // skip PR-M1:/PR-M2:

          for (var i = 0; i < allLines.length; i++) {
            final param = 'P${i + 1}';
            final value = allLines[i].replaceAll('$param-', '').trim();
            allParams[param] = value;
          }

          final timestamp = message.date ?? DateTime.now().millisecondsSinceEpoch;

          _latestMessage.value = {
            'message': allParams,
            'timestamp': timestamp,
          };

          _saveLatestMessage(jsonEncode(allParams), timestamp);

          _m1Message = null;
          _m2Message = null;
        }
      },
      listenInBackground: false,
    );
  }

  Future<void> _saveLatestMessage(String message, int timestamp) async {
    final prefs = await SharedPreferences.getInstance();
    final keyPrefix = widget.phoneNumber;

    await prefs.setString('message_${keyPrefix}_phone', message);
    await prefs.setInt('message_${keyPrefix}_phone_time', timestamp);
  }

  Future<void> _loadLatestMessage() async {
    final prefs = await SharedPreferences.getInstance();
    final keyPrefix = widget.phoneNumber;
    final messageJson = prefs.getString('message_${keyPrefix}_phone');
    final timestamp = prefs.getInt('message_${keyPrefix}_phone_time') ?? 0;

    if (messageJson != null) {
      final structuredMessage = Map<String, dynamic>.from(jsonDecode(messageJson));
      _latestMessage.value = {
        'message': structuredMessage,
        'timestamp': timestamp,
      };
    }
  }

  Future<void> _sendSMS() async {
    final phoneNumber = _phoneController.text.trim();
    const fixedMessage = "SPHO";

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
      _showDialog( "Unsupported Android Version",
          "Please note that this feature is supported only on Android 12 and or above. SMS commands remain available for standard communication. For further information, kindly refer to the Help Page.");
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
    final message = Map<String, dynamic>.from(messageData['message'] ?? {});

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
            ...List.generate(20, (index) {
              final key = 'P${index + 1}';
              final value = message[key] ?? 'N/A';
              return _buildStatusRow(key, value);
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text("$label:", style: const TextStyle(fontWeight: FontWeight.w600)),
          Text(value, style: const TextStyle(color: Colors.blueGrey)),
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
      backgroundColor: const Color(0xFFF2F6FC),
      appBar: AppBar(title: const Text("Get Phone Number")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(  // Add scroll view here
          child: Column(
            children: [
              ElevatedButton.icon(
                onPressed: _sendSMS,
                icon: const Icon(Icons.send),
                label: const Text("Get Number"),
              ),
              const SizedBox(height: 20),
              ValueListenableBuilder<Map<String, dynamic>>(
                valueListenable: _latestMessage,
                builder: (context, data, _) {
                  final timestamp = data['timestamp'] ?? 0;
                  final formattedDate = timestamp != 0
                      ? DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.fromMillisecondsSinceEpoch(timestamp))
                      : 'Unknown';

                  final message = Map<String, dynamic>.from(data['message'] ?? {});
                  if (message.isEmpty) {
                    return const Center(child: Text("No structured message received yet."));
                  }

                  return _buildMessageCard(data, formattedDate);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
